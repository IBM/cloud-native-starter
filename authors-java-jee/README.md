# Simplest possible Microservice in Java

This folder contains a microservice which is kept as simple as possible, so that it can be used as a starting point for other microservices. It contains the following functionality:

* Image with OpenJ9, OpenJDK, Open Liberty and MicroProfile: [Dockerfile](Dockerfile)
* Maven project: [pom.xml](pom.xml)
* Open Liberty server configuration: [server.xml](liberty/server.xml)
* Health endpoint: [HealthEndpoint.java](src/main/java/com/ibm/authors/HealthEndpoint.java)
* Kubernetes yaml files: [deployment.yaml](deployment/deployment.yaml) and [service.yaml](deployment/service.yaml)
* Sample REST GET endpoint: [AuthorsApplication.java](src/main/java/com/ibm/authors/AuthorsApplication.java), [GetAuthor.java](src/main/java/com/ibm/authors/GetAuthor.java) and [Author.java](src/main/java/com/ibm/authors/Author.java)

The microservice is a Java version of the Authors service in the 'authors-nodejs' folder. If you want to use this code for your own microservice, remove the three Java files for the REST GET endpoint and rename the service in the pom.xml file and the yaml files.


**Run final version with Docker**

```
$ cd authors-java-jee
$ mvn package
$ docker build -t authors .
$ docker run -i --rm -p 3000:3000 authors
$ open http://localhost:3000/openapi/ui/
```

**Run final version with Minikube**

```
$ cd authors-java-jee
$ mvn package
$ eval $(minikube docker-env)
$ docker build -t authors:1 .
$ kubectl apply -f deployment/deployment.yaml
$ kubectl apply -f deployment/service.yaml
$ minikubeip=$(minikube ip)
$ nodeport=$(kubectl get svc authors --ignore-not-found --output 'jsonpath={.spec.ports[*].nodePort}')
$ open http://${minikubeip}:${nodeport}/openapi/ui/
```

**Final test in Minikube**

First delete all services:

```
$ cd cloud-native-starter
$ scripts/delete-all.sh
```

Next deploy the Java based authors service as documented above.

Next deploy the articles and web-api services:

```
$ cd cloud-native-starter
$ scripts/deploy-articles-java-jee.sh
$ scripts/deploy-web-api-java-jee.sh
$ scripts/show-urls.sh
```

Invoke /getmultiple, for example 'http://192.168.99.100:31380/web-api/v1/getmultiple'.