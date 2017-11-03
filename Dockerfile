FROM ubuntu:14.04
MAINTAINER Lewis
ENV DEBIAN_FRONTEND noninteractive

RUN \
    echo 'APT::Get::Assume-Yes "true";' > /etc/apt/apt.conf.d/90forceyes;\
    echo 'deb http://archive.ubuntu.com/ubuntu trusty main universe restricted' > /etc/apt/sources.list;\
    echo 'deb http://archive.ubuntu.com/ubuntu trusty-updates  main universe restricted' >> /etc/apt/sources.list;\
    apt-get update;\
    echo exit 101 > /usr/sbin/policy-rc.d && chmod +x /usr/sbin/policy-rc.d;\
    dpkg-divert --local --rename --add /sbin/initctl;\
    ln -sf /bin/true /sbin/initctl;\
    apt-get -y upgrade && apt-get clean ;\
    apt-get install gcc-multilib wget

RUN \
    cd /tmp ;\
    wget --no-check-certificate --no-cookies --header "Cookie: oraclelicense=accept-securebackup-cookie" -O jdk-1_5_0_22-linux-amd64.bin http://download.oracle.com/otn-pub/java/jdk/1.5.0_22/jdk-1_5_0_22-linux-amd64.bin

# alternate  java method disabled: download local jdk
#ADD jdk-1_5_0_22-linux-amd64.bin /tmp/

RUN \
    echo yes|sh /tmp/jdk-1_5_0_22-linux-amd64.bin ;\
    rm /tmp/jdk-1_5_0_22-linux-amd64.bin

ENV JAVA_HOME /jdk1.5.0_22
ENV PATH /jdk1.5.0_22/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin



RUN apt-get update && \
apt-get install -yq --no-install-recommends wget pwgen ca-certificates && \
apt-get clean && \
rm -rf /var/lib/apt/lists/*

ENV TOMCAT_MAJOR_VERSION 6
ENV TOMCAT_MINOR_VERSION 6.0.41
ENV CATALINA_HOME /tomcat

#INSTALL TOMCAT
RUN wget -q https://archive.apache.org/dist/tomcat/tomcat-${TOMCAT_MAJOR_VERSION}/v${TOMCAT_MINOR_VERSION}/bin/apache-tomcat-${TOMCAT_MINOR_VERSION}.tar.gz && \
wget -qO- https://archive.apache.org/dist/tomcat/tomcat-${TOMCAT_MAJOR_VERSION}/v${TOMCAT_MINOR_VERSION}/bin/apache-tomcat-${TOMCAT_MINOR_VERSION}.tar.gz.md5 | md5sum -c - && \
tar zxf apache-tomcat-.tar.gz && \
rm apache-tomcat-.tar.gz && \
mv apache-tomcat* tomcat

ADD create_tomcat_admin_user.sh /create_tomcat_admin_user.sh
ADD run.sh /run.sh
RUN chmod +x /*.sh

EXPOSE 8080
CMD ["/run.sh"]
