FROM ubuntu:xenial

MAINTAINER Wei Ren


RUN apt-get update \
&& apt-get install -y wget unzip tar git

RUN mkdir /software
WORKDIR /software

########## Install JDK 8 ##########
ENV JDK_URL http://download.oracle.com/otn-pub/java/jdk/8u121-b13/e9e7ea248e2c4826b92b3f075a80e441/jdk-8u121-linux-x64.tar.gz
RUN wget --no-check-certificate --no-cookies --header "Cookie: oraclelicense=accept-securebackup-cookie" "$JDK_URL" -O jdk-download.tar.gz && \
    mkdir jdk_current && \
    for i in *.tar.gz; do tar -xzvf $i -C jdk_current --strip-components 1; done && \
    rm *.tar.gz
ENV JAVA_HOME /software/jdk_current
ENV JRE_HOME $JAVA_HOME/jre
ENV PATH $JAVA_HOME/bin:$JRE_HOME/bin:$PATH

########## Install Gradle & Nodejs ##########
ENV GRADLE_URL https://services.gradle.org/distributions/gradle-3.4.1-bin.zip
RUN wget "$GRADLE_URL" -O gradle-download.zip && \
    mkdir gradle_current && \
    unzip *.zip && \
    mv gradle-*/* gradle_current/ && \
    rm *.zip && \
    rm -r gradle-*
ENV PATH /software/gradle_current/bin:$PATH

ENV NODE_URL https://nodejs.org/dist/v7.7.3/node-v7.7.3-linux-x64.tar.gz
RUN wget "$NODE_URL" -O node-download.tar.gz && \
    mkdir node_current && \
    for i in *.tar.gz; do tar -xzvf "$i" -C node_current --strip-components 1; done && \
    rm *.tar.gz
ENV PATH /software/node_current/bin:$PATH
RUN npm install yarn -g


########## Install miniconda ##########
ENV CONDA_URL https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh
RUN apt-get update --fix-missing && apt-get install -y wget bzip2 ca-certificates \
    libglib2.0-0 libxext6 libsm6 libxrender1 \
    git mercurial subversion

RUN echo 'export PATH=/software/conda/bin:$PATH' > /etc/profile.d/conda.sh && \
    wget --quiet "$CONDA_URL" -O ~/miniconda.sh && \
    /bin/bash ~/miniconda.sh -b -p /software/conda && \
    rm ~/miniconda.sh
ENV PATH /software/conda/bin:$PATH
RUN conda install scipy numpy astropy six && \
    conda clean -i -l -t -y
ENV LANG C.UTF-8


########## Install Tomcat ##########
ENV CATALINA_HOME /software/tomcat
ENV PATH $CATALINA_HOME/bin:$PATH

ENV TOMCAT_MAJOR 7
ENV TOMCAT_VERSION 7.0.76
ENV TOMCAT_TGZ_URL https://www.apache.org/dist/tomcat/tomcat-$TOMCAT_MAJOR/v$TOMCAT_VERSION/bin/apache-tomcat-$TOMCAT_VERSION.tar.gz
ENV TOMCAT_TEMP /tmp/tomcat.tar.gz
# Wget Tomcat
RUN wget --no-cookies "$TOMCAT_TGZ_URL" -O "$TOMCAT_TEMP" && \
    tar xzvf "$TOMCAT_TEMP" && \
    mv apache-tomcat-${TOMCAT_VERSION} $CATALINA_HOME && \
    rm "$TOMCAT_TEMP"


########## Build Firefly ##########
ENV FIREFLY_GIT https://github.com/Caltech-IPAC/firefly.git
RUN git clone "$FIREFLY_GIT" /tmp/firefly
RUN cd /tmp/firefly && git checkout master && \
    gradle :firefly:warAll

########## Copy firefly webapp to tomcat server ##########
RUN cp /tmp/firefly/build/libs/firefly.war /software/tomcat/webapps/


########## Expose port to host ##########
EXPOSE 8080
EXPOSE 8009
VOLUME "/software/tomcat/webapps"
WORKDIR /software/tomcat/bin

########## Initialize script on startup ##########
RUN mkdir -p /lsst/server_config/firefly
ADD ./s_build_Essential/app.prop /lsst/server_config/firefly/app.prop
ADD ./s_build_Essential/setenv.sh /software/tomcat/bin/setenv.sh
RUN chmod u+x setenv.sh

RUN mkdir /www
ADD ./s_build_Essential/server.xml /software/tomcat/conf/server.xml

WORKDIR /software/tomcat/webapps

########## Attach code as volume ##########
VOLUME ["/www/static", "/www/algorithm"]
