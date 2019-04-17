## Prerequisites

****** **UNDER CONSTRUCTION** ******

Here I will use 
iks-scripts/create-iks-cluster.sh
iks-scripts/cluster-add-istio.sh

Following tools have to be installed on your laptop, to perform the workshop.

- [git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git) 
- [curl](https://curl.haxx.se/download.html)
- [IBM Cloud CLI](https://cloud.ibm.com/docs/home/tools) 
- [Docker](https://docs.docker.com/v17.12/install/)
- [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/)
- on Windows, you need access to a Unix shell (Babun, [Cygwin](https://cygwin.com/install.html), etc.)


### IBM Cloud access

[[ibm-cloud-cli]]

#### Installing IBM Cloud CLI

Follow the steps listed under the [Install from shell^](https://cloud.ibm.com/docs/cli/reference/bluemix_cli?topic=cloud-cli-install-ibmcloud-cli#shell_install) section to download and install the IBM Cloud CLI.

- MacOS: `curl -fsSL https://clis.ng.bluemix.net/install/osx | sh`
- Linux: `curl -fsSL https://clis.ng.bluemix.net/install/linux | sh`
- Windows (Powershell): `iex(New-Object Net.WebClient).DownloadString('https://clis.ng.bluemix.net/install/powershell')`

[Documentation install CLI](images/docs.gif)


#### Registering IBM Cloud Account

Open a browser window and navigate to [Registration page](https://ibm.biz/Bd2JHx).

![image](images/registration.png)

Fill in the registration form and follow the link in the validation email when it arrives.

![Validation email](images/email.png)

[Login into IBM Cloud^](https://ibm.biz/Bd2JHx) using the account credentials you have registered.

NOTE: IBM Cloud new accounts set default to the [lite account version](https://www.ibm.com/cloud/pricing).

This account type provides free access to a subset of IBM Cloud resources.
Lite accounts **do not need a credit-card** to sign up or expire after a set time period, i.e. 30 days.
Developers using lite accounts are restricted to use Kubernetes lite / free cluster for which they can use the provided promo codes.


#### IBM Cloud CLI

We log into the IBM Cloud CLI tool: `ibmcloud login`.
If you have a federated account, include the `--sso` flag: `ibmcloud login --sso`.

Install the IBM Cloud Kubernetes Service plug-in (`cs` sub command):

```sh
ibmcloud plugin install container-service
```

To verify that the plug-in is installed properly, run `ibmcloud plugin list`.
The Container Service plug-in is displayed in the results as `container-service/kubernetes-service`.

Initialize the Container Service plug-in and point the endpoint to your region:

```sh
ibmcloud ks region-set eu-gb
```

All subsequent CLI commands will operate in that region.


### IBM Kubernetes Service

[Create a Kubernetes cluster](https://console.bluemix.net/docs/containers/cs_clusters.html#clusters_ui)[Create a Kubernetes cluster^] (lite or standard) using the [Cloud Console](https://cloud.ibm.com/containers-kubernetes/catalog/cluster/create) or CLI in region `eu-gb` (London).
A lite / free cluster is sufficient for this workshop but feel free to create a standard cluster with your desired configuration.

NOTE: When you're using the CLI or the browser Cloud console, always make sure you're **viewing the correct region**, as your resources will only be visible in its region.

#### Promo Codes

In order that you can easily execute the workshop, we're providing promo codes to create lite clusters, even if you don't want to provide your credit card details.
You apply the provided promo code under your [Cloud Account](https://cloud.ibm.com/account) ("`Manage`" -> "`Account`") by navigating to "`Account settings`".
Apply your personal Feature (Promo) Code there.

NOTE: Lite clusters expire after one month.


#### Accessing the cluster

Now, we'll see how to set the context to work with our clusters by using the `kubectl` CLI, access the Kubernetes dashboard, and gather basic information about our cluster.

We set the context for the cluster in the CLI.
Every time you log in to the IBM Cloud Kubernetes Service CLI to work with the cluster, you must run these commands to set the path to the cluster's configuration file as a session variable.
The Kubernetes CLI uses this variable to find a local configuration file and certificates that are necessary to connect with the cluster in IBM Cloud.

List the available clusters: `ibmcloud cs clusters`.
This command should now show your cluster which is being created.

Download the configuration file and certificates for the cluster using the `cluster-config` command:

```sh
ibmcloud ks cluster-config <cluster-name>
```

Copy and paste the output command from the previous step to set the `KUBECONFIG` environment variable and configure the CLI to run `kubectl` commands against the cluster:

```sh
export KUBECONFIG=/<home>/.bluemix/plugins/container-service/clusters/mycluster/kube-config-<region>-<cluster-name>.yml
```

Get basic information about the cluster and its worker nodes.
This information can help you managing the cluster and troubleshoot issues.

Get the details of your cluster: `ibmcloud cs cluster-get <cluster-name>`

Verify the nodes in the cluster:

```sh
ibmcloud cs workers <cluster-name>
kubectl get nodes
```

View the currently available services, deployments, and pods:

```sh
kubectl get svc,deploy,po --all-namespaces
```

#### Add Istio

TBD

Before we continue, we make sure all the pods are deployed and are either in `Running` or `Completed` state.
If they're still pending, we'll wait a few minutes to let the deployment finish.

Congratulations! We now successfully installed Istio into our cluster.


#### Container Registry

In order to build and distribute Docker images, we need a Docker registry.
We can use the IBM Container Registry which can be accessed right away from our Kubernetes cluster.

We log into the Container Registry service via the `ibmcloud` CLI and obtain the information about our registry:

```sh
ibmcloud plugin install container-registry
ibmcloud cr login
ibmcloud cr region-set eu-gb
ibmcloud cr region
You are targeting region 'uk-south', the registry is 'registry.eu-gb.bluemix.net'.
```

We use the CLI to create a unique namespace in the Container Registry service (`cr`) for our workshop:

```sh
ibmcloud cr namespace-add jfokus-<your-name>-workshop
ibmcloud cr namespaces
```

In order to test our new registry namespace, we pull a public image, re-tag it for our own registry, for our region, and push it:

```sh
docker pull sdaschner/open-liberty:javaee8-tracing-b1
docker tag sdaschner/open-liberty:javaee8-tracing-b1 registry.eu-gb.bluemix.net/jfokus-<your-name>-workshop/open-liberty:1
docker push registry.eu-gb.bluemix.net/jfokus-<your-name>-workshop/open-liberty:1
```

Let's see whether our image is now in the private registry:

```sh
ibmcloud cr images
```

NOTE: In all following examples, you will need to adapt the image / namespace name!
This is important to take into consideration, otherwise the examples won't work since the images won't exist in your account.

### Local Docker setup

If you want to try out the example locally, you have to create a Docker network similar to the following:

```sh
docker network create --subnet=192.168.42.0/24 dkrnet
```

Now, we've finished all preparations.
Let's get started with the link:01-introduction.adoc[workshop].
