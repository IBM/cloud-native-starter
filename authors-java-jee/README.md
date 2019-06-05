# Simplest possible Microservice in Java

This folder contains a microservice which is kept as simple as possible, so that it can be used as a starting point for other microservices. It contains the following functionality:

* Image with OpenJ9, OpenJDK, Open Liberty and MicroProfile: [Dockerfile](Dockerfile)
* Maven project: [pom.xml](pom.xml)
* Open Liberty server configuration: [server.xml](liberty/server.xml)
* Health endpoint: [HealthEndpoint.java](src/main/java/com/ibm/authors/HealthEndpoint.java)
* Kubernetes yaml files: [deployment.yaml](deployment/deployment.yaml) and [service.yaml](deployment/service.yaml)
* Sample REST GET endpoint: [AuthorsApplication.java](src/main/java/com/ibm/authors/AuthorsApplication.java), [GetAuthor.java](src/main/java/com/ibm/authors/GetAuthor.java) and [Author.java](src/main/java/com/ibm/authors/Author.java)

The microservice is a Java version of the Authors service in the 'authors-nodejs' folder. If you want to use this code for your own microservice, remove the three Java files for the REST GET endpoint and rename the service in the pom.xml file and the yaml files.

## Deployment Options

The microservice can be run in different environments:

* [Docker](#run-in-docker)
* [Minikube](#run-in-minikube)
* [IBM Cloud Kubernetes Service](#run-in-ibm-cloud-kubernetes-service)
* [Minishift](#run-in-minishift)

## Run in Docker

```
$ cd authors-java-jee
$ mvn package
$ docker build -t authors .
$ docker run -i --rm -p 3000:3000 authors
$ open http://localhost:3000/openapi/ui/
```

## Run in Minikube

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


## Run in IBM Cloud Kubernetes Service

To be done - see [workshop](../workshop/06-java-development.md#5kubernetes-deployment-configuration) for now


## Run in Minishift

Prerequisites:

* Install [Minishift](https://github.com/minishift/minishift) v1.34.0 (OKD 3.11.0)
* Install [oc](https://docs.okd.io/latest/cli_reference/get_started_cli.html) CLI

Build and push image:

```
$ cd authors-java-jee
$ mvn package
$ eval $(minishift docker-env)
$ oc login -u developer -p developer
$ oc new-project cloud-native-starter
$ docker login -u developer -p $(oc whoami -t) $(minishift openshift registry)
$ docker build -f DockerfileNoBuild -t authors:kubectl .
$ docker tag authors:kubectl $(minishift openshift registry)/cloud-native-starter/authors:kubectl
$ docker push $(minishift openshift registry)/cloud-native-starter/authors:kubectl
$ oc get istag
```

Deploy microservice:

```
$ cd authors-java-jee/deployment
$ sed "s+<namespace>+cloud-native-starter+g" deployment-template.yaml > deployment-template.yaml.1
$ minishiftregistryip=$(minishift openshift registry)
$ sed "s+<ip:port>+$minishiftregistryip+g" deployment-template.yaml.1 > deployment-template.yaml.2
$ sed "s+<tag>+kubectl+g" deployment-template.yaml.2 > deployment-minishift.yaml
$ kubectl apply -f deployment-minishift.yaml
$ kubectl apply -f service.yaml
$ rm deployment-template.yaml.1
$ rm deployment-template.yaml.2
$ oc expose svc/authors
$ curl -X GET "http://authors-cloud-native-starter.$(minishift ip).nip.io/api/v1/getauthor?name=Niklas%20Heidloff" -H "accept: application/json"
$ open http://authors-cloud-native-starter.$(minishift ip).nip.io/openapi/ui/
$ open https://$(minishift ip):8443
```

Rather than building the image locally and deploying the app via kubectl and yaml files, Minishift can build and deploy the microservice:

```
$ oc new-project server-side-build
$ oc new-app https://github.com/nheidloff/cloud-native-starter --context-dir=authors-java-jee
$ oc expose svc/server-side-build
$ curl -X GET "http://cloud-native-starter-server-side-build.$(minishift ip).nip.io/api/v1/getauthor?name=Niklas%20Heidloff" -H "accept: application/json"
```