FROM phusion/baseimage

MAINTAINER DCRW


CMD ["/sbin/my_init"]

# Fix sh
RUN rm /bin/sh && ln -s /bin/bash /bin/sh

# Install dependencies
RUN apt-get update && \
apt-get install -y software-properties-common && \
apt-get install -y git build-essential curl wget


# Install JDK 8
RUN \
add-apt-repository -y ppa:webupd8team/java && \
apt-get update && \
echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | debconf-set-selections && \
apt-get install -y oracle-java8-installer wget unzip tar && \
rm -rf /var/lib/apt/lists/* && \
rm -rf /var/cache/oracle-jdk8-installer

# Define commonly used JAVA_HOME variable
ENV JAVA_HOME /usr/lib/jvm/java-8-oracle
ENV JRE_HOME /usr/lib/jvm/java-8-oracle/jre
ENV TOMCAT_VERSION 8.0.32

# Get Tomcat
RUN wget --no-cookies http://apache.rediris.es/tomcat/tomcat-8/v${TOMCAT_VERSION}/bin/apache-tomcat-${TOMCAT_VERSION}.tar.gz -O /tmp/tomcat.tgz && \
tar xzvf /tmp/tomcat.tgz -C /opt && \
mv /opt/apache-tomcat-${TOMCAT_VERSION} /opt/tomcat && \
rm /tmp/tomcat.tgz && \
rm -rf /opt/tomcat/webapps/examples && \
rm -rf /opt/tomcat/webapps/docs && \
rm -rf /opt/tomcat/webapps/ROOT


# Get gradle
RUN add-apt-repository -y ppa:cwchien/gradle
RUN apt-get update && \
apt-get install -y gradle

# Get python.
RUN apt-get update && apt-get install -y python python-numpy

# Install Node.js
# gpg keys listed at https://github.com/nodejs/node
# RUN \
#   cd /tmp && \
#   wget http://nodejs.org/dist/node-latest.tar.gz && \
#   tar xvzf node-latest.tar.gz && \
#   rm -f node-latest.tar.gz && \
#   cd node-v* && \
#   ./configure && \
#   CXX="g++ -Wno-unused-local-typedefs" make && \
#   CXX="g++ -Wno-unused-local-typedefs" make install && \
#   cd /tmp && \
#   rm -rf /tmp/node-v* && \
#   npm install -g npm && \
#   printf '\n# Node.js\nexport PATH="node_modules/.bin:$PATH"' >> /root/.bashrc

RUN curl -sL https://deb.nodesource.com/setup_5.x | sudo -E bash -
RUN apt-get install -y nodejs


RUN npm install --save npm-latest-version
# Add admin/admin user

# Firefly
RUN git clone https://github.com/lsst/firefly.git /tmp/firefly && \
cd /tmp/firefly && gradle :firefly:jar && gradle :fftools:war

RUN apt-get install -y python-astropy

RUN apt-get update --fix-missing && apt-get install -y wget bzip2 ca-certificates \
    libglib2.0-0 libxext6 libsm6 libxrender1 \
    git mercurial subversion
RUN echo 'export PATH=/opt/conda/bin:$PATH' > /etc/profile.d/conda.sh && \
    wget --quiet https://repo.continuum.io/archive/Anaconda2-2.5.0-Linux-x86_64.sh && \
    /bin/bash /Anaconda2-2.5.0-Linux-x86_64.sh -b -p /opt/conda && \
    rm /Anaconda2-2.5.0-Linux-x86_64.sh

RUN apt-get install -y curl grep sed dpkg && \
    TINI_VERSION=`curl https://github.com/krallin/tini/releases/latest | grep -o "/v.*\"" | sed 's:^..\(.*\).$:\1:'` && \
    curl -L "https://github.com/krallin/tini/releases/download/v${TINI_VERSION}/tini_${TINI_VERSION}.deb" > tini.deb && \
    dpkg -i tini.deb && \
    rm tini.deb && \
    apt-get clean

ENV PATH /opt/conda/bin:$PATH

# http://bugs.python.org/issue19846
# > At the moment, setting "LANG=C" on a Linux system *fundamentally breaks Python 3*, and that's not OK.
ENV LANG C.UTF-8

ENV CATALINA_HOME /opt/tomcat
ENV PATH $PATH:$CATALINA_HOME/bin

RUN cp /tmp/firefly/build/libs/fftools.war $CATALINA_HOME/webapps/

# RUN cd /tmp && \
# wget https://github.com/lsst/firefly/releases/download/Firefly-Standalone_2.4.1_Beta-49_master/fftools-exec.war

EXPOSE 8080
EXPOSE 8009
VOLUME "/opt/tomcat/webapps"
WORKDIR /opt/tomcat/bin

RUN mkdir -p /etc/my_init.d && mkdir /www
ADD run.sh /etc/my_init.d/run1.sh
ADD server.xml /opt/tomcat/conf/server.xml

WORKDIR /opt/tomcat/webapps
#RUN mkdir fftools && cd fftools && jar -xvf ../fftools.war

#RUN sed '$d' fftools/WEB-INF/config/app.prop
#RUN "python.exe=/usr/bin/python /www/algorithm/dispatcher.py" >> fftools/WEB-INF/config/app.prop

VOLUME ["/www/static", "/www/algorithm"]

# Launch Tomcat
# CMD ["/bin/bash" "startup.sh"]
# CMD chmod +x *.sh && source startup.sh
