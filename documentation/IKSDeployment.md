## Deployment on IBM Cloud using IBM Cloud Kubernetes Service

If you want to deploy the Cloud Native Starter on IBM Cloud Kubernetes Service (IKS), the IBM managed Kubernetes offering, then follow these steps. They will create a Kubernetes Lite Cluster with Istio enabled and a namespace in the IBM Container Registry (ICR) where the container images of the microservices will be created, stored, and made available for Kubernetes deployments. By default, deployment is in Dallas, USA (us-south). If you already have a lite cluster in Dallas, these scripts will not work because only one lite cluster is allowed. 

A Kubernetes lite cluster itself is free of charge but it can not be created in a IBM Cloud Lite account. In order to create one either a credit card needs to be entered into the IBM Cloud account or you need a promo code which you can sometimes get at conferences where IBM is present. Or contact us, Harald or Niklas, our Twitter links are in the README, and we'll try to get one for you. 


### Get the code:

```
$ git clone https://github.com/IBM/cloud-native-starter.git
$ cd cloud-native-starter
```
### Prerequisites:
Most important: an IBM Cloud account, you can register for a free account [here](http://ibm.biz/nheidloff).

* [git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git) 
* [curl](https://curl.haxx.se/download.html)
* [docker](https://docs.docker.com/install/) requires not only the code but also permission to run docker commands
* [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/)
* [ibmcloud CLI](https://cloud.ibm.com/docs/home/tools)  including plugins `kubernetes-service` and `container-registry`
    * Make sure that both the ibmcloud CLI and the kubernetes-service plugin are at least at version 1.0.0:
    * `ibmcloud version`
    * `ibmcloud plugin list`

Run this script to check the prerequisites:

```
$ iks-scripts/check-prerequisites.sh
```

__Important note to non-English users:__ We use the `ibmcloud` CLI to set and retrieve configuration information. By default `ibmcloud` uses the OS environment language as its locale which could lead to errors in some scripts if it is not English. So on non-English systems we advise to set the `ibmcloud` locale to English by using this command:

```
$ ibmcloud config --locale en_US
```

To revert this setting, simply execute:

```
$ ibmcloud config --locale CLEAR
```

### To prepare the deployment on IBM Cloud:

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

### Create IBM Kubernetes Service Environment

This step creates a lite Kubernetes cluster on IBM Cloud. 

```
$ iks-scripts/create-iks-cluster.sh
```

Creating a cluster takes some time, typically at least 20 minutes.

The next command checks if the cluster is ready and if it is ready, it retrieves the cluster configuration (which is needed in most of the other scripts), and stores the cluster configuration in the kubectl configuration. If the cluster isn't ready, the script will tell you. Then just wait a few more minutes and try again.

```
$ iks-scripts/cluster-get-config.sh
```

**NOTE:** You **MUST** run this command to check for completion of the cluster provisioning and it must report that the cluster is ready for Istio installation! This command retrieves the IKS cluster configuration which is needed in other scripts. But this configuration can only be retrieved from a cluster that is in ready state.  

From now on if you want to use `kubectl` commands with your IKS cluster and you have used other Kubernetes environments before, e.g. Minikube, use this command (`cluster-get-config.sh`) to get access to the IKS cluster again. 

### Add Istio

IBM Kubernetes Service has an option to install a managed Istio into a Kubernetes cluster. Unfortunately, the Kubernetes Lite Cluster we created in the previous step does not meet the hardware requirements for managed Istio. Hence we do a manual install of the Istio demo or evaluation version.

These are the instructions to install Istio. We used and tested Istio 1.5.1 for this project. Please be aware that these installation instructions will not work with Istio versions prior to 1.4.0!


1. Download Istio, this will create a directory istio-1.5.1:

    ```
    curl -L https://git.io/getLatestIstio | ISTIO_VERSION=1.5.1 sh -
    ```

1. Add `istioctl` to the PATH environment variable, e.g copy paste in your shell and/or `~/.profile`. Follow the instructions in the installer message.


    ```
    export PATH="$PATH:/path/to/istio-1.5.1/bin"
    ```

1. Verify the `istioctl` installation:


    ```
    $ istioctl version 
    ```

1. Install Istio on the Kubernetes cluster:

    We will use the `demo` profile to install Istio. 

    **Note:** This is a "...configuration designed to showcase Istio functionality with modest resource requirements. ... **This profile enables high levels of tracing and access logging so it is not suitable for performance tests!**"

    ```
    $ istioctl manifest apply --set profile=demo
    ```


1. Check that all pods are running before continuing.
  
    ```
    $ kubectl get pod -n istio-system
    ```

1. Verify Istio installation

    This generates a manifest file for the demo profile we used to install Istion and then verifies the installation against this profile.

    ```
    $ istioctl manifest generate --set profile=demo > generated-manifest.yaml
    $ istioctl verify-install -f generated-manifest.yaml
    ```

    Result of the second command (last 3 lines) looks like this:

     ```
     Checked 25 crds
	 Checked 3 Istio Deployments
	 Istio is installed successfully
	 ```
 
1. Enable automatic sidecar injection for `default`namespace:

    ```
    $ kubectl label namespace default istio-injection=enabled
    ```

Once complete, the Kiali dashboard can be accessed with this command:

```
$ istioctl dashboard kiali
```

Log in with Username: admin, Password: admin

### Create Container Registry

When Istio is installed and all Istio pods are started, create a namespace in the IBM Cloud Container Registry:

```
$ iks-scripts/create-registry.sh
```

The container images we will build next are stored in the Container Registry as `us.icr.io/cloud-native/<imagename>:<tag>` if you didn't change the defaults.


### Initial Deployment of Cloud Native Starter

To deploy (or redeploy) run these scripts:

```
$ iks-scripts/deploy-articles-java-jee.sh
$ iks-scripts/deploy-web-api-java-jee.sh
$ iks-scripts/deploy-authors-nodejs.sh
$ iks-scripts/deploy-web-app-vuejs.sh
$ scripts/deploy-istio-ingress-v1.sh
$ iks-scripts/show-urls.sh
```

After running all (!) the scripts above, you will get a list of all URLs in the terminal. 

<kbd><img src="../images/IKS-urls.png" /></kbd>

### Demo Traffic Routing

Run these scripts to deploy version 2 of the web-api and then apply Istio traffic routing to send 80% of the traffic to version 1, 20% to version 2:

```
$ iks-scripts/deploy-web-api-java-jee-v2.sh
$ scripts/deploy-istio-ingress-v1-v2.sh
``` 

Create some load and view the traffic distribution in the Kiali console.

### Cleanup

Run the following command to delete all cloud-native-starter components from IKS:

```
$ scripts/delete-all.sh
```

You can also delete single components:

```
$ scripts/delete-articles-java-jee.sh
$ scripts/delete-articles-java-jee-quarkus.sh
$ scripts/delete-web-api-java-jee.sh
$ scripts/delete-authors-nodejs.sh
$ scripts/delete-web-app-vuejs.sh
$ scripts/delete-istio-ingress.sh
```


