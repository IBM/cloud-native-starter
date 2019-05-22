# Simplest possible Microservice in Java

This folder contains a Java implementation of the authors service.

The microservice is kept as simple as possible, so that it can be used as a starting point for other services. It contains the following functionality:

* Image with open source Java stack: [Dockerfile](Dockerfile)
* Maven project: [pom.xml](pom.xml)
* Server configuration: [server.xml](liberty/server.xml)
* Health endpoint: [HealthEndpoint.java](src/main/java/com/ibm/authors/HealthEndpoint.java)
* Sample GET endpoint: [AuthorsApplication.java](src/main/java/com/ibm/authors/AuthorsApplication.java), [GetAuthor.java](src/main/java/com/ibm/authors/GetAuthor.java) and [Author.java](src/main/java/com/ibm/authors/Author.java)
* Kubernetes yaml files: [kubernetes-deployment.yaml](deployment/kubernetes-deployment.yaml) and [kubernetes-service.yaml](deployment/kubernetes-service.yaml)


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
$ kubectl apply -f deployment/kubernetes-deployment.yaml
$ kubectl apply -f deployment/kubernetes-service.yaml
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