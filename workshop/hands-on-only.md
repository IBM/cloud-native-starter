# Hands-on only part of the workshop

This page summarizes the steps of the workshop.

## Step 1

[Get an IBM Cloud account](https://ibm.biz/Bd2JHx) and enter promocode

## Step 2

[Install ibmcloud CLI](https://cloud.ibm.com/docs/cli/reference/bluemix_cli?topic=cloud-cli-install-ibmcloud-cli#shell_install)

```
$ ibmcloud plugin install container-service
$ ibmcloud plugin install container-registry
```

## Step 3

Get an API key

```
$ ibmcloud login -a https://cloud.ibm.com -r us-south -g default
$ ibmcloud iam api-key-create cloud-native-starter-key \
  -d "This is the cloud-native-starter key to access the IBM Platform" \
  --file cloud-native-starter-key.json
$ cat cloud-native-starter-key.json
```

## Step 4 

Create local.env

```
$ cp template.local.env local.env
```

* Paste the API key
* Change the row 'REGISTRY_NAMESPACE=cloud-native-yourname'

## Step 5

Create cluster

```
$ git clone https://github.com/IBM/cloud-native-starter.git
$ cd cloud-native-starter
$ ./iks-scripts/create-iks-cluster.sh
```

## Step 6

Add Istio

```
$ ./iks-scripts/cluster-get-config.sh
$ ibmcloud ks cluster-config cloud-native
$ export KUBECONFIG=/<home>/.bluemix/plugins/container-service/clusters/mycluster/kube-config-<region>-<cluster-name>.yml
$ cd workshop
$ curl -L https://git.io/getLatestIstio | ISTIO_VERSION=1.1.5 sh -
$ export PATH=$PWD/istio-1.1.5/bin:$PATH
$ cd istio-1.1.5
$ for i in install/kubernetes/helm/istio-init/files/crd*yaml; do kubectl apply -f $i; done
$ kubectl apply -f install/kubernetes/istio-demo.yaml
$ kubectl get pod -n istio-system
$ kubectl label namespace default istio-injection=enabled
$ kubectl -n istio-system port-forward $(kubectl -n istio-system get pod -l app=kiali -o jsonpath='{.items[0].metadata.name}') 20001:20001
```

Open [Kiali](http://localhost:20001/kiali)

## Step 7

Create registry

```
$ cd ../..
$ ./iks-scripts/create-registry.sh
```

## Step 8

Create services

```
$ ./iks-scripts/deploy-articles-java-jee.sh
$ ./iks-scripts/deploy-authors-nodejs.sh
$ ./iks-scripts/deploy-web-api-java-jee.sh
$ ./iks-scripts/deploy-web-app-vuejs.sh
$ ./scripts/deploy-istio-ingress-v1.sh
$ ./iks-scripts/show-urls.sh
```