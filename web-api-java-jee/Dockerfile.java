FROM open-liberty:microProfile2-java11

COPY liberty-opentracing-zipkintracer /opt/ol/wlp/usr/
COPY liberty/server.xml /config/
COPY key.jks /config/

ADD target/web-api.war /config/dropins/