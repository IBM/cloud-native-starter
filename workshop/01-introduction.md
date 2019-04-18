# Introduction

As part of this workshop, we will see how to develop cloud-native microservices using Jakarta EE and MicroProfile, which are deployed using Docker CLI, Kubernetes, and Istio.
We'll examine the basics of modern cloud native Java micro-services development with container, rest APIS, traffic management, and resiliency.


## The "Cloud Native Starter" application

The "Cloud Native Starter" application TBD.

TODO: Use customized architecture diagram for the workshop.

![architecture](images/architecture.png)

### Microservice*

**Articles microservice**

The objective of this microservice is to add and get artical information from a database. At moment the implementation is just creating sample data values.

The service is organized in following packages:

* apis
* business
* data

**Web-api microservice**

The objective of this microservice is to combine information from different services and provide that information to be consumned using a REST api in the vue webapp. In this case the information of **articals** and **authors** are combined to be consunmed by the webapp.

This microservice also organized in following packages:

* apis
* business
* data

# Technologies

## MicroProfile

For cloud-native applications Kubernetes and Istio deliver a lot of important functionality out of the box, for example to ensure **resiliency** and **scalability**. This functionality works generically for microservices, no matter in which language they have been implemented and independent from the application logic.

Some cloud-native functionality however cannot be handled by Kubernetes and Istio, since it needs to be handled in the business logic of the microservices, for example application specific failover functionality, metrics and fine-grained authorization.

That’s why we use Eclipse MicroProfile, which is an extension to JavaEE to build microservices-based architectures and a great programming model for Istio. In addition to the application specific logic that Istio cannot handle, it also comes with convenience functionality that you typically need when developing microservices, for example invoking REST APIs and implementing REST APIs including their documentation.

[source](http://heidloff.net/article/dockerizing-container-java-microprofile)

## Getting started

To get started, clone the Git repository and use the projects that are provided inside:





