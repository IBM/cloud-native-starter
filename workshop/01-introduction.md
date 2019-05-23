[home](README.md)
# Introduction
****** **UNDER CONSTRUCTION** ******

In this hands-on workshop, we will see, how to develop cloud-native microservices using Jakarta EE and MicroProfile.

When building cloud-native applications, developers are challenged to figure out how to address topics like **building and deploying Containers**, **traffic routing**, **resiliency** and **defining and exposing REST APIs**. Fortunately, most of these new challenges are handled by the orchestration platform Kubernetes and the service mesh Istio. This functionality works generically for microservices, regardless of the language they are implemented in and without changes to the application logic.

However, **some functionality can not be covered by orchestration platforms** and service meshes. Instead it must be handled in the business logic of the microservices, for example application specific failover functionality, metrics, and fine-grained authorizations.

Java developers can leverage **Eclipse MicroProfile** to implement this functionality. MicroProfile is an extension to Java EE (Enterprise Edition) to build microservices-based architectures and it complements Kubernetes and Istio capabilities. In addition to the application specific logic which Kubernetes and Istio cannot handle, it also comes with convenience functionality that you typically need when developing microservices, for example mechanisms to invoke REST APIs and functionality to implement REST APIs including their documentation.

---

## 1. The "Cloud Native Starter (CNS)" application

With the **"Cloud Native Starter"** application you can **show**, **add** and **remove** articles with authors information. The application is built on microservices with one frontend web application.

![architecture](images/architecture.png)

* **Web app** service provides a [Vue.js](https://vuejs.org/) web application to the browser. It's based on [Nginx](https://nginx.org/en/).
* **Web-API** is accessed by the Vue app and provides a list of blog articles and their authors
* **Articles** holds the list of blog articles
* **Authors** holds the blog authors details (blog URL and Twitter handle)

The **"Cloud Native Starter"** application follows these design principles:

* **Leverage platforms as much as possible – do as little as possible in language-specific frameworks**

> The advantage of using Kubernetes and Istio for features like traffic management is, that these features are language agnostic. Cloud-native applications can be, and often are, polyglot. This allows developers to pick the best possible languages for the specific tasks.

* **Use open-source components for the core services of the application only**

> Pretty much everyone loves open source. For example the Java stack leverages [OpenJ9](https://www.eclipse.org/openj9/), [OpenJDK](https://openjdk.java.net/) from [AdoptOpenJDK](https://adoptopenjdk.net/), [OpenLiberty](https://openliberty.io/) and [MicroProfile](https://microprofile.io/). [Kubernetes](https://kubernetes.io/) and [Istio](https://istio.io/) are obviously open source projects as well.

* **Make the first-time experience as simple as possible**

> The example application shows several features working together, see below for details. There are also scripts to deploy services very easily, basically one script per service, similar to the **‘cf push’** experience for Cloud Foundry applications.

* **Be able to run the application in different environments**

> Fortunately, this is one of the main advantages of Kubernetes since you can run workloads on-premises, hybrid or public cloud infrastructures. The repo has instructions how to deploy the application to Minikube and to the managed IBM Cloud Kubernetes Service.

---

## 2. **Microservices and Web app**

These are the responsibilities of the different microservices and the Web app. The implementation organization of these services do focus to follow the clean architecture software design **philosophy**.

---

### 2.1 **Web app**

The Web app is the UI to display the given entries and is built with **VUE**.
Here you can see a picture of the **Web app** UI.

![cns-introduction-01](images/cns-introduction-01.png)

---

### 2.2 ****Web API****

The objective of this microservice is to combine the information from the **articals** and the **Authors** microservice. 

The **Web API** is business related to be consumned by the **VUE** **Web app**. So the Web app can use just **one** REST API and doesn't need more APIs. The **Web API** service implements the **BFF** (backend for frontend pattern). 

The following image contains a sample instance of the **Web API** using the **Open API explorer**.

![cns-container-web-api-v1-04.png](images/cns-container-web-api-v1-04.png)

---

### 2.3 **Articles microservice**

The objective of this microservice is to **add** and **get** article information from a database. In this workshop we will use the default implementation, which just creates sample data values.

In the image blow you can see a sample instance of the Articles,  using the **Open API explorer**.

![cns-container-articels-service-03](images/cns-container-articels-service-03.png)

---

### 2.4 **Authors microservice**

The objective of this microservice is to **get** author information from a database and is built on Node.JS.
In this workshop we will use the default implementation, which just creates sample data values.

Sample curl command to get a author from the **Authors** microservice.

```sh
$ curl http://159.122.172.162:31078/api/v1/getauthor?name=Niklas%20Heidloff
$ {"name":"Niklas Heidloff","twitter":"@nheidloff","blog":"http://heidloff.net"}
```

## 3 Technologies

### 3.1 Technologies of the microservices

The **'Articles'** and '**Web API**' microservices are based purly on open source components:

* [OpenJ9 0.12.1](https://projects.eclipse.org/projects/technology.openj9/releases/0.12.1/review)
* OpenJDK 8u202-b08 from AdoptOpenJDK
* [Open Liberty 18.0.0.4](https://openliberty.io/downloads/)
* [MicroProfile 2.1](https://projects.eclipse.org/projects/technology.microprofile/releases/microprofile-2.1)

To ensure that distributed tracing it supported [zipkintracer](https://github.com/openzipkin/zipkin-ruby) is copied onto the image.  


_Note:_ Distributed tracing is not in scope of current workshop material.

---

### 3.2 MicroProfile

For cloud-native applications Kubernetes and Istio deliver a lot of important functionality out of the box, for example to ensure **resiliency** and **scalability**. This functionality works generically for microservices, no matter in which language they have been implemented and independent from the application logic.

Some cloud-native functionality however cannot be handled by Kubernetes and Istio, since it needs to be handled in the business logic of the microservices, for example application specific failover functionality, metrics and fine-grained authorization.

That’s why we use **Eclipse MicroProfile**, which is an extension to JavaEE to build microservices-based architectures and a great programming model for Istio. In addition to the application specific logic that Istio cannot handle, it also comes with convenience functionality that you typically need when developing microservices, for example invoking REST APIs and implementing REST APIs including their documentation.

Now, we've finished the **introduction**.
Let's get started with the [Lab - Building and deploying Containers](02-container.md).

---

Resources:

* ['Dockerizing Java MicroProfile Applications'](http://heidloff.net/article/dockerizing-container-java-microprofile)
* ['Example Java App running in the Cloud via Kubernetes'](http://heidloff.net/article/example-java-app-cloud-kubernetes)





