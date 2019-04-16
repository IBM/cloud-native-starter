## Building a Container

****** **UNDER CONSTRUCTION** ******

In this Lab we build a container with services one is called **'articles'** and the other is called. **'web-api'**.

### Services

**Articles service**

The objective of this service is to add and get artical information from a database. At moment the implementation is just showing is creating sample data values.

The service is organized in following packages:
* apis
* business
* data


**Web-api service**

The objective of this service is to combine information from different services and provide that information to be consumned using a REST api in the vue webapp. In this case the information of articals and authors are combined to be consunmed by the webapp.

### Technology

Both services are based purly only on open source components:

* [OpenJ9 0.12.1](https://projects.eclipse.org/projects/technology.openj9/releases/0.12.1/review)
* OpenJDK 8u202-b08 from AdoptOpenJDK
* [Open Liberty 18.0.0.4](https://openliberty.io/downloads/)
* [MicroProfile 2.1](https://projects.eclipse.org/projects/technology.microprofile/releases/microprofile-2.1)

To ensure that distributed tracing it supported [zipkintracer](https://github.com/openzipkin/zipkin-ruby) is copied onto the image.

### Dockerfile for the container

This is the used [Dockerfile](../articles-java-jee/Dockerfile.nojava) which uses multiple stages so that the image can be built on environments that don't have Java and Maven (or wrong versions) installed.

First maven 3.5 will be installed in the container from the [dockerhub](https://hub.docker.com/_/maven/).

```
FROM maven:3.5-jdk-8 as BUILD
COPY src /usr/src/app/src
COPY pom.xml /usr/src/app
RUN mvn -f /usr/src/app/pom.xml clean package
```

Then **openliberty** with **microProfile2** and the **zipkintracer** will be installed in the container.

```
FROM openliberty/open-liberty:microProfile2-java8-openj9
ADD liberty-opentracing-zipkintracer-1.2-sample.zip /
RUN unzip liberty-opentracing-zipkintracer-1.2-sample.zip -d /opt/ol/wlp/usr/ \
 && rm liberty-opentracing-zipkintracer-1.2-sample.zip
COPY liberty/server.xml /config/
COPY --from=BUILD /usr/src/app/target/articles.war /config/dropins/
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


