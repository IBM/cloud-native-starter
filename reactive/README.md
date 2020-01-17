## Reactive Java Microservices 

This part of the cloud-native-starter project describes how to implement reactive microservices with the following technologies:

* [Quarkus](https://quarkus.io/)
* [Eclipse MicroProfile](https://microprofile.io/)
* [Eclipse Vert.x](https://vertx.io/)
* [Eclipse OpenJ9](https://www.eclipse.org/openj9/)
* [Kubernetes](https://kubernetes.io/)
* [Minikube](https://minikube.sigs.k8s.io/)
* [Apache Kafka](https://kafka.apache.org/)
* [PostgreSQL](https://www.postgresql.org/)

This diagram desribes the high level architecture.

<kbd><img src="documentation/architecture-small.png" /></kbd>

### Demonstration 1: Web application is refreshed automatically when new articles are created

Articles can be created via REST API. The web application receives a notification and adds the new article to the page.

<kbd><img src="documentation/demo-1-video-small.gif" /></kbd>

This diagram explains the flow.

<kbd><img src="documentation/demo-1-small.png" /></kbd>

### Demonstration 2: Reactive REST Endpoint '/articles' in web-api service

The project contains the endpoint '/articles' of the web-api service in two different versions, one uses imperative code, the other one reactive code.

The reactive stack of this sample provides responsive times that take less than half of the time compared to the imperative stack: Reactive: 793 ms - Imperative: 1956 ms.

Read the [documentation](documentation/LoadTests.md) for details.

This diagram explains the flow.

<kbd><img src="documentation/demo-2-small.png" /></kbd>

This is the result of the imperative version after 30000 invocations:

<kbd><img src="documentation/load-100x300-v1-summary.png" /></kbd>

This is the result of the reactive version after 30000 invocations:

<kbd><img src="documentation/load-100x300-v2-summary.png" /></kbd>

### Functionality

At this point the project demonstrates this functionality:

* Sending events from a microservice to a web application via Server Sent Events
* Sending in-memory messages via MicroProfile
* Sending in-memory messages via Vertx event bus
* Sending and receiving Kafka messages via MicroProfile
* Sending Kafka messages via Kafka API
* Reactive REST endpoints via CompletionStage
* Exception handling in chained reactive invocations
* Timeouts via CompletableFuture
* Resiliency of reactive microservices
* Reactive REST invocations via Vertx Axle Web Client
* Reactive REST invocations via MicroProfile REST Client
* Reactive CRUD operations for Postgres

### Setup

The sample can be deployed on three different Kubernetes environments:

1. Minikube: The instructions are below. 
2. CodeReady Containers / local OpenShift: See [instructions](documentation/OpenShift4.md).
3. IBM Cloud Kubernetes Service: See [instructions](documentation/IKS.md).

**1. Install Minikube**

See the [instructions](https://kubernetes.io/docs/tasks/tools/install-minikube/).

**2. Get the code**

```
$ git clone https://github.com/IBM/cloud-native-starter.git
$ cd cloud-native-starter/reactive
$ ROOT_FOLDER=$(pwd)
```

**3. Install prerequisites**

```
$ cd ${ROOT_FOLDER}
$ sh scripts/check-prerequisites.sh
```

**4. Start Minikube and install Kafka and Postgres**

After every step follow the instructions in the output of the commands to check when the components have been started before moving on. It's also recommended to doublecheck whether all components in all namespaces have the 'green' status in the Minikube dashboard ($ minikube dashboard).

```
$ cd ${ROOT_FOLDER}
$ sh scripts/start-minikube.sh
$ sh scripts/deploy-kafka.sh
$ sh scripts/deploy-postgres-operator.sh
$ sh scripts/deploy-postgres-database.sh
$ sh scripts/deploy-postgres-admin.sh
```

The script [deploy-kafka.sh](scripts/deploy-kafka.sh) performs the following actions:
1. Create a namespace 'kafka'
2. Install the Kafka operator [strimzi-cluster-operator](https://strimzi.io/docs/master/)
3. Deploy the 'my-cluster-entity-operator'
4. Deploy Kafka (3 pods my-cluster-zookeeper, 3 pods my-cluster-kafka)

The script [deploy-postgres-operator.sh](scripts/deploy-postgres-operator.sh) performs the following actions:
1. Install the [Operator Lifecycle Manager](https://github.com/operator-framework/operator-lifecycle-manager)
2. Install the Postgres operator [dev4devs-com/postgresql-operator](https://github.com/dev4devs-com/postgresql-operator)

The script [deploy-postgres-database.sh](scripts/deploy-postgres-database.sh) creates a Postgres database and opens up a NodePort.

The script [deploy-postgres-admin.sh](scripts/deploy-postgres-admim.sh) is optional only and install the Postgres admin tool [pgAdmin](https://www.pgadmin.org/).

### Deploy and run the sample in Minikube

**Demo 1: Web application is refreshed automatically when new articles are created**

```
$ cd ${ROOT_FOLDER}
$ sh scripts/deploy-articles-reactive-postgres.sh
$ sh scripts/deploy-web-api-reactive.sh
$ sh scripts/deploy-web-app-reactive.sh
$ sh scripts/show-urls.sh
```

Create a new article either via the API explorer or curl. Open either the web application or only the stream endpoint in a browser. See the output of 'show-urls.sh' for the URLs.

**Demo 2: Reactive REST Endpoint '/articles' in web-api service**

```
$ cd ${ROOT_FOLDER}
$ sh scripts/deploy-articles-reactive-postgres.sh
$ sh scripts/deploy-web-api-reactive.sh
$ sh scripts/deploy-web-app-reactive.sh
$ sh scripts/deploy-authors.sh
$ sh scripts/show-urls.sh
```

Open the API explorer of the web-api service and invoke the '/articles' endpoint. See the output of 'show-urls.sh' for the URL.

In order to test resiliency, try different combinations of the appliation with and without the articles and authors services being available.

```
$ cd ${ROOT_FOLDER}
$ sh scripts/deploy-web-api-reactive.sh
$ sh scripts/deploy-articles-reactive-postgres.sh
$ sh scripts/deploy-authors.sh
$ sh scripts/delete-authors.sh
$ sh scripts/delete-articles-reactive.sh
```

**Optional: Run the sample locally**

You can run single services locally, but there are some restrictions:

* Kafka always run in Minikube
* Only one of the services can be run locally at the same time since they all use the same port
* When running the articles or the web-api service locally, the web application doesn't work
* When running the web-api service locally, the messaging works, but not the REST invocations

Here is an example how to run the web-api service locally:

*First terminal*

```
$ cd ${ROOT_FOLDER}
$ sh scripts/deploy-articles-reactive-postgres.sh
$ sh scripts/run-locally-web-api-reactive.sh
```

*Browser*

Open the stream endpoint in a browser.

*Second terminal*

```
$ cd ${ROOT_FOLDER}
$ sh scripts/show-urls.sh
$ curl -X POST "http://localhost:8080/v1/articles" ...
```