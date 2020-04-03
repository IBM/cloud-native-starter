FROM maven:3.5-jdk-8 as BUILD
 
COPY src /usr/src/app/src
COPY pom.xml /usr/src/app
RUN mvn -f /usr/src/app/pom.xml clean package


FROM open-liberty:19.0.0.9-kernel-java11

COPY liberty-opentracing-zipkintracer /opt/ol/wlp/usr/

COPY liberty/server.xml /config/

COPY key.jks /config/

COPY --from=BUILD /usr/src/app/target/web-api.war /config/dropins/

# This script will add the requested XML snippets, grow image to be fit-for-purpose and apply interim fixes
# https://github.com/WASdev/ci.docker
RUN configure.sh

EXPOSE 9080