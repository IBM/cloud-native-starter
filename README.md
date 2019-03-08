# Cloud Native Starter for Java and Node.js

This project contains sample code that shows how to build cloud-native applications with Java and Node.js and deploy them to Kubernetes and Istio.

The project showcases the following functionality:

* Chained invocations
* Traffic management (A/B, canary)
* Polyglot Java and JavaScript microservices
* Circuit breaker and fallbacks
* Distributed logging
* Metrics
* Authentication and authorization
* APIs incl. documentation
* Configuration
* Deployments (helm, yaml)

This diagram shows the key components:

![alt text](images/architecture.png "architecture diagram")

The next screenshot shows the web application. More screenshots are in the [images](images) folder.

![alt text](images/web-app-1.png "web app")


### Work in Progress

Stay tuned for more ...


### Local Environment Setup

Follow these [instructions](LocalEnvironment.md) to set up the local environment.


### Deployment

Deploy and redeploy:

```
$ scripts/check-prerequisites.sh
$ scripts/deploy-articles-java-jee.sh
$ scripts/deploy-web-api-java-jee.sh
$ scripts/deploy-authors-nodejs.sh
$ scripts/deploy-web-app-vuejs.sh
```


### Run the Demo

After installing the web-api, you get an URL like http://192.168.99.100:31380/openapi/ui/ in the terminal to open the OpenAPI explorer. Note: The port '31380' is always the same one since Istio Ingress is used. The IP address is the IP of your Minikube cluster.

After installing the web-app, you get an URL like http://192.168.99.100:31696 in the terminal to open the web application.

*Traffic Routing*

In order to demonstrate traffic routing you can run this command. Every other web-api API request to read articles will now return 10 instead of 5 articles.

```
$ scripts/deploy-web-api-java-jee-v2.sh
```

*Resiliency*

In order to demonstrate resiliency you can run the following command to delete the authors service:

```
$ scripts/delete-authors-nodejs.sh
```

In the next step delete the articles service:

```
$ scripts/delete-web-api-java-jee.sh
```


### Documentation

Here is a series of blog entries about this project:

* [Setup of a Local Kubernetes and Istio Dev Environment](http://heidloff.net/article/setup-local-development-kubernetes-istio)
* [Debugging Microservices running in Kubernetes](http://heidloff.net/article/debugging-microservices-kubernetes)
* [Dockerizing Java MicroProfile Applications](http://heidloff.net/article/dockerizing-container-java-microprofile)
* Traffic Management (functionality: almost done / blog: to be done)
* APIs including documentation (functionality: done / blog: to be done)
* Invoking REST APIs (functionality: done / blog: to be done)
* Distributed logging (functionality: almost done / blog: to be done)
* Monitoring and metrics (functionality: to be done / blog: to be done)
* Authentication and authorization (functionality: to be done / blog: to be done)
* Configuration (functionality: almost done / blog: to be done)

Here is more information about Microservices, MicroProfile and Istio:

* [MicroProfile, the microservice programming model made for Istio](https://www.eclipse.org/community/eclipse_newsletter/2018/september/MicroProfile_istio.php)
* [Migrating Java Microservices to MicroProfile – Epilogue](https://www.ibm.com/blogs/bluemix/2019/02/migrating-java-microservices-to-microprofile-epilogue/)
* Video: [Istio Platform vs Spring and MicroProfile frameworks](https://www.youtube.com/watch?v=lFj8X0VLOFQ)
* Video: [Java EE, Jakarta EE, MicroProfile, Or Maybe All Of Them?](https://www.youtube.com/watch?v=Jemx1BrB45Y)
* Video: [Istio: Canaries and Kubernetes, Microservices and Service Mesh](https://www.youtube.com/watch?v=YQLOcjvbo9s)