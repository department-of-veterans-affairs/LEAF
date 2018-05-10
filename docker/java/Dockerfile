FROM ubuntu:16.04
#FROM java:8
MAINTAINER Nick Ciardiello <nick.ciardiello@ablevets.com>

ADD docker/java/Websocket-Digital-Signature-1.0-SNAPSHOT.jar /
ADD docker/java/sc.key /
ADD docker/java/sc.pem /

EXPOSE 8765

RUN apt-get update
RUN yes | apt-get install default-jre
RUN yes | apt-get install opensc

ENTRYPOINT [ "java", "-jar", "/Websocket-Digital-Signature-1.0-SNAPSHOT.jar" ]
