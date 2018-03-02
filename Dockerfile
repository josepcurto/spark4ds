# spark for Data Science
FROM rocker/r-base:latest

MAINTAINER Josep Curto <josep.curto@gmail.com>

## install curl, git and gnupg
RUN apt-get update && apt-get install -y \
	git \
	gnupg \
	curl

## install java 
RUN echo "deb http://ppa.launchpad.net/webupd8team/java/ubuntu trusty main" \
      | tee /etc/apt/sources.list.d/webupd8team-java.list \
    &&  echo "deb-src http://ppa.launchpad.net/webupd8team/java/ubuntu trusty main" \
      | tee -a /etc/apt/sources.list.d/webupd8team-java.list \
    && apt-key adv --keyserver keyserver.ubuntu.com --recv-keys EEA14886 \
    && echo "oracle-java8-installer shared/accepted-oracle-license-v1-1 select true" \
        | /usr/bin/debconf-set-selections \
    && apt-get update \
    && apt-get install -y oracle-java8-installer \
    && update-alternatives --display java \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get clean \
    && R CMD javareconf

# install python3 and pip for python3
RUN apt-get update
RUN apt-get install -y python3-pip

# python ds
RUN pip3 install numpy
RUN pip3 install pandasql
RUN pip3 install scipy
RUN pip3 install scikit-learn

# install spark and zeppelin
ENV SPARK_VERSION 2.3.0
ENV SPARK_HADOOP_PROFILE 2.7
ENV SPARK_SRC_URL https://www.apache.org/dist/spark/spark-$SPARK_VERSION/spark-${SPARK_VERSION}-bin-hadoop${SPARK_HADOOP_PROFILE}.tgz
ENV SPARK_HOME=/opt/spark
ENV PATH $PATH:$SPARK_HOME/bin

# download and unpack spark 
RUN wget ${SPARK_SRC_URL}
RUN tar -xzf spark-${SPARK_VERSION}-bin-hadoop${SPARK_HADOOP_PROFILE}.tgz
 
# moving the spark root folder to /opt/spark
RUN mv spark-${SPARK_VERSION}-bin-hadoop${SPARK_HADOOP_PROFILE} /opt/spark

# clean
RUN rm -f spark-${SPARK_VERSION}-bin-hadoop${SPARK_HADOOP_PROFILE}.tgz

# Zeppelin
ENV ZEPPELIN_PORT 8080
ENV ZEPPELIN_HOME /usr/zeppelin
ENV ZEPPELIN_CONF_DIR $ZEPPELIN_HOME/conf
ENV ZEPPELIN_NOTEBOOK_DIR $ZEPPELIN_HOME/notebook
ENV ZEPPELIN_COMMIT daceee568874a1c98c54ae487700858d2300854b
RUN set -ex \
 && buildDeps=' \
    git \
    bzip2 \
 ' \
 && apt-get update && apt-get install -y --no-install-recommends $buildDeps \
 && curl -sL http://archive.apache.org/dist/maven/maven-3/3.3.9/binaries/apache-maven-3.3.9-bin.tar.gz \
   | gunzip \
   | tar x -C /tmp/ \
 && git clone https://github.com/apache/zeppelin.git /usr/src/zeppelin \
 && cd /usr/src/zeppelin \
 && git checkout -q $ZEPPELIN_COMMIT \
 && sed -i 's/--no-color/buildSkipTests --no-color/' zeppelin-web/pom.xml \
 && MAVEN_OPTS="-Xms512m -Xmx1024m" /tmp/apache-maven-3.3.9/bin/mvn --batch-mode package -DskipTests -Pbuild-distr \
  -pl 'zeppelin-interpreter,zeppelin-zengine,zeppelin-display,spark-dependencies,spark,markdown,angular,shell,hbase,postgresql,jdbc,python,elasticsearch,zeppelin-web,zeppelin-server,zeppelin-distribution' \
 && tar xvf /usr/src/zeppelin/zeppelin-distribution/target/zeppelin*.tar.gz -C /usr/ \
 && mv /usr/zeppelin* $ZEPPELIN_HOME \
 && mkdir -p $ZEPPELIN_HOME/logs \
 && mkdir -p $ZEPPELIN_HOME/run \
 && rm -rf $ZEPPELIN_NOTEBOOK_DIR/r \
 && apt-get purge -y --auto-remove $buildDeps \
 && rm -rf /var/lib/apt/lists/* \
 && rm -rf /usr/src/zeppelin \
 && rm -rf /root/.m2 \
 && rm -rf /root/.npm \
 && rm -rf /tmp/*

WORKDIR $ZEPPELIN_HOME
CMD ["bin/zeppelin.sh"]