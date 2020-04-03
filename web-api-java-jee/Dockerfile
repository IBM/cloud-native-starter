FROM open-liberty:19.0.0.9-kernel-java11

COPY liberty-opentracing-zipkintracer /opt/ol/wlp/usr/
COPY liberty/server.xml /config/
COPY key.jks /config/

ADD target/web-api.war /config/dropins/

# This script will add the requested XML snippets, grow image to be fit-for-purpose and apply interim fixes
# https://github.com/WASdev/ci.docker
RUN configure.sh

EXPOSE 9080