**--------------------------------------------**
**-------------UNDER CONSTRUCTION-------------**
**--------------------------------------------**

### Setup Istio on your Red Hat OpenShift Cluster

### Istio and OpenShift

### Step 1: Logon to the Cluster

```sh
oc login --token=TOKEN --server=https://URL
```

### Step 2: Create new Project

```sh
oc new-project istio-system
```

#### Step 2: **Overview** [Red Hat OpenShift Service Mesh installation activities](https://access.redhat.com/documentation/en-us/openshift_container_platform/4.5/html/service_mesh/service-mesh-1-x#ossm-kiali-service-mesh_ossm-vs-istio-v1x) 

To install the Red Hat OpenShift Service Mesh Operator, you must first install these Operators:

* **Elasticsearch** - Based on the open source Elasticsearch project that enables you to configure and manage an Elasticsearch cluster for tracing and logging with Jaeger.
* **Jaeger** - based on the open source Jaeger project, lets you perform tracing to monitor and troubleshoot transactions in complex distributed systems.
* **Kiali** - based on the open source Kiali project, provides observability for your service mesh. By using Kiali you can view configurations, monitor traffic, and view and analyze traces in a single console.

>After you install the Elasticsearch, Jaeger, and Kiali Operators, then you install the Red Hat OpenShift Service Mesh Operator. The Service Mesh Operator defines and monitors the ServiceMeshControlPlane resources that manage the deployment, updating, and deletion of the Service Mesh components.

* **Red Hat OpenShift Service Mesh** - based on the open source Istio project, lets you connect, secure, control, and observe the microservices that make up your applications.

#### Step 2: Install Istio that means  - here the detailed steps

Follow the documentation [Installing Red Hat OpenShift Service Mesh](https://access.redhat.com/documentation/en-us/openshift_container_platform/4.5/html-single/service_mesh/index#installing-ossm-v1x). 
The steps starting form 1.5 are relevant

> Notes: Ensure you have done following tasks

* Add the `cloud-native-starter` project to the `ServiceMeshMemberRoll`
* Verify that you can access `Kiali` under `Administrator->Networking->Routes->Kiali`
* Verify that you get the Istio Gateway URL
```sh
export ISTIO_GATEWAY_URL=$(oc -n istio-system get route istio-ingressgateway -o jsonpath='{.spec.host}')
echo $ISTIO_GATEWAY_URL
```
* Verify the Istio Gateway and Virtual Service configruation file in folder `helm/webapp/templates/istio-virtual-service.yaml` 

