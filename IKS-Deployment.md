# Deployment on IBM Cloud using IBM Cloud Kubernetes Service

If you want to deploy the Cloud Native Starter on IBM Cloud Kubernetes Service (IKS), the IBM managed Kubernetes offering, then follow these steps. They will create a Kubernetes Lite Cluster with Istio enabled and a namespace in the IBM Container Registry (ICR) where the container images of the microservices will be created, stored, and made available for Kubernetes deployments. By default, deployment is in Dallas, USA (us-south). If you already have a lite cluster in Dallas, these scripts will not work because only one lite cluster is allowed. 

A Kubernetes lite cluster itself is free of charge but it can not be created in a IBM Cloud Lite account. In order to create one either a credit card needs to be entered into the IBM Cloud account or you need a promo code which you can sometimes get at conferences where IBM is present.

**Prerequisites:**

* [git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git) 
* [curl](https://curl.haxx.se/download.html)
* [docker](https://docs.docker.com/install/) requires not only the code but also permission to run docker commands
* [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/)
* [ibmcloud CLI](https://cloud.ibm.com/docs/home/tools) 

Run this script to check the prerequisites:

```
$ iks-scripts/IKS-check-prerequisites.sh
```


**Get the code:**

```
$ git clone https://github.com/nheidloff/cloud-native-starter.git
$ cd cloud-native-starter
```

**To prepare the deployment on IBM Cloud:**

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
```


## Create IBM Kubernetes Service Environment

This step creates a lite Kubernetes cluster on IBM Cloud. 

```
$ iks-scripts/create-iks-cluster.sh
```

Creating a cluster takes some time. Please wait at least 20 minutes before you continue with the next step!

## Add Istio

IBM Kubernetes Service has a feature call 'add-ons' that can be installed into an existing cluster. There are several add-ons avaliable, one of them is *Istio* and another is *Istio Extras* which contains Kiali, Istios graphical dashboard.


```
$ iks-scripts/cluster-add-istio.sh
```

This command first checks if the cluster created in the previous step is ready and available. If it isn't, the script terminates. Then just wait a few more minutes and try again.

Once complete, the Kiali dashboard can be accessed with this command:

```
$ kubectl -n istio-system port-forward $(kubectl -n istio-system get pod -l app=kiali -o jsonpath='{.items[0].metadata.name}') 20001:20001
```
Then open http://localhost:20001 in your browser, logon with Username: admin, Password: admin

## Create Container Registry

When Istio is installed and all Istio pods are started, create a namespace in the IBM Cloud Container Registry:

```
$ iks-scripts/create-registry.sh
```

The container images we will build next are stored in the Container Registry as `us.icr.io/cloud-native/<imagename>:<tag>` if you didn't change the defaults.


## Enable Istio Sidecar Auto Injection

```
$ kubectl label namespace default istio-injection=enabled
```

## Deploy Cloud Native Starter

To deploy (or redeploy) run these scripts:

```
$ iks-scripts/IKS-deploy-articles-java-jee.sh
$ iks-scripts/IKS-deploy-web-api-java-jee.sh
$ iks-scripts/IKS-deploy-authors-nodejs.sh
$ iks-scripts/IKS-deploy-web-app-vuejs.sh
$ scripts/deploy-istio-ingress-v1
$ iks-scripts/IKS-show-urls.sh
```
After running all (!) the scripts above, you will get a list of all URLs in the terminal. All the commands with kubectl require that the kubectl environment is set with `source iks-scripts/cluster-config.sh`. This is required once when you start a new shell.
