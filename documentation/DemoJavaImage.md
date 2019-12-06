## Demo: Java Image

This project uses for 'articles' and 'web-api' a Java image with only open source components:

* OpenJ9 0.12.1
* OpenJDK 8u202-b08 from AdoptOpenJDK
* Open Liberty 19.0.0.9

Additionally zipkintracer is copied onto the image to support distributed tracing.

This is the used [Dockerfile](../articles-java-jee/Dockerfile.nojava) which uses multiple stages so that the image can be built on environments that don't have Java and Maven (or wrong versions) installed.

```
FROM maven:3.5-jdk-8 as BUILD
COPY src /usr/src/app/src
COPY pom.xml /usr/src/app
RUN mvn -f /usr/src/app/pom.xml clean package

FROM open-liberty:19.0.0.9-kernel-java11
ADD liberty-opentracing-zipkintracer-1.3-sample.zip /
RUN unzip liberty-opentracing-zipkintracer-1.2-sample.zip -d /opt/ol/wlp/usr/ \
 && rm liberty-opentracing-zipkintracer-1.2-sample.zip
COPY liberty/server.xml /config/
COPY --from=BUILD /usr/src/app/target/articles.war /config/dropins/

# This script will add the requested XML snippets, grow image to be fit-for-purpose and apply interim fixes
# https://github.com/WASdev/ci.docker
RUN configure.sh

EXPOSE 8080
```

Invoke the following commands to set up the Java based microservice 'articles':

```
$ cd $PROJECT_HOME
$ scripts/check-prerequisites.sh
$ scripts/delete-all.sh
$ scripts/deploy-articles-java-jee.sh
$ scripts/show-urls.sh
```

Invoke the curl command which is displayed as output of 'scripts/show-urls.sh' to get ten articles.

Check out the article [Dockerizing Java MicroProfile Applications](http://heidloff.net/article/dockerizing-container-java-microprofile) for more details.


