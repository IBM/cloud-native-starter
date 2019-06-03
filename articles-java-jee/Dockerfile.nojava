FROM maven:3.6-jdk-8 as BUILD
 
COPY src /usr/src/app/src
COPY pom.xml /usr/src/app
WORKDIR /usr/src/app
RUN mvn package


FROM open-liberty:microProfile2-java11

COPY liberty-opentracing-zipkintracer /opt/ol/wlp/usr/

COPY liberty/server.xml /config/

COPY --from=BUILD /usr/src/app/target/articles.war /config/dropins/

COPY --from=BUILD /usr/src/app/target/jcc-11.1.4.4.jar /opt/ol/wlp/usr/shared/resources/