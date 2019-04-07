## Access IBM Cloud

In order to use services from the IBM Cloud like the IBM Cloud Kubernetes Service or IBM App ID, follow these instructions.

First get an [IBM Cloud Lite account](http://ibm.biz/nheidloff). It's free, there is no time restriction and no credit card is required!

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

The file local.env has preset values for region, cluster name, and image registry namespace in local.env. You can change them of course if you know what you are doing.

Example local.env:

```
IBMCLOUD_API_KEY=AbcD3fg7hIj65klMn9derHHb9zge5
IBM_CLOUD_REGION=us-south
CLUSTER_NAME=cloud-native
REGISTRY_NAMESPACE=cloud-native
```