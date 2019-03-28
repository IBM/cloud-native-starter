# Cloud Native Starter for Java and Node.js

This project contains sample code that shows how to build cloud-native applications with JavaEE and Node.js and deploy them to Kubernetes and Istio.

The project showcases the following functionality:

* JavaEE (with MicroProfile) and Node.js microservices
* Distributed tracing
* Traffic management
* Resiliency via fallbacks and circuit breakers
* REST APIs implementations incl. documentation
* REST API invocations
* Distributed logging
* Metrics
* Authentication and authorization
* Configuration
* Deployments

This diagram shows the key components:

<kbd><img src="images/architecture.png" /></kbd>

The next screenshot shows the web application. More screenshots are in the [images](images) folder.

<kbd><img src="images/web-app.png" /></kbd>

### Local Environment Setup

Follow these [instructions](LocalEnvironment.md) to set up the local environment with Minikube and Istio. This should not take longer than 30 minutes.


### Deployment

Prerequisites:

* [git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git) 
* [curl](https://curl.haxx.se/download.html)
* [docker](https://docs.docker.com/install/)
* [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/)
* [minikube](LocalEnvironment.md) and Istio and Kiali

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


### Demo - Web Application

After running the scripts above, you will get a list of all URLs in the terminal.

<kbd><img src="images/urls.png" /></kbd>

Example URL to open the web app: http://192.168.99.100:31380

Example API endpoint: http://192.168.99.100:31380/web-api/v1/getmultiple


### Demo - Traffic Routing

In order to demonstrate traffic routing you can run the following commands. 20 % of the web-api API request to read articles will now return 10 instead of 5 articles which is version 2. 80 % of the requests are still showing only 5 articles which is version 1. This distribution is set in `istio/istio-ingress-service-web-api-v1-v2-80-20.yaml` (weight: 80 vs. weight: 20).

```
$ scripts/deploy-web-api-java-jee-v2.sh
$ scripts/deploy-istio-ingress-v1-v2.sh
```

<kbd><img src="images/traffic-management-1.png" /></kbd>

### Demo - Resiliency

In order to demonstrate resiliency you can run the following command to delete the authors service:

```
$ scripts/delete-authors-nodejs.sh
```

In the next step delete the articles service:

```
$ scripts/delete-web-api-java-jee.sh
```

### Demo - Metrics

The web-api service [produces](https://github.com/nheidloff/cloud-native-starter/blob/master/web-api-java-jee/src/main/java/com/ibm/webapi/apis/GetArticles.java) some application specific metrics. 

Run 'scripts/show-urls.sh' to get the URL to display the [unformatted](images/prometheus-3.png) metrics of this microservice (for example http://192.168.99.100:31223/metrics/application) as well as the URL to generate load (for example http://192.168.99.100:31223/web-api/v1/getmultiple).

In order to display the metrics with the Prometheus UI, Prometheus needs to be configured first:

```
$ scripts/configure-prometheus.sh
```

After this wait until the Prometheus pod has been restarted. Then run the command to forward the Prometheus port which is displayed as result of 'scripts/configure-prometheus.sh'.

The metrics are displayed in the Prometheus UI (http://localhost:9090) when you search for 'web-api' or 'articles'.

For example the [amount](images/prometheus-1.png) of times /web-api/v1/getmultiple has been invoked can be displayed as well as the [duration](images/prometheus-2.png) of these requests.

### Cleanup

Run these commands to delete the cloud native starter components:

```
$ scripts/delete-articles-java-jee.sh
$ scripts/delete-web-api-java-jee.sh
$ scripts/delete-authors-nodejs.sh
$ scripts/delete-web-app-vuejs.sh
$ scripts/delete-istio-ingress.sh
```


### Documentation

Here is a series of blog entries about this project:

* [Setup of a Local Kubernetes and Istio Dev Environment](http://heidloff.net/article/setup-local-development-kubernetes-istio)
* [Debugging Microservices running in Kubernetes](http://heidloff.net/article/debugging-microservices-kubernetes)
* [Dockerizing Java MicroProfile Applications](http://heidloff.net/article/dockerizing-container-java-microprofile)
* [Developing resilient Microservices with Istio and MicroProfile](http://heidloff.net/article/resiliency-microservice-microprofile-java-istio)
* [Using Quarkus to run Java Apps on Kubernetes](http://heidloff.net/article/quarkus-javaee-microprofile-kubernetes)
* [Managing Microservices Traffic with Istio](https://haralduebele.blog/2019/03/11/managing-microservices-traffic-with-istio/)
* [Web Application to demo Traffic Management with Istio](http://heidloff.net/article/sample-app-manage-microservices-traffic-istio)
* [Implementing and documenting REST APIs with JavaEE](http://heidloff.net/article/rest-apis-microprofile-javaee-jaxrs)
* [Invoking REST APIs from Java Microservices](http://heidloff.net/invoke-rest-apis-java-microprofile-microservice)
* Prometheus Metrics for MicroProfile Microservices in Istio
* Deployment to IBM Cloud
* Distributed logging with IBM Log Analysis with LogDNA
* Monitoring with IBM Cloud Monitoring with Sysdig
* Istio Healthchecks for MicroProfile Microservices 
* Sample Quarkus Microservices with and without GraalVM
* cf push-like Deployments of Microservices via Scripts
* Template to create new Java EE Microservice
* Clean-ish Architecture for Java EE Microservices
* Configuration of MicroProfile Microservices in Istio
* Authentication and Authorization
* SQL PersistenceSQL via JPA and JDBC
* Lightweight API Management
* Sample Microservices with Spring and Micronaut

Here is more information about Microservices, MicroProfile and Istio:

* [MicroProfile, the microservice programming model made for Istio](https://www.eclipse.org/community/eclipse_newsletter/2018/september/MicroProfile_istio.php)
* [Migrating Java Microservices to MicroProfile – Epilogue](https://www.ibm.com/blogs/bluemix/2019/02/migrating-java-microservices-to-microprofile-epilogue/)
* Video: [Istio Platform vs Spring and MicroProfile frameworks](https://www.youtube.com/watch?v=lFj8X0VLOFQ)
* Video: [Java EE, Jakarta EE, MicroProfile, Or Maybe All Of Them?](https://www.youtube.com/watch?v=Jemx1BrB45Y)
* Video: [Istio: Canaries and Kubernetes, Microservices and Service Mesh](https://www.youtube.com/watch?v=YQLOcjvbo9s)