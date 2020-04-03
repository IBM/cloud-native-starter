FROM adoptopenjdk/maven-openjdk11 as BUILD
COPY src /usr/src/app/src
COPY pom.xml /usr/src/app
WORKDIR /usr/src/app
RUN mvn package

FROM adoptopenjdk/openjdk11-openj9:ubi-minimal
ENV JAVA_OPTIONS="-Dquarkus.http.host=0.0.0.0 -Djava.util.logging.manager=org.jboss.logmanager.LogManager"
ENV AB_ENABLED=jmx_exporter
RUN mkdir /opt/shareclasses
# OpenShift permissions:
RUN chmod a+rwx -R /opt/shareclasses
RUN mkdir /opt/app
COPY --from=BUILD /usr/src/app/target/lib/* /opt/app/lib/
COPY --from=BUILD /usr/src/app/target/*-runner.jar /opt/app/app.jar
ENV JAVA_APP_DIR=/opt/app \
    JAVA_MAJOR_VERSION=11
COPY run-java.sh /opt/app/
RUN chmod 755 /opt/app/run-java.sh
ENTRYPOINT [ "/opt/app/run-java.sh" ]