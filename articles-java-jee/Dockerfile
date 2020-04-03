FROM open-liberty:19.0.0.9-kernel-java11
# OpenJ9 0.14.0
# OpenJDK 11.0.3+7
# Open Liberty 19.0.0.5

COPY liberty-opentracing-zipkintracer /opt/ol/wlp/usr/

COPY liberty/server.xml /config/

ADD target/articles.war /config/dropins/

ADD target/jcc-11.1.4.4.jar /opt/ol/wlp/usr/shared/resources/jcc-11.1.4.4.jar

# This script will add the requested XML snippets, grow image to be fit-for-purpose and apply interim fixes
# https://github.com/WASdev/ci.docker
RUN configure.sh

EXPOSE 8080