# Local Environment Setup

This document describes how to set up Minikube with Istio and Kiali to run cloud-native applications with multiple microservices locally.

After following these instructions you will be able to use the Kubernetes dashboard, Kiali, Jaeger, Grafana and Prometheus.


### Minikube

Follow the [instructions](https://kubernetes.io/docs/setup/minikube/) to install Minikube. This project has been tested with Minkube version 0.33.1. After this run these commands:

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

To install Istio, follow these instructions. We use Istio 1.1.1 for this project.

1. Download Istio 1.1.1 directly from [Github](https://github.com/istio/istio/releases/tag/1.1.1). Select the version that matches your OS. (Please be aware that we do not cover Windows in these instructions!)
Result: istio-1.1.1-osx|linux.tar.gz

2. Extract the installation files, e.g.:

    ```
    tar -xvzf istio-1.1.1-linux.tar.gz
    ```
    
3. Add `istioctl` to the PATH environment variable, e.g copy paste in your shell and/or `~/.profile`:

    ```
    export PATH=$PWD/istio-1.1.1/bin:$PATH
    ```

4. Change into the extracted directory: `cd istio-1.1.1`

5. Install Istio:

    ```
    $ for i in install/kubernetes/helm/istio-init/files/crd*yaml; do kubectl apply -f $i; done
    ```
    
    Wait a few seconds before issuing the next command:

    ```
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

With an Istio 1.1.1 demo installation (this is what we used to setup Istio), Kiali is automatically installed.

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



