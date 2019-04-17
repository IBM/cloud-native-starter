# Introduction

As part of this workshop, we will see how to develop cloud-native microservices using Jakarta EE and MicroProfile, which are deployed using Docker CLI, Kubernetes, and Istio.
We'll examine the basics of modern cloud native Java micro-services development with container, rest APIS, traffic management, and resiliency.


## Example application

Our microservices example consists of TBD.

![cns-basic-setup-01](images/cns-basic-setup-01.png)

### Services

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




## Getting started

To get started, clone the Git repository and use the projects that are provided inside:





