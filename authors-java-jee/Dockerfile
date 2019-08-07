FROM maven:3.5-jdk-8
 
COPY src /usr/src/app/src
COPY pom.xml /usr/src/app
RUN mvn -f /usr/src/app/pom.xml clean package


FROM open-liberty:microProfile2-java11

COPY liberty/server.xml /config/

COPY --from=0 /usr/src/app/target/authors.war /config/apps/

EXPOSE 3000