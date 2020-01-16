## Reactive Java Microservices on OpenShift 4

This documentation has been developed/tested on CRC (CodeReady Containers).

### 1. Create an OpenShift 4 cluster

Start with these 2 documents to create and get access to an OpenShift 4 environment, but make sure to come back here!

1. [Get access to an OpenShift cluster](../../documentation/OS4Cluster.md)
    **Note:** Don't continue with the Istio installation, Istio is currently not required! Continue here:
2. [Requirements for Cloud Native Starter on OpenShift](../../documentation/OS4Requirements.md)
    **Note:** Don't follow the "Continue ..." link at the end of this document, instead return here and continue with the next section!

### 2. Install Prerequisites

The following script will inform about missing tools:

```
$ cd ${ROOT_FOLDER}/reactive
$ ROOT_FOLDER=$(pwd)
$ sh os4-scripts/check-prerequisites.sh
```

### 3. Install Kafka

We will install Kafka via a script using the Strimzi operator:

```
$ sh os4-scripts/deploy-kafka.sh
```
This script will
1. Create a project kafka in OpenShift
1. Install the "strimzi-cluster-operator"
1. Deploy the "my-cluster-entity-operator"
1. Deploy Kafka (3 pods my-cluster-zookeeper, 3 pods my-cluster-kafka)

### 4. Install PostgreSQL

We will install PostgreSQL using the Dev2Devs operator in the OpenShift Web Console

1. Login to/open the OpenShift Web Console (`crc console`).
1. In the 'Administrator' view, in 'Home' -> 'Projects' create a new project 'postgres'.
1. In the 'Administrator' view, in 'Operators' -> 'OperatorHub' filter for 'postgres'.
    Note: If you don't see the 'Operator' menu, refresh your browser.
    ![](images/operatorhub-postgres.png)
1. Click on 'PostgreSQL Operator by Dev4Ddevs.com', continue on the 'Show Community Operator' dialog, then click 'Install'.
1. 'Installation Mode' is 'A specific namespace on the cluster', namespace is the 'postgres' project. All else should remain default. Click 'Subscribe'.
    ![](images/subscr-postgres.png)
1. In the 'Installed Operators' view in project 'postgres' wait until the status of the 'PostgreSQL Operator by Dev4Ddevs.com' shows a green checkmark and 'InstallSucceeded'. 
    ![](images/postgres-op-succeeded.png)
1. Click on the operator name, then click 'Create Instance' for the 'Database Database' API.
1. In the YAML file change 'metadata.name' from 'database' to 'database-articles'. Make sure 'metadata.namespace' is 'postgres'. Click 'Create'.
    ![](images/postgres-yaml.png)
1. Go to 'Administrator' view, 'Workloads' -> 'Pods' and check that you see two Running pods, one for database and one for the operator.

### 5. Deploy and run the sample 

**Demo 1: Web application is refreshed automatically when new articles are created**

```
$ cd ${ROOT_FOLDER}
$ sh os4-scripts/deploy-articles-reactive-postgres.sh
$ sh os4-scripts/deploy-web-api-reactive.sh
$ sh os4-scripts/deploy-web-app-reactive.sh
$ sh os4-scripts/show-urls.sh
```
Create a new article either via the API explorer or curl. Open either the web application or only the stream endpoint in a browser. See the output of 'show-urls.sh' for the URLs. Every time you create a new article, the articles list of the web app will automatically show the newest 5 articles. 

**Demo 2: Reactive REST Endpoint '/articles' in web-api service**

```
$ cd ${ROOT_FOLDER}
$ sh os4-scripts/deploy-articles-reactive-postgres.sh
$ sh os4-scripts/deploy-web-api-reactive.sh
$ sh os4-scripts/deploy-web-app-reactive.sh
$ sh os4-scripts/deploy-authors.sh
$ sh os4-scripts/show-urls.sh
```

Open the API explorer of the web-api service and invoke the '/articles' endpoint. See the output of 'show-urls.sh' for the URL.

In order to test resiliency, try different combinations of the appliation with and without the articles and authors services being available.

```
$ cd ${ROOT_FOLDER}
$ sh os4-scripts/deploy-web-api-reactive.sh
$ sh os4-scripts/deploy-articles-reactive-postgres.sh
$ sh os4-scripts/deploy-authors.sh
$ sh os4-scripts/delete-authors.sh
$ sh os4-scripts/delete-articles-reactive.sh
```

** Cleanup

To delete the project including Kafka and Postgres from OpenShift, run:


```
$ cd ${ROOT_FOLDER}
$ sh os4-scripts/cleanup.sh
```
