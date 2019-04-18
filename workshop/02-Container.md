## Building and deploy the Containers

****** **UNDER CONSTRUCTION** ******

In this Lab we build and deploy the containers with microservices to Kubernetes.
Along this way we will use the configured yaml files to create the deployment and setup the right ISTIO configuration for each microservice.

![cns-container-deployment-01](images/cns-container-deployment-01.png)

### Technology of the microservices

The **'articles'** and **'web-api'** micro-service are based purly only on open source components:

* [OpenJ9 0.12.1](https://projects.eclipse.org/projects/technology.openj9/releases/0.12.1/review)
* OpenJDK 8u202-b08 from AdoptOpenJDK
* [Open Liberty 18.0.0.4](https://openliberty.io/downloads/)
* [MicroProfile 2.1](https://projects.eclipse.org/projects/technology.microprofile/releases/microprofile-2.1)

To ensure that distributed tracing it supported [zipkintracer](https://github.com/openzipkin/zipkin-ruby) is copied onto the image.



### Dockerfile to create the articles container

Now we take a look info the [Dockerfile](../articles-java-jee/Dockerfile.nojava) to create the articles service. The inside the Dockerfile we use multiple stages to build the  container image. 
The reason for the two stages we have the objective to be independed on local environment settings, when we create the container. With this concept we don't have to ensure that Java and Maven (or wrong versions) installed.

* Build environment container

Here we create our **build environment container** based on the maven 3.5 image from the [dockerhub](https://hub.docker.com/_/maven/).

```
FROM maven:3.5-jdk-8 as BUILD
COPY src /usr/src/app/src
COPY pom.xml /usr/src/app
```

Let's build the **articles.war** inside the container image, using the maven command **mvn -f pom.xml clean package** .

```
RUN mvn -f /usr/src/app/pom.xml clean package
```

* Production container

Here we create the **production container** based on the **openliberty** with **microProfile2**.
Then **zipkintracer** will be installed.

```
FROM openliberty/open-liberty:microProfile2-java8-openj9
ADD liberty-opentracing-zipkintracer-1.2-sample.zip /
RUN unzip liberty-opentracing-zipkintracer-1.2-sample.zip -d /opt/ol/wlp/usr/ \
 && rm liberty-opentracing-zipkintracer-1.2-sample.zip
COPY liberty/server.xml /config/
```

Now it is time to copy the build result form our  **build environment container** into the correct place inside the **production container**.

```
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


