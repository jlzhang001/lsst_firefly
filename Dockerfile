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
ENV TOMCAT_VERSION 8.0.30

# Get Tomcat
RUN wget --no-cookies http://apache.rediris.es/tomcat/tomcat-8/v${TOMCAT_VERSION}/bin/apache-tomcat-${TOMCAT_VERSION}.tar.gz -O /tmp/tomcat.tgz && \
tar xzvf /tmp/tomcat.tgz -C /opt && \
mv /opt/apache-tomcat-${TOMCAT_VERSION} /opt/tomcat && \
rm /tmp/tomcat.tgz && \
rm -rf /opt/tomcat/webapps/examples && \
rm -rf /opt/tomcat/webapps/docs && \
rm -rf /opt/tomcat/webapps/ROOT

# Get python.
RUN apt-get update && apt-get install -y python python-numpy

# Get gradle
RUN add-apt-repository -y ppa:cwchien/gradle && \
apt-get update && \
apt-get install -y gradle


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

RUN curl -sL https://deb.nodesource.com/setup_5.x | sudo -E bash - && \
apt-get install -y nodejs


RUN npm install --save npm-latest-version
# Add admin/admin user
ADD tomcat-users.xml /opt/tomcat/conf/

# Firefly
RUN git clone https://github.com/lsst/firefly.git /tmp/firefly && \
cd /tmp/firefly && gradle :firefly:jar && gradle :fftools:war

RUN apt-get install -y python-astropy


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
ADD run.sh /etc/my_init.d/run.sh
ADD server.xml /opt/tomcat/conf/server.xml

VOLUME ["/www/static", "/www/algorithm"]

# Launch Tomcat
# CMD ["/bin/bash" "startup.sh"]
# CMD chmod +x *.sh && source startup.sh
