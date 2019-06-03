FROM open-liberty:microProfile2-java11

ADD https://github.com/WASdev/sample.opentracing.zipkintracer/releases/download/1.2/liberty-opentracing-zipkintracer-1.2-sample.zip /

RUN unzip liberty-opentracing-zipkintracer-1.2-sample.zip -d /opt/ol/wlp/usr/ \
 && rm liberty-opentracing-zipkintracer-1.2-sample.zip

COPY liberty/server.xml /config/
COPY key.jks /config/

ADD target/web-api.war /config/dropins/