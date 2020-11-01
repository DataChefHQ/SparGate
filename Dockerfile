FROM alpine:3.12

ARG HADOOP_VERSION=3.2.0
ARG HADOOP_VERSION_SHORT=3.2
ARG SPARK_VERSION=3.0.1
ARG AWS_SDK_VERSION=1.11.375

ARG SPARK_PACKAGE=spark-${SPARK_VERSION}-bin-hadoop${HADOOP_VERSION_SHORT}.tgz
ARG SPARK_PACKAGE_URL=https://downloads.apache.org/spark/spark-${SPARK_VERSION}/${SPARK_PACKAGE}
ARG HADOOP_JAR=https://repo1.maven.org/maven2/org/apache/hadoop/hadoop-aws/${HADOOP_VERSION}/hadoop-aws-${HADOOP_VERSION}.jar
ARG AWS_SDK_JAR=https://repo1.maven.org/maven2/com/amazonaws/aws-java-sdk-bundle/${AWS_SDK_VERSION}/aws-java-sdk-bundle-${AWS_SDK_VERSION}.jar

# Install dependencies
RUN apk update
RUN apk add openjdk8-jre bash snappy

# Install spark
ADD ${SPARK_PACKAGE_URL} /tmp/
RUN tar xvf /tmp/$SPARK_PACKAGE -C /opt
RUN ln -vs /opt/spark* /opt/spark

COPY spark-defaults.conf /opt/spark/conf/spark-defaults.conf

ADD $HADOOP_JAR  /opt/spark/jars/
ADD $AWS_SDK_JAR /opt/spark/jars/

# Fix snappy library load issue
RUN apk add libc6-compat
RUN ln -s /lib/libc.musl-x86_64.so.1 /lib/ld-linux-x86-64.so.2

# Cleanup
RUN rm -rfv /tmp/*

# Add Spark tools to path
ENV PATH="/opt/spark/bin/:${PATH}"

CMD ["spark-shell"]
