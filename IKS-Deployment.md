# Deployment on the IBM Cloud using IBM Cloud Kubernetes Service

**Prerequisites:**

* [git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git) 
* [curl](https://curl.haxx.se/download.html)
* [docker](https://docs.docker.com/install/)
* [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/)
* [ibmcloud CLI](https://cloud.ibm.com/docs/home/tools) 

**Get the code:**

```
$ git clone https://github.com/nheidloff/cloud-native-starter.git
$ cd cloud-native-starter
```

**To prepare the deployment follow these steps:**


```
$ ibmcloud login
$ ibmcloud iam api-key-create cloud-native-starter \
  -d "cloud-native-starter" \
  --file cloud-native-starter.json
$ cat cloud-native-starter.json
$ cp template.local.env local.env 
```

From the output of `cloud-native-starter.json` copy the apikey without " " into IBMCLOUD_API_KEY= in file local.env.

**You already have a Kubernetes Cluster and a Container Image Registry on IBM Cloud?**

Then enter their region, cluster name, and image registry namespace in local.env overwriting the exiting values.

**You do not have a Kubernetes Cluster and a Container Image Registry on IBM Cloud?**

The file local.env has preset values for region, cluster name, and image registry namespace in local.env. You can change them of course if you know what you are doing.

Example local.env:

```
IBMCLOUD_API_KEY=AbcD3fg7hIj65klMn9derHHb9zge5
IBM_CLOUD_REGION=us-south
CLUSTER_NAME=cloud-native
REGISTRY_NAMESPACE=cloud-native
```

## Check prereqs  --> Move to script!!!!

**tbd**
ibmcloud plugin list | awk '/kubernetes-service/ { print $2 }'
ibmcloud plugin list | awk '/container-registry/ { print $2 }'
docker images > /dev/null   --> Check if user has permission to run docker commands


## Create IBM Kubernetes Service Environment

**Andere Ideen?** This step creates a lite Kubernetes cluster on IBM Cloud. The cluster itself is free, but in order to create a free cluster, either a credit card needs to be entered into the IBM Cloud account or you need a promo code which you can sometimes get at conferences where IBM is present. Just ask!

```
$ iks-scripts/create-iks-cluster.sh
```

Creating a cluster takes some time. Please wait at least 20 minutes before you continue with the next step!

## Add Istio

IBM Kubernetes Service has a feature call 'add-ons' that can be installed into an existing cluster. There are several add-ons avaliable, one of them is *Istio* and another is *Kiali*, Istios graphical dashboard.

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


ibmcloud cr build -f Dockerfile --tag $REGISTRY/$REGISTRY_NAMESPACE/authors:1 .

