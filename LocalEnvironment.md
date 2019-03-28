# Local Environment Setup

This document describes how to set up Minikube with Istio and Kiali to run cloud-native applications with multiple microservices locally.

After following these instructions you will be able to use the Kubernetes dashboard, Kiali, Jaeger, Grafana and Prometheus.


### Minikube

Follow the [instructions](https://kubernetes.io/docs/setup/minikube/) to install Minikube. After this run these commands:

```
$ minikube config set cpus 4
$ minikube config set memory 8192
$ minikube config set disk-size 50g
$ minikube start
$ eval $(minikube docker-env)
```

After this you can get the Minikube IP address and open the dashboard via these commands:

```
$ minikube ip
$ minikube dashboard
```

To stop the cluster run this command:

```
$ minikube stop
```


### Istio

To install Istio, run these commands:

```
$ curl -L https://git.io/getLatestIstio | sh -
# follow the instruction to set the path
# change into the Istio directory, at the time of this writing it was istio-1.1.1
$ cd istio-1.1.1
$ for i in install/kubernetes/helm/istio-init/files/crd*yaml; do kubectl apply -f $i; done
# wait a few seconds before issuing the next command
$ kubectl apply -f install/kubernetes/istio-demo.yaml
```

Check that all pods are running or completed before continuing.

```
$ kubectl get pod -n istio-system
```

Enable automatic sidecar injection:

```
$ kubectl label namespace default istio-injection=enabled
```

After this you can use the following tools:

[**Kiali Dashboard**](https://www.kiali.io/gettingstarted/)

With Istio 1.1.1 demo installation (this is what we used to setup Istio), Kiali is automatically installed.

```
kubectl -n istio-system port-forward $(kubectl -n istio-system get pod -l app=kiali -o jsonpath='{.items[0].metadata.name}') 20001:20001
```

http://localhost:20001/kiali/console

(User: admin, Password: admin)

[**Jaeger Dashboard**](https://www.jaegertracing.io/docs/1.6/getting-started/)

```
$ kubectl port-forward -n istio-system $(kubectl get pod -n istio-system -l app=jaeger -o jsonpath='{.items[0].metadata.name}') 16686:16686
```

http://localhost:16686

[**Grafana Dashboard**](https://grafana.com/dashboards)

```
$ kubectl -n istio-system port-forward $(kubectl -n istio-system get pod -l app=grafana -o jsonpath='{.items[0].metadata.name}') 3000:3000 &
```

http://localhost:3000/dashboard/db/istio-mesh-dashboard

[**Prometheus Dashboard**](https://prometheus.io/docs/practices/consoles/)

```
$ kubectl -n istio-system port-forward $(kubectl -n istio-system get pod -l app=prometheus -o jsonpath='{.items[0].metadata.name}') 9090:9090 &
```

http://localhost:9090



