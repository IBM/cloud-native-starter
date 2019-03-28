## Notes on IKS Deployment (work in progress)

Change into cloud-native-starter directory, then
$ ibmcloud login
$ ibmcloud iam api-key-create cloud-native-starter \
  -d "cloud-native-starter" \
  --file cloud-native-starter.json
$ cat cloud-native-starter.json
$ cp template.local.env local.env 

From the output of cloud-native-starter.json copy the apikey without " " into IBMCLOUD_API_KEY= in file local.env.

You already have a Kubernetes Cluster and a Container Image Registry on IBM Cloud?

Enter their region, cluster name, and image registry namespace in local.env overwriting the exiting values.

You do not have a Kubernetes Cluster and a Container Image Registry on IBM Cloud?

The file local.env has preset values for region, cluster name, and image registry namespace in local.env. You can change them of course if you know what you are doing.

local.env:
IBMCLOUD_API_KEY=xxx
IBM_CLOUD_REGION=us-south
CLUSTER_NAME=cloud-native
REGISTRY_NAMESPACE=cloud-native

## Create IKS Environment

ibmcloud config --check-version=false
ibmcloud api --unset
ibmcloud api https://cloud.ibm.com
ibmcloud login --apikey $IBMCLOUD_API_KEY -r $IBM_CLOUD_REGION