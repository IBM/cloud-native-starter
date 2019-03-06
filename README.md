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
```


### Run the Demo

After installing the web-api, you get an URL like http://192.168.99.100:31695/openapi/ui/ in the terminal that you can use to open the OpenAPI explorer.


### Documentation

Here is a series of blog entries about this project:

* [Setup of a Local Kubernetes and Istio Dev Environment](http://heidloff.net/article/setup-local-development-kubernetes-istio)
* [Debugging Microservices running in Kubernetes](http://heidloff.net/article/debugging-microservices-kubernetes)
* [Dockerizing Java MicroProfile Applications](http://heidloff.net/article/dockerizing-container-java-microprofile)
* to be done: Traffic Management
* to be done: APIs including documentation
* to be done: Invoking REST APIs
* to be done: Distributed logging
* to be done: Monitoring and metrics
* to be done: Authentication and authorization
* to be done: Configuration

Here is more information about Microservices, MicroProfile and Istio:

* [MicroProfile, the microservice programming model made for Istio](https://www.eclipse.org/community/eclipse_newsletter/2018/september/MicroProfile_istio.php)
* [Migrating Java Microservices to MicroProfile – Epilogue](https://www.ibm.com/blogs/bluemix/2019/02/migrating-java-microservices-to-microprofile-epilogue/)
* Video: [Istio Platform vs Spring and MicroProfile frameworks](https://www.youtube.com/watch?v=lFj8X0VLOFQ)
* Video: [Java EE, Jakarta EE, MicroProfile, Or Maybe All Of Them?](https://www.youtube.com/watch?v=Jemx1BrB45Y)
* Video: [Istio: Canaries and Kubernetes, Microservices and Service Mesh](https://www.youtube.com/watch?v=YQLOcjvbo9s)