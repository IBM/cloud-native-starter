*** !!! UNDER CONSTRUCTION !!! ***

# Reactive Java Microservices on IBM Cloud Kubernetes 

## 1. Setup IBM Cloud Kubernetes Service and IBM Cloud Container Registry

If you want to deploy the Cloud Native Starter on IBM Cloud Kubernetes Service (IKS), the IBM managed Kubernetes offering, then follow these steps. They will create a Kubernetes Lite Cluster and a namespace in the IBM Container Registry (ICR) where the container images of the microservices will be created, stored, and made available for Kubernetes deployments.

Istio is not needed to install in this setup.

A Kubernetes lite cluster itself is free of charge but it can not be created in a IBM Cloud Lite account. In order to create one either a credit card needs to be entered into the IBM Cloud account or you need a promo code which you can sometimes get at conferences where IBM is present. Or contact us. 


### 1.1 Get the code:

```
$ git clone https://github.com/IBM/cloud-native-starter.git
$ cd cloud-native-starter/reactive
$ ROOT_FOLDER=$(pwd)
```
### 1.2 Prerequisites:
Most important: an IBM Cloud account, you can register for a free account [here](http://ibm.biz/nheidloff).

* [git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git) 
* [curl](https://curl.haxx.se/download.html)
* [docker](https://docs.docker.com/install/) requires not only the code but also permission to run docker commands
* [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/)
* [ibmcloud CLI](https://cloud.ibm.com/docs/home/tools)  including plugins `kubernetes-service` and `container-registry`

Run this script to check the prerequisites:

```
$ sh iks-scripts/check-prerequisites.sh
```

__Important note to non-English users:__ We use the `ibmcloud` CLI to set and retrieve configuration information. By default `ibmcloud` uses the OS environment language as its locale which could lead to errors in some scripts if it is not English. So on non-English systems we advise to set the `ibmcloud` locale to English by using this command:

```
$ ibmcloud config --locale en_US
```

To revert this setting, simply execute:

```
$ ibmcloud config --locale CLEAR
```

### 1.3 To prepare the deployment on IBM Cloud:

This creates an API key for the scripts.

```
$ ibmcloud login
$ ibmcloud iam api-key-create cloud-native-starter \
  -d "cloud-native-starter" \
  --file cloud-native-starter.json
$ cat cloud-native-starter.json
$ cp template.local.env local.env 
```

From the output of `cloud-native-starter.json` copy the apikey without " " into IBMCLOUD_API_KEY= in file local.env.

The file local.env has preset values for region, cluster name, and image registry namespace in local.env. You can change them of course if you know what you are doing.

Example local.env:

```
IBMCLOUD_API_KEY=AbcD3fg7hIj65klMn9derHHb9zge5
IBM_CLOUD_REGION=us-south
CLUSTER_NAME=cloud-native
REGISTRY_NAMESPACE=cloud-native
IBM_CLOUD_CF_API=https://api.ng.bluemix.net
IBM_CLOUD_CF_ORG=
IBM_CLOUD_CF_SPACE=dev
AUTHORS_DB=local
CLOUDANT_URL=
```

### 1.4 Create IBM Kubernetes Service

This step creates a lite Kubernetes cluster on IBM Cloud. 

```
$ sh iks-scripts/create-iks-cluster.sh
```

Creating a cluster takes some time, typically at least 20 minutes.

The next command checks if the cluster is ready and if it is ready, it retrieves the cluster configuration (which is needed in most of the other scripts), creates file `iks-scripts/cluster-config.sh`, and stores the cluster configuration in it. If the cluster isn't ready, the script will tell you. Then just wait a few more minutes and try again.

```
$ sh iks-scripts/cluster-get-config.sh
```

**NOTE:** You **MUST** run this command to check for completion of the cluster provisioning and it must report that the cluster is ready for Istio installation! This command also retrieves the cluster configuration which is needed in other scripts. But this configuration can only be retrieved from a cluster that is in ready state.  

From now on if you want to use `kubectl` commands with your cluster use this command to get access to the cluster:

```
$ source iks-scripts/cluster-config.sh
```

### 1.5. Create Container Registry

Create a namespace in the IBM Cloud Container Registry:

```
$ sh iks-scripts/create-registry.sh
```

The container images we will build next are stored in the Container Registry as `us.icr.io/cloud-native/<imagename>:<tag>` if you didn't change the defaults.


## 2. Install Kafka and Postgres

After every step follow the instructions in the output of the commands to check when the components have been started before moving on.

```
$ cd ${ROOT_FOLDER}
$ sh iks-scripts/deploy-kafka.sh
$ sh iks-scripts/deploy-postgres.sh
```

## 3. Deploy and run the reactive sample

### Demo 1: Web application is refreshed automatically when new articles are created

```
$ cd ${ROOT_FOLDER}
$ sh scripts/deploy-articles-reactive-postgres.sh
$ sh scripts/deploy-web-api-reactive.sh
$ sh scripts/deploy-web-app-reactive.sh
$ sh scripts/show-urls.sh
```

Create a new article either via the API explorer or curl. Open either the web application or only the stream endpoint in a browser. See the output of 'show-urls.sh' for the URLs.

### Demo 2: Test resiliency with reactive REST Endpoint '/articles' in web-api service

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

## 4. Cleanup

To delete all the including Kafka and Postgres from Kubernetes, run:

```
$ cd ${ROOT_FOLDER}
$ sh iks-scripts/cleanup.sh
```