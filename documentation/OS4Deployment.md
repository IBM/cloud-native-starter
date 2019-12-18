# Running the Cloud Native Starter on OpenShift 4.2

Before you start with the actual Cloud Native Starter project on OpenShift you must go through all of these 3 documents:

1. [Get access to an OpenShift cluster](OS4Cluster.md)
2. [Installing Istio aka Service Mesh on your OpenShift cluster](OS4ServiceMesh.md)
3. [Requirements for Cloud Native Starter on OpenShift](OS4Requirements.md)


To following commands deploy the base project.

**Note:** If you get an error "The token provided is invalid or expired" the value for APITOKEN in file local.env is no longer valid. Follow the instructions to obtain the API token in [Requirements for Cloud Native Starter on OpenShift](https://github.com/IBM/cloud-native-starter/blob/master/documentation/OS4Requirements.md#access-openshift-via-cli) in section "Access OpenShift via CLI". 


```
$ os4-scripts/check-prerequisites.sh
$ os4-scripts/deploy-articles-java-jee.sh
$ os4-scripts/deploy-authors-nodejs.sh
$ os4-scripts/deploy-web-api-java-jee.sh
$ 
```











 