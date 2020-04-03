FROM maven:3.6-jdk-11 as BUILD
 
COPY src /usr/src/app/src
COPY pom.xml /usr/src/app
WORKDIR /usr/src/app
RUN mvn package

FROM adoptopenjdk:11-jre-openj9

COPY --from=BUILD /usr/src/app/target/articles.jar /

COPY --from=BUILD /usr/src/app/target/jcc-11.1.4.4.jar /

ENTRYPOINT ["java", "-jar", "articles.jar" ]