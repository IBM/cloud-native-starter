# Simplest possible Microservice in Java

This folder contains a microservice which is kept as simple as possible, so that it can be used as a starting point for other microservices. It contains the following functionality:

* Image with OpenJ9, OpenJDK, Open Liberty and MicroProfile: [Dockerfile](Dockerfile)
* Maven project: [pom.xml](pom.xml)
* Open Liberty server configuration: [server.xml](liberty/server.xml)
* Health endpoint: [HealthEndpoint.java](src/main/java/com/ibm/authors/HealthEndpoint.java)
* Kubernetes yaml files: [deployment.yaml](deployment/deployment.yaml) and [service.yaml](deployment/service.yaml)
* Sample REST GET endpoint: [AuthorsApplication.java](src/main/java/com/ibm/authors/AuthorsApplication.java), [GetAuthor.java](src/main/java/com/ibm/authors/GetAuthor.java) and [Author.java](src/main/java/com/ibm/authors/Author.java)

The microservice is a Java version of the Authors service in the 'authors-nodejs' folder. If you want to use this code for your own microservice, remove the three Java files for the REST GET endpoint and rename the service in the pom.xml file and the yaml files.

## Deployment Options

The microservice can be run in different environments:

* [Docker](#run-in-docker)
* [Minikube](#run-in-minikube)
* [IBM Cloud Kubernetes Service](#run-in-ibm-cloud-kubernetes-service)
* [Minishift](#run-in-minishift)
* [Red Hat OpenShift on IBM Cloud](#run-in-red-hat-openshift-on-the-ibm-cloud)

In all cases get the code first:

```
$ git clone https://github.com/nheidloff/cloud-native-starter.git
$ cd cloud-native-starter
$ ROOT_FOLDER=$(pwd)
```

## Run in Docker

```
$ cd ${ROOT_FOLDER}/authors-java-jee
$ mvn package
$ docker build -t authors .
$ docker run -i --rm -p 3000:3000 authors
$ open http://localhost:3000/openapi/ui/
```

## Run in Minikube

```
$ cd ${ROOT_FOLDER}/authors-java-jee
$ mvn package
$ eval $(minikube docker-env)
$ docker build -t authors:1 .
$ kubectl apply -f deployment/deployment.yaml
$ kubectl apply -f deployment/service.yaml
$ minikubeip=$(minikube ip)
$ nodeport=$(kubectl get svc authors --ignore-not-found --output 'jsonpath={.spec.ports[*].nodePort}')
$ open http://${minikubeip}:${nodeport}/openapi/ui/
```

**Final test in Minikube**

First delete all services:

```
$ cd ${ROOT_FOLDER}
$ scripts/delete-all.sh
```

Next deploy the Java based authors service as documented above.

Next deploy the articles and web-api services:

```
$ cd ${ROOT_FOLDER}
$ scripts/deploy-articles-java-jee.sh
$ scripts/deploy-web-api-java-jee.sh
$ scripts/show-urls.sh
```

Invoke /getmultiple, for example 'http://192.168.99.100:31380/web-api/v1/getmultiple'.


## Run in IBM Cloud Kubernetes Service

IBM provides a free [IBM Cloud Lite](https://ibm.biz/nheidloff) account including a free Kubernetes cluster after having updated to a billable account or having entered a promocode. Create a Kubernetes cluster following these [instructions](https://cloud.ibm.com/docs/containers?topic=containers-getting-started#getting-started).

There are several options to deploy microservices to IBM Cloud Kubernetes:

* [ibmcloud and kubectl](#deploy-via-ibmcloud-and-kubectl)
* [Deploy via kubectl and Tekton](#deploy-via-kubectl-and-tekton)

Set your namespace and cluster name, for example:

```
$ REGISTRY_NAMESPACE=niklas-heidloff-cns
$ CLUSTER_NAME=niklas-heidloff-free
```

### Deploy via ibmcloud and kubectl

**Build and push image**

```
$ cd ${ROOT_FOLDER}/authors-java-jee
$ ibmcloud login -a cloud.ibm.com -r us-south -g default
$ ibmcloud ks cluster-config --cluster $CLUSTER_NAME
$ export ... // for example: export KUBECONFIG=/Users/$USER/.bluemix/plugins/container-service/clusters/niklas-heidloff-free/kube-config-hou02-niklas-heidloff-free.yml
$ mvn package
$ REGISTRY=$(ibmcloud cr info | awk '/Container Registry  /  {print $3}')
$ ibmcloud cr namespace-add $REGISTRY_NAMESPACE
$ ibmcloud cr build --tag $REGISTRY/$REGISTRY_NAMESPACE/authors:1 .
```

**Deploy microservice**

```
$ cd ${ROOT_FOLDER}/authors-java-jee/deployment
$ sed "s+<namespace>+$REGISTRY_NAMESPACE+g" deployment-template.yaml > deployment-template.yaml.1
$ sed "s+<ip:port>+$REGISTRY+g" deployment-template.yaml.1 > deployment-template.yaml.2
$ sed "s+<tag>+1+g" deployment-template.yaml.2 > deployment-iks.yaml
$ kubectl apply -f deployment-iks.yaml
$ kubectl apply -f service.yaml
$ clusterip=$(ibmcloud ks workers --cluster $CLUSTER_NAME | awk '/Ready/ {print $2;exit;}')
$ nodeport=$(kubectl get svc authors --output 'jsonpath={.spec.ports[*].nodePort}')
$ open http://${clusterip}:${nodeport}/openapi/ui/
$ curl -X GET "http://${clusterip}:${nodeport}/api/v1/getauthor?name=Niklas%20Heidloff" -H "accept: application/json"
```

### Deploy via kubectl and Tekton

In order to use Tekton, you need to install it first - see [documentation](https://github.com/tektoncd/pipeline/blob/master/docs/install.md#adding-the-tekton-pipelines).

**Set up the Tekton pipleline**

```
$ cd ${ROOT_FOLDER}/authors-java-jee
$ ibmcloud login -a cloud.ibm.com -r us-south -g default
$ ibmcloud ks cluster-config --cluster $CLUSTER_NAME
$ export ... // for example: export KUBECONFIG=/Users/$USER/.bluemix/plugins/container-service/clusters/niklas-heidloff-free/kube-config-hou02-niklas-heidloff-free.yml
$ REGISTRY=$(ibmcloud cr info | awk '/Container Registry  /  {print $3}')
$ ibmcloud cr namespace-add $REGISTRY_NAMESPACE
$ kubectl apply -f deployment/tekton/resource-git-cloud-native-starter.yaml 
$ kubectl apply -f deployment/tekton/task-source-to-image.yaml 
$ kubectl apply -f deployment/tekton/task-deploy-via-kubectl.yaml 
$ kubectl apply -f deployment/tekton/pipeline.yaml
$ ibmcloud iam api-key-create tekton -d "tekton" --file tekton.json
$ cat tekton.json | grep apikey 
$ kubectl create secret generic ibm-cr-push-secret --type="kubernetes.io/basic-auth" --from-literal=username=iamapikey --from-literal=password=<your-apikey>
$ kubectl annotate secret ibm-cr-push-secret tekton.dev/docker-0=us.icr.io
$ kubectl apply -f deployment/tekton/pipeline-account.yaml
```

**Execute the pipeline and test the service**

```
$ cd ${ROOT_FOLDER}/authors-java-jee/deployment/tekton
$ REGISTRY=$(ibmcloud cr info | awk '/Container Registry  /  {print $3}')
$ sed "s+<namespace>+$REGISTRY_NAMESPACE+g" pipeline-run-template.yaml > pipeline-run-template.yaml.1
$ sed "s+<ip:port>+$REGISTRY+g" pipeline-run-template.yaml.1 > pipeline-run-template.yaml.2
$ sed "s+<tag>+1+g" pipeline-run-template.yaml.2 > pipeline-run.yaml
$ cd ${ROOT_FOLDER}/authors-java-jee
$ kubectl create -f deployment/tekton/pipeline-run.yaml
$ kubectl describe pipelinerun pipeline-run-cns-authors-<output-from-previous-command>
$ clusterip=$(ibmcloud ks workers --cluster $CLUSTER_NAME | awk '/Ready/ {print $2;exit;}')
$ nodeport=$(kubectl get svc authors --output 'jsonpath={.spec.ports[*].nodePort}')
$ open http://${clusterip}:${nodeport}/openapi/ui/
$ curl -X GET "http://${clusterip}:${nodeport}/api/v1/getauthor?name=Niklas%20Heidloff" -H "accept: application/json"
```

## Run in Minishift

Prerequisites:

* Install [Minishift](https://github.com/minishift/minishift) v1.34.0 (OKD 3.11.0)
* Install [oc](https://docs.okd.io/latest/cli_reference/get_started_cli.html) CLI

There are several options to deploy microservices to Minishift:

* [kubectl](#deploy-via-kubectl)
* [Git Repo with Dockerfile](#deploy-via-git-repo-with-dockerfile)
* [Binary Build](#deploy-as-binary-build)
* [Source to Image](#deploy-via-s2i)


### Deploy via kubectl

This approach is very similar to the deployments to Minikube and IBM Cloud Kubernetes Service above.

**Build and push image**

```
$ cd ${ROOT_FOLDER}/authors-java-jee
$ mvn package
$ eval $(minishift docker-env)
$ oc login -u developer -p developer
$ oc new-project cloud-native-starter
$ docker login -u developer -p $(oc whoami -t) $(minishift openshift registry)
$ docker build -f DockerfileNoBuild -t authors:kubectl .
$ docker tag authors:kubectl $(minishift openshift registry)/cloud-native-starter/authors:kubectl
$ docker push $(minishift openshift registry)/cloud-native-starter/authors:kubectl
$ oc get istag
```

**Deploy microservice**

```
$ cd ${ROOT_FOLDER}/authors-java-jee/deployment
$ sed "s+<namespace>+cloud-native-starter+g" deployment-template.yaml > deployment-template.yaml.1
$ minishiftregistryip=$(minishift openshift registry)
$ sed "s+<ip:port>+$minishiftregistryip+g" deployment-template.yaml.1 > deployment-template.yaml.2
$ sed "s+<tag>+kubectl+g" deployment-template.yaml.2 > deployment-minishift.yaml
$ kubectl apply -f deployment-minishift.yaml
$ kubectl apply -f service.yaml
$ oc expose svc/authors
$ curl -X GET "http://authors-cloud-native-starter.$(minishift ip).nip.io/api/v1/getauthor?name=Niklas%20Heidloff" -H "accept: application/json"
$ open http://authors-cloud-native-starter.$(minishift ip).nip.io/openapi/ui/
$ open https://$(minishift ip):8443
```

### Deploy via Git Repo with Dockerfile

Rather than building the image locally and deploying the microservice via kubectl and yaml files, Minishift can download the code from a Git repository and build and deploy the microservices:

```
$ oc login -u developer -p developer
$ oc new-project server-side-build
$ oc new-app https://github.com/nheidloff/cloud-native-starter --context-dir=authors-java-jee
$ oc expose svc/server-side-build
$ curl -X GET "http://cloud-native-starter-server-side-build.$(minishift ip).nip.io/api/v1/getauthor?name=Niklas%20Heidloff" -H "accept: application/json"
```

### Deploy as Binary Build

With this [deployment method](https://docs.okd.io/3.11/dev_guide/dev_tutorials/binary_builds.html), the code is pushed to Minishift (similarly to 'cf push').

```
$ cd ${ROOT_FOLDER}/authors-java-jee
$ oc login -u developer -p developer
$ oc new-project binary-build
$ oc new-build --name authors --binary --strategy docker
$ oc start-build authors --from-dir=.
$ oc new-app authors
$ oc expose svc/authors
$ curl -X GET "http://authors-binary-build.$(minishift ip).nip.io/api/v1/getauthor?name=Niklas%20Heidloff" -H "accept: application/json"
```

### Deploy via S2I

The article [Source to Image Builder for Open Liberty Apps on OpenShift](http://heidloff.net/article/source-to-image-builder-open-liberty-openshift/) describes how the authors service can be deployed without having to define a Dockerfile.


## Run in Red Hat OpenShift on the IBM Cloud

IBM provides a managed [Red Hat OpenShift](https://cloud.ibm.com/docs/containers?topic=containers-openshift_tutorial) offering on the IBM Cloud (beta). Get a free [IBM Cloud Lite](https://ibm.biz/nheidloff) account.

After you've created a new cluster, open the OpenShift console. From the dropdown menu in the upper right of the page, click 'Copy Login Command'. Paste the copied command in your local terminal, for example 'oc login https://c1-e.us-east.containers.cloud.ibm.com:23967 --token=xxxxxx'.

**Push code and build image**

```
$ cd ${ROOT_FOLDER}/authors-java-jee
$ oc new-project cloud-native-starter
$ oc new-build --name authors --binary --strategy docker
$ oc start-build authors --from-dir=.
```

**Deploy microservice**

```
$ cd ${ROOT_FOLDER}/authors-java-jee/deployment
$ sed "s+<namespace>+cloud-native-starter+g" deployment-template.yaml > deployment-template.yaml.1
$ sed "s+<ip:port>+docker-registry.default.svc:5000+g" deployment-template.yaml.1 > deployment-template.yaml.2
$ sed "s+<tag>+latest+g" deployment-template.yaml.2 > deployment-os.yaml
$ oc apply -f deployment-os.yaml
$ oc apply -f service.yaml
$ oc expose svc/authors
$ open http://$(oc get route authors -o jsonpath={.spec.host})/openapi/ui/
$ curl -X GET "http://$(oc get route authors -o jsonpath={.spec.host})/api/v1/getauthor?name=Niklas%20Heidloff" -H "accept: application/json"
```
