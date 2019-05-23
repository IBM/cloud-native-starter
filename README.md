## Cloud Native Starter for Java/Jakarta EE based Microservices on Kubernetes and Istio

This project contains sample code that demonstrates how to get started with cloud-native applications and microservice based architectures. 

The project focusses on how to build microservices with Java EE and the open source technologies [Eclipse MicroProfile](https://microprofile.io/), [Eclipse OpenJ9](https://www.eclipse.org/openj9/), [AdoptOpenJDK](https://adoptopenjdk.net/) and [Open Liberty](https://openliberty.io/).

The microservices can be easily deployed on Kubernetes environments running [Istio](https://istio.io/) like [Minikube](https://kubernetes.io/docs/setup/minikube/) or the [IBM Cloud Kubernetes Service](https://www.ibm.com/cloud/container-service).

The project showcases the following functionality:

* REST APIs implementations incl. documentation
* REST API invocations
* Traffic management
* Resiliency via fallbacks and circuit breakers
* Authentication and authorization
* Distributed tracing and logging
* Monitoring and metrics
* Persistence for Java microservices via JPA

This diagram shows the key components:

<kbd><img src="images/architecture-2.png" /></kbd>

The next screenshot shows the web application. More screenshots are in the [images](images) folder.

<kbd><img src="images/web-app.png" /></kbd>


### Demos

This project demonstrates several Java EE and Istio key functionality.

* [Containerized Java EE Microservices](documentation/DemoJavaImage.md)
* [Exposing REST APIs](documentation/DemoExposeRESTAPIs.md)
* [Consuming REST APIs](documentation/DemoConsumeRESTAPIs.md)
* [Traffic Routing](documentation/DemoTrafficRouting.md)
* [Resiliency](documentation/DemoResiliency.md)
* [Authentication and Authorization](documentation/DemoAuthentication.md)
* [Metrics](documentation/DemoMetrics.md)
* [Health Checks](documentation/DemoHealthCheck.md)
* [Configuration](documentation/DemoConfiguration.md)
* [Distributed Logging and Monitoring](documentation/DemoDistributedLoggingMonitoring.md)
* [Persistence with Java Persistence API (JPA)](documentation/DemoJPA.md)


### Setup

The sample application can be run locally on Minikube or on the IBM Cloud. The following instructions describe how to install everything locally.

If you would like to run the cloud native starter application on IBM Cloud Kubernetes Service, follow these [instructions](documentation/IKSDeployment.md). 

Before the microservices can be installed, make sure you've set up Minikube and Istio correctly or follow these [instructions](documentation/SetupLocalEnvironment.md) to set up Minikube and Istio from scratch. This should not take longer than 30 minutes.

The microservices can be installed via scripts. In addition to Minikube and Istio you need the following tools to be installed.

Prerequisites:

* [git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git)
* [curl](https://curl.haxx.se/download.html)
* [docker](https://docs.docker.com/install/)
* [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/)

Deploy (and redeploy):

```
$ git clone https://github.com/nheidloff/cloud-native-starter.git
$ cd cloud-native-starter
$ scripts/check-prerequisites.sh
$ scripts/deploy-articles-java-jee.sh
$ scripts/deploy-web-api-java-jee.sh
$ scripts/deploy-authors-nodejs.sh
$ scripts/deploy-web-app-vuejs.sh
$ scripts/deploy-istio-ingress-v1.sh
$ scripts/show-urls.sh
```

After running the scripts above, you will get a list of all URLs in the terminal.

<kbd><img src="images/urls.png" /></kbd>

Example URL to open the web app: http://192.168.99.100:31380

Example API endpoint: http://192.168.99.100:31380/web-api/v1/getmultiple

### Cleanup

Run the following command to delete all cloud-native-starter components from Istio.

```
$ scripts/delete-all.sh
```

You can also delete single components:

```
$ scripts/delete-articles-java-jee.sh
$ scripts/delete-articles-java-jee-quarkus.sh
$ scripts/delete-web-api-java-jee.sh
$ scripts/delete-authors-nodejs.sh
$ scripts/delete-web-app-vuejs.sh
$ scripts/delete-istio-ingress.sh
```

### Authors

* [Niklas Heidloff](https://twitter.com/nheidloff)
* [Harald Uebele](https://twitter.com/harald_u)


### Documentation

The following [slides](https://github.com/nheidloff/cloud-native-starter/blob/master/documentation/FirstCloudNativeApplicationsJava.pdf) summarize this repo:

[![Video](images/slides.png)](documentation/FirstCloudNativeApplicationsJava.pdf)

Here is a series of blog entries about this project:

* [Project Description and Design Principles](http://heidloff.net/article/example-java-app-cloud-kubernetes)
* Slides: [How to develop your first cloud-native Applications with Java](https://github.com/nheidloff/cloud-native-starter/blob/master/documentation/FirstCloudNativeApplicationsJava.pdf) and four [recorded demos](https://www.youtube.com/watch?v=IVd8pxDP8p8)
* [Setup of a Local Kubernetes and Istio Dev Environment](http://heidloff.net/article/setup-local-development-kubernetes-istio)
* [Debugging Microservices running in Kubernetes](http://heidloff.net/article/debugging-microservices-kubernetes)
* [Dockerizing Java MicroProfile Applications](http://heidloff.net/article/dockerizing-container-java-microprofile)
* [Developing resilient Microservices with Istio and MicroProfile](http://heidloff.net/article/resiliency-microservice-microprofile-java-istio)
* [Using Quarkus to run Java Apps on Kubernetes](http://heidloff.net/article/quarkus-javaee-microprofile-kubernetes)
* [Managing Microservices Traffic with Istio](https://haralduebele.blog/2019/03/11/managing-microservices-traffic-with-istio/)
* [Web Application to demo Traffic Management with Istio](http://heidloff.net/article/sample-app-manage-microservices-traffic-istio)
* [Implementing and documenting REST APIs with JavaEE](http://heidloff.net/article/rest-apis-microprofile-javaee-jaxrs)
* [Invoking REST APIs from Java Microservices](http://heidloff.net/invoke-rest-apis-java-microprofile-microservice)
* [Prometheus Metrics for MicroProfile Microservices in Istio](http://heidloff.net/article/prometheus-metrics-microprofile-microservices-istio/)
* [Moving from Minikube to IBM Cloud Kubernetes Service](https://haralduebele.blog/2019/04/04/moving-from-minikube-to-ibm-cloud-kubernetes-service/)
* [Distributed logging with LogDNA and Monitoring with Sysdig](https://haralduebele.blog/2019/04/08/whats-going-on-in-my-cluster/)
* [Implementing Health Checks with MicroProfile and Istio](http://heidloff.net/article/implementing-health-checks-microprofile-istio)
* [Configuring Microservices with MicroProfile and Kubernetes](http://heidloff.net/article/configuring-java-microservices-microprofile-kubernetes/)
* [Authenticating Web Users with OpenID and JWT](http://heidloff.net/article/authenticating-web-users-openid-connect-jwt/)
* [Authorization in Cloud-Native Applications via OpenID and Istio](http://heidloff.net/article/authentication-authorization-openid-connect-istio)
* [Authorization in Microservices with MicroProfile](http://heidloff.net/article/authorization-microservices-java-microprofile/)
* [Persistence for Java Microservices in Kubernetes via JPA](http://heidloff.net/article/persistence-java-microservices-kubernetes-jpa/)

Here is more information about Microservices, MicroProfile and Istio:

* [MicroProfile, the microservice programming model made for Istio](https://www.eclipse.org/community/eclipse_newsletter/2018/september/MicroProfile_istio.php)
* [Migrating Java Microservices to MicroProfile – Epilogue](https://www.ibm.com/blogs/bluemix/2019/02/migrating-java-microservices-to-microprofile-epilogue/)
* Video: [Istio Platform vs Spring and MicroProfile frameworks](https://www.youtube.com/watch?v=lFj8X0VLOFQ)
* Video: [Java EE, Jakarta EE, MicroProfile, Or Maybe All Of Them?](https://www.youtube.com/watch?v=Jemx1BrB45Y)
* Video: [Istio: Canaries and Kubernetes, Microservices and Service Mesh](https://www.youtube.com/watch?v=YQLOcjvbo9s)
