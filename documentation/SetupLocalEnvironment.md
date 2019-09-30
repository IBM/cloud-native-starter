# Local Environment Setup

This document describes how to set up Minikube with Istio and Kiali to run cloud-native applications with multiple microservices locally.

After following these instructions you will be able to use the Kubernetes dashboard, Kiali, Jaeger, Grafana and Prometheus.


### Minikube

Follow the [instructions](https://kubernetes.io/docs/setup/minikube/) to install Minikube. This project has been tested with Minkube version 1.0.1. After this run these commands:

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

To install Istio, follow these instructions. We use Istio 1.3.0 for this project.

1. Download Istio, this will create a directory istio-1.3.0:
   ```
   curl -L https://git.io/getLatestIstio | ISTIO_VERSION=1.3.0 sh -
   ```

3. Add `istioctl` to the PATH environment variable, e.g copy paste in your shell and/or `~/.profile`. Follow the instructions in the installer message.

    ```
    export PATH="$PATH:/path/to/istio-1.3.0/bin"
    ```

4. Verify the Istio installation:

   ```
   $ istioctl verify-install
   ```

5. Change into the Istio directory: 

   ```
   $ cd istio-1.3.0
   ```

6. Install Istio on Minikube:

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

With recent Istio versions, Kiali is automatically installed together with Istio.

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



