FROM registry.access.redhat.com/rhel7/rhel AS builder
ENV JAVA_HOME=/opt/jdk \
    PATH=${PATH}:/opt/jdk/bin \
    LANG=C.UTF-8

RUN curl -o jdk.tar.gz https://download.java.net/java/GA/jdk10/10.0.1/fb4372174a714e6b8c52526dc134031e/10/openjdk-10.0.1_linux-x64_bin.tar.gz && \
    mkdir -p /opt/jdk && \
    tar zxvf jdk.tar.gz -C /opt/jdk --strip-components=1 && \
    rm jdk.tar.gz && \
    rm /opt/jdk/lib/src.zip
 
WORKDIR /app
 
RUN jlink --module-path $JAVA_HOME/jmods \
        --verbose \
	--add-modules java.base,java.logging,java.xml,jdk.unsupported,java.sql,java.naming,java.desktop,java.management,java.security.jgss,java.instrument \
	--compress 2 \
	--no-header-files \
	--output /opt/jdk-10-minimal

#second stage

FROM registry.access.redhat.com/rhel7/rhel-atomic
COPY --from=builder /opt/jdk-10-minimal /opt/jdk-10-minimal
COPY target/Java10TestSpring-0.0.1-SNAPSHOT.jar /opt/

ENV JAVA_HOME=/opt/jdk-10-minimal
ENV PATH="$PATH:$JAVA_HOME/bin"

EXPOSE 8080
CMD java -jar /opt/Java10TestSpring-0.0.1-SNAPSHOT.jar
