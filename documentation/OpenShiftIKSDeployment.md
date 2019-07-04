## Deploy Cloud Native Starter on OpenShift on IBM Cloud

While the rest of this project is based on Open Source and mostly free offerings this part is no longer free of charge. Setting up an OpenShift Cluster on the IBM Cloud requires a paid IBM Cloud account and will generate costs even during the OpenShift beta. During the beta there will be no licence fees for OpenShift but you still need to pay for the hardware of the cluster!
When you create the cluster, the "Order summary" will estimate the cost per month. In this setup we use virtual shared hardware which is charged by the hour. Your incurring costs will therefore depend on how long you run the cluster.

**Get the code**

```
$ git clone https://github.com/nheidloff/cloud-native-starter.git
$ cd cloud-native-starter
```

**Prerequisites**

Make sure you have the following prerequisites installed:

* [git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git) 
* [curl](https://curl.haxx.se/download.html)
* [ibmcloud CLI](https://cloud.ibm.com/docs/home/tools) 

Run this script to check the prerequisites:

```
$ ibm-scripts/IKS-check-prerequisites.sh
```

**Create an API Key**

```
$ ibmcloud login
$ ibmcloud iam api-key-create cloud-native-starter \
  -d "cloud-native-starter" \
  --file cloud-native-starter.json
$ cat cloud-native-starter.json
$ cp template.local.env local.env 
```

From the output of `cat cloud-native-starter.json` copy the apikey without " " into IBMCLOUD_API_KEY= in file local.env.

The file local.env has preset values for region and cluster name. You can change them of course if you know what you are doing.

Example local.env:

```
IBMCLOUD_API_KEY=AbcD3fg7hIj65klMn9derHHb9zge5
IBM_CLOUD_REGION=us-south
CLUSTER_NAME=cloud-native
REGISTRY_NAMESPACE=cloud-native
```

### 1. Setup OpenShift on IBM Cloud

Our normal approach throughout this project is to script as much as possible. 

We could script the OpenShift cluster creation, too, but have decided against because only when you create the cluster manually in the IBM Cloud Dashboard will you see an estimate of the costs.

Create an OS Cluster in the IBM Cloud Dashboard

  a) Logon to the IBM Cloud
  b) From the IBM Cloud Menu (upper left corner) select "Kubernetes"
  c) Click "Create cluster"
  d) Select plan: "Standard"
  e) Cluster type and version: "OpenShift"
  f) Cluster name: "cloud-native-openshift"
  g) Resource group: "default", Geography "North America"
  h) Availability: "Single zone"
  i) Worker zone: select any of the available zones, e.g. "Washington DC 06"
  j) Master service endpoint: "Public endpint only" 
  k) Default worker pool/Flavor: "2 Cores 4 GB RAM, Virtual Shared, u3c.2x4"
  l) Worker nodes: 2

Click on "Create Cluster", this will take approximately 15 to 20 minutes.





