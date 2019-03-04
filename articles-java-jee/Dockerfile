FROM openliberty/open-liberty:microProfile2-java8-openj9
# OpenJ9 0.12.1
# OpenJDK 8u202-b08
# Open Liberty 18.0.0.4
# MicroProfile 2.1 (as of 03/02/2019 there is no image with MicroProfile 2.2 yet)

ADD https://github.com/WASdev/sample.opentracing.zipkintracer/releases/download/1.2/liberty-opentracing-zipkintracer-1.2-sample.zip /

RUN unzip liberty-opentracing-zipkintracer-1.2-sample.zip -d /opt/ol/wlp/usr/ \
 && rm liberty-opentracing-zipkintracer-1.2-sample.zip

COPY liberty/server.xml /config/

ADD target/articles.war /config/dropins/