FROM phusion/baseimage:0.9.18
EXPOSE 8080

MAINTAINER Meillaud Jean-Christophe (jc@houseofagile.com)
ENV JAVA_VERSION 8
ENV MYSQL_CONNECTOR_VERSION 5.1.36

# Install Java 8
RUN DEBIAN_FRONTEND=noninteractive apt-get update && apt-get install -q -y git-core software-properties-common python-software-properties && \
  apt-add-repository ppa:webupd8team/java -y && \
  echo oracle-java${JAVA_VERSION}-installer shared/accepted-oracle-license-v1-1 select true | debconf-set-selections && \
  DEBIAN_FRONTEND=noninteractive apt-get update &&  apt-get install oracle-java${JAVA_VERSION}-installer -y && \
  mkdir /srv/www

# Install Jira
ADD install-jira.sh /root/
RUN /root/install-jira.sh

## Install SSH for a specific user (thanks to public key)
ADD ./config/id_rsa.pub /tmp/your_key
RUN cat /tmp/your_key >> /root/.ssh/authorized_keys && rm -f /tmp/your_key

# Add private key in order to get access to private repo
ADD ./config/id_rsa /root/.ssh/id_rsa

# Launching Jira
WORKDIR /opt/jira-home
RUN rm -f /opt/jira-home/.jira-home.lock

# Add mysql driver
RUN curl -sSL http://dev.mysql.com/get/Downloads/Connector-J/mysql-connector-java-${MYSQL_CONNECTOR_VERSION}.tar.gz -o /tmp/mysql-connector-java.tar.gz && \
  tar xzf /tmp/mysql-connector-java.tar.gz -C /tmp && \
  cp /tmp/mysql-connector-java-${MYSQL_CONNECTOR_VERSION}/mysql-connector-java-${MYSQL_CONNECTOR_VERSION}-bin.jar /opt/jira/lib/

# Add start script in my_init.d of phusion baseimage
RUN mkdir -p /etc/my_init.d
ADD ./start-jira.sh /etc/my_init.d/start-jira.sh

CMD  ["/sbin/my_init"]
