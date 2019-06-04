FROM open-liberty:microProfile2-java11
# OpenJ9 0.14.0
# OpenJDK 11.0.3+7
# Open Liberty 19.0.0.5
# MicroProfile 2.2

COPY liberty-opentracing-zipkintracer /opt/ol/wlp/usr/

COPY liberty/server.xml /config/

ADD target/articles.war /config/dropins/

ADD target/jcc-11.1.4.4.jar /opt/ol/wlp/usr/shared/resources/jcc-11.1.4.4.jar