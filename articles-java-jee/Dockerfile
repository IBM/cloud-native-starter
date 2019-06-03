FROM open-liberty:microProfile2-java11
# OpenJ9 0.14.0
# OpenJDK 11.0.3+7
# Open Liberty 19.0.0.5
# MicroProfile 2.2

ADD https://github.com/WASdev/sample.opentracing.zipkintracer/releases/download/1.2/liberty-opentracing-zipkintracer-1.2-sample.zip /

RUN unzip liberty-opentracing-zipkintracer-1.2-sample.zip -d /opt/ol/wlp/usr/ \
 && rm liberty-opentracing-zipkintracer-1.2-sample.zip
# alternatively liberty-opentracing-zipkintracer-1.2-sample.zip can be downloaded via pom.xml: https://github.com/WASdev/sample.opentracing.zipkintracer

COPY liberty/server.xml /config/

ADD target/articles.war /config/dropins/

ADD target/jcc-11.1.4.4.jar /opt/ol/wlp/usr/shared/resources/jcc-11.1.4.4.jar