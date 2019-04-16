## Prerequisites

****** **UNDER CONSTRUCTION** ******

Following tools have to be installed on your laptop, to perform the workshop.

- [git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git) 
- [curl](https://curl.haxx.se/download.html)
- [IBM Cloud CLI](https://cloud.ibm.com/docs/home/tools) 
- [Docker](https://docs.docker.com/v17.12/install/)
- [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/)
- JDK 8+
- Maven 3 ???
- `helm` (Tiller not required) ???
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

----
ibmcloud plugin install container-service
----

To verify that the plug-in is installed properly, run `ibmcloud plugin list`.
The Container Service plug-in is displayed in the results as `container-service/kubernetes-service`.

Initialize the Container Service plug-in and point the endpoint to your region:

----
ibmcloud cs region-set eu-gb
----

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

----
ibmcloud cs cluster-config <cluster-name>
----

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

#### Installing Istio

Now, we'll see how we download and install Istio 1.0.5 to our cluster.

We download Istio 1.0.5 directly from [GitHub](https://github.com/istio/istio/releases/1.0.5).
Choose the version that matches your system: `istio-1.0.5-<os>.{zip,tar.gz}`

We extract the installation files (example for `tar.gz`):

```sh
tar -xvzf istio-<istio-version>-linux.tar.gz
```

Optionally, we add the `istioctl` client to the PATH.
The `<version-number>` is in the directory name.

```sh
export PATH=$PWD/istio-<version-number>/bin:$PATH
```

We switch the directory into to the Istio file location: `cd istio-<version-number>` and we install Istio’s resource definitions via the following commands:

```sh
helm template $PWD/install/kubernetes/helm/istio --name istio --namespace istio-system \
  --set tracing.enabled=true \
  --set grafana.enabled=true \
  --set kiali.enabled=true \
  --set pilot.traceSampling=100.0 \
  > /tmp/istio.yaml
kubectl create namespace istio-system
kubectl label namespace default istio-injection=enabled --overwrite
kubectl create -f /tmp/istio.yaml
```

This will install Istio 1.0.5 with distributed tracing, Grafana monitoring, Kiali, and automatic sidecar injection for the `default` namespace being enabled.

Now, we ensure that the `istio-*` Kubernetes services have been deployed correctly.

```sh
kubectl get services -n istio-system
```

```sh
NAME                       TYPE           CLUSTER-IP       EXTERNAL-IP      PORT(S)                                                                                                                   AGE
grafana                    ClusterIP      172.21.44.128    <none>           3000/TCP                                                                                                                  5d
istio-citadel              ClusterIP      172.21.62.12     <none>           8060/TCP,9093/TCP                                                                                                         5d
istio-egressgateway        ClusterIP      172.21.115.236   <none>           80/TCP,443/TCP                                                                                                            5d
istio-galley               ClusterIP      172.21.7.201     <none>           443/TCP,9093/TCP                                                                                                          5d
istio-ingressgateway       LoadBalancer   172.21.19.202    169.61.151.162   80:31380/TCP,443:31390/TCP,31400:31400/TCP,15011:32440/TCP,8060:32156/TCP,853:30932/TCP,15030:32259/TCP,15031:31292/TCP   5d
istio-pilot                ClusterIP      172.21.115.9     <none>           15010/TCP,15011/TCP,8080/TCP,9093/TCP                                                                                     5d
istio-policy               ClusterIP      172.21.165.123   <none>           9091/TCP,15004/TCP,9093/TCP                                                                                               5d
istio-sidecar-injector     ClusterIP      172.21.164.224   <none>           443/TCP                                                                                                                   5d
istio-statsd-prom-bridge   ClusterIP      172.21.57.144    <none>           9102/TCP,9125/UDP                                                                                                         5d
istio-telemetry            ClusterIP      172.21.165.71    <none>           9091/TCP,15004/TCP,9093/TCP,42422/TCP                                                                                     5d
jaeger-agent               ClusterIP      None             <none>           5775/UDP,6831/UDP,6832/UDP                                                                                                5d
jaeger-collector           ClusterIP      172.21.154.138   <none>           14267/TCP,14268/TCP                                                                                                       5d
jaeger-query               ClusterIP      172.21.224.97    <none>           16686/TCP                                                                                                                 5d
prometheus                 ClusterIP      172.21.173.167   <none>           9090/TCP                                                                                                                  5d
servicegraph               ClusterIP      172.21.190.31    <none>           8088/TCP                                                                                                                  5d
tracing                    ClusterIP      172.21.2.208     <none>           80/TCP                                                                                                                    5d
zipkin                     ClusterIP      172.21.76.162    <none>           9411/TCP                                                                                                                  5d
```

NOTE: For Lite clusters, the istio-ingressgateway service will be in `pending` state with no external IP address.
This is normal.

We ensure the corresponding pods `istio-citadel-*`, `istio-ingressgateway-*`, `istio-pilot-*`, and `istio-policy-*` are all in `Running` state before continuing.

```sh
kubectl get pods -n istio-system
grafana-85dbf49c94-gccvp                    1/1       Running     0          5d
istio-citadel-545f49c58b-j8tm5              1/1       Running     0          5d
istio-cleanup-secrets-smtxn                 0/1       Completed   0          5d
istio-egressgateway-79f4b99d6f-t2lvk        1/1       Running     0          5d
istio-galley-5b6449c48f-sc92j               1/1       Running     0          5d
istio-grafana-post-install-djzm9            0/1       Completed   0          5d
istio-ingressgateway-6894bd895b-tvklg       1/1       Running     0          5d
istio-pilot-cb58b65c9-sj8zb                 2/2       Running     0          5d
istio-policy-69cc5c74d5-gz8kt               2/2       Running     0          5d
istio-sidecar-injector-75b9866679-sldhs     1/1       Running     0          5d
istio-statsd-prom-bridge-549d687fd9-hrhfs   1/1       Running     0          5d
istio-telemetry-d8898f9bd-2gl49             2/2       Running     0          5d
istio-telemetry-d8898f9bd-9r9jz             2/2       Running     0          5d
istio-tracing-7596597bd7-tqwkr              1/1       Running     0          5d
prometheus-6ffc56584f-6jqhg                 1/1       Running     0          5d
servicegraph-5d64b457b4-z2ctz               1/1       Running     0          5d
```

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
