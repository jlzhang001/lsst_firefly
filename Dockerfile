FROM phusion/baseimage:latest

MAINTAINER DCRW


CMD ["/sbin/my_init"]

# Fix sh
RUN rm /bin/sh && ln -s /bin/bash /bin/sh

########## Install JDK 8 ##########
RUN \
add-apt-repository -y ppa:webupd8team/java && \
apt-get update && \
echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | debconf-set-selections && \
apt-get install -y oracle-java8-installer wget unzip tar && \
rm -rf /var/lib/apt/lists/* && \
rm -rf /var/cache/oracle-jdk8-installer
ENV JAVA_HOME /usr/lib/jvm/java-8-oracle
ENV JRE_HOME /usr/lib/jvm/java-8-oracle/jre


# ########## Install Gradle ##########
# RUN add-apt-repository -y ppa:cwchien/gradle
# RUN apt-get update && \
# apt-get install -y gradle-2.14.1
#
#
# ########## Install Nodejs ##########
# RUN curl -sL https://deb.nodesource.com/setup_6.x | bash -
# RUN apt-get install -y nodejs
# RUN npm install --save npm-latest-version


# ########## Install Anaconda ##########
ENV CONDA_URL https://repo.continuum.io/miniconda/Miniconda3-4.1.11-Linux-x86_64.sh
RUN apt-get update --fix-missing && apt-get install -y wget bzip2 ca-certificates \
    libglib2.0-0 libxext6 libsm6 libxrender1 \
    git mercurial subversion

RUN echo 'export PATH=/opt/conda/bin:$PATH' > /etc/profile.d/conda.sh && \
    wget --quiet "$CONDA_URL" -O ~/miniconda.sh && \
    /bin/bash ~/miniconda.sh -b -p /opt/conda && \
    rm ~/miniconda.sh
ENV PATH /opt/conda/bin:$PATH
RUN conda install scipy numpy astropy six && \
    conda clean -i -l -t -y
ENV LANG C.UTF-8

# RUN apt-get install -y curl grep sed dpkg && \
#     TINI_VERSION=`curl https://github.com/krallin/tini/releases/latest | grep -o "/v.*\"" | sed 's:^..\(.*\).$:\1:'` && \
#     curl -L "https://github.com/krallin/tini/releases/download/v${TINI_VERSION}/tini_${TINI_VERSION}.deb" > tini.deb && \
#     dpkg -i tini.deb && \
#     rm tini.deb && \
#     apt-get clean
# # Install common packages
# # http://bugs.python.org/issue19846
# # > At the moment, setting "LANG=C" on a Linux system *fundamentally breaks Python 3*, and that's not OK.
# RUN conda install astropy scipy numpy


########## Install Tomcat ##########
ENV CATALINA_HOME /opt/tomcat
ENV PATH $CATALINA_HOME/bin:$PATH
WORKDIR /opt

ENV TOMCAT_MAJOR 9
ENV TOMCAT_VERSION 9.0.0.M9
ENV TOMCAT_TGZ_URL https://www.apache.org/dist/tomcat/tomcat-$TOMCAT_MAJOR/v$TOMCAT_VERSION/bin/apache-tomcat-$TOMCAT_VERSION.tar.gz
ENV TOMCAT_TEMP /tmp/tomcat.tar.gz
# Wget Tomcat
RUN wget --no-cookies "$TOMCAT_TGZ_URL" -O "$TOMCAT_TEMP" && \
    tar xzvf "$TOMCAT_TEMP"
RUN mv apache-tomcat-${TOMCAT_VERSION} $CATALINA_HOME && \
    rm "$TOMCAT_TEMP"


########## Build Firefly ##########
# Already built once. Simple add fftools.war into tomcat directory.

# ENV FIREFLY_GIT https://github.com/Caltech-IPAC/firefly.git
# RUN git clone "$FIREFLY_GIT" /tmp/firefly
# RUN cd /tmp/firefly && git checkout rc && \
# gradle :firefly:jar && gradle :fftools:war


########## Copy firefly webapp to tomcat server ##########
COPY ./fftools.war ${CATALINA_HOME}/webapps/

EXPOSE 8080
EXPOSE 8009
VOLUME "/opt/tomcat/webapps"
WORKDIR /opt/tomcat/bin

RUN mkdir -p /etc/my_init.d && mkdir /www
ADD run.sh /etc/my_init.d/run1.sh
ADD server.xml /opt/tomcat/conf/server.xml

WORKDIR /opt/tomcat/webapps
#RUN mkdir fftools && cd fftools && jar -xvf ../fftools.war

# RUN sed '$d' fftools/WEB-INF/config/app.prop
# RUN "python.exe=/usr/bin/python /www/algorithm/dispatcher.py" >> fftools/WEB-INF/config/app.prop

VOLUME ["/www/static", "/www/algorithm"]

# Launch Tomcat
# CMD ["/bin/bash" "startup.sh"]
# CMD chmod +x *.sh && source startup.sh
