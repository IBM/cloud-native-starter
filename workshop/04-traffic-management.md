[home](README.md)
# Using traffic management in Kubernetes with Istio

****** **UNDER CONSTRUCTION** ******

The “Cloud Native Starter” shows a sample polyglot microservices application with Java and Node.js on Kubernetes using Istio for traffic management, tracing, metrics, fault injection, fault tolerance, etc.

There are currently not many Istio examples available, the one most widely used is probably [Istio’s own “Bookinfo”](https://developer.ibm.com/solutions/container-orchestration-and-deployment/?cm_mmc=Search_Google-_-Developer_IBM+Developer-_-WW_EP-_-%2Bistio_b&cm_mmca1=000019RS&cm_mmca2=10004796&cm_mmca7=9041823&cm_mmca8=aud-396679157191:kwd-448983149697&cm_mmca9=_k_EAIaIQobChMIq_ynq8yi4gIVrDLTCh1T2g9AEAAYASAAEgIVAfD_BwE_k_&cm_mmca10=322762525080&cm_mmca11=b&gclid=EAIaIQobChMIq_ynq8yi4gIVrDLTCh1T2g9AEAAYASAAEgIVAfD_BwE) sample or the [Red Hat Istio tutorial](https://github.com/redhat-developer-demos/istio-tutorial). 

These other tutorials and examples do mostly the request routing not as a part for a user-facing service directly behind the Istio ingress.

In this part we create a new instance and version of the web-api microservice.

![git](images/traffic-new-architecture.gif)

New we configure the routing to split the usage between our two instances and versions of our web-api microservice.

![gif](images/traffic-routing.gif)


Now, we've finished the **Using traffic management in Kubernetes**.
Let's get started with the [Lab - Resiliency](05-resiliency.md).

---

Resources:

* ['Managing Microservices Traffic with Istio'](https://haralduebele.blog/2019/03/11/managing-microservices-traffic-with-istio/)
* ['Demo: Traffic Routing'](../documentation/DemoTrafficRouting.md)