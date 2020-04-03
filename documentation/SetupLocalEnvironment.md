# Local Environment Setup

This document describes how to set up Minikube with Istio and Kiali to run cloud-native applications with multiple microservices locally.

After following these instructions you will be able to use the Kubernetes dashboard, Kiali, Jaeger, Grafana and Prometheus.


### Minikube

Follow the [instructions](https://kubernetes.io/docs/tasks/tools/install-minikube/) to install Minikube. 

This project has been tested with Minikube version 1.5.2. 

Once installed, run these commands:

```
$ minikube config set cpus 2
$ minikube config set memory 8192
$ minikube config set disk-size 50g
$ minikube start
$ eval $(minikube docker-env)
```

When Minikube is started you can get the IP address and open the Kubernetes dashboard with these commands:

```
$ minikube ip
$ minikube dashboard
```

To stop the cluster run this command:

```
$ minikube stop
```


### Istio

We used Istio 1.4.0 for this project. 

Note that the installation for Istio 1.4.0 has changed and also some commands, most notably those to open the Kiali, Jaeger, Prometheus, and Grafana dashboards were different in older Istio versions.

We will use `istioctl` to install Istio:

1. Download Istio, this will create a directory istio-1.4.0:

    ```
    curl -L https://git.io/getLatestIstio | ISTIO_VERSION=1.4.0 sh -
    ```

2. Add `istioctl` to the PATH environment variable, e.g copy paste in your shell and/or `~/.profile`. Follow the instructions in the installer message.


    ```
    export PATH="$PATH:/path/to/istio-1.4.0/bin"
    ```

3. Verify the `istioctl` installation:


    ```
    $ istioctl version 
    ```

4. Install Istio on Minikube:

    We will use the `demo` profile to install Istio. 

    **Note:** This is a "...configuration designed to showcase Istio functionality with modest resource requirements. ... **This profile enables high levels of tracing and access logging so it is not suitable for performance tests!**"

    ```
    $ istioctl manifest apply --set profile=demo
    ```


5. Check that all pods are running or completed before continuing.
  
    ```
    $ kubectl get pod -n istio-system
    ```

6. Verify Istio installation

    This generates a manifest file for the demo profile we used to install Istion and then verifies the installation against this profile.

    ```
    $ istioctl manifest generate --set profile=demo > generated-manifest.yaml
    $ istioctl verify-install -f generated-manifest.yaml
    ```

    Result of the second command (last 3 lines) looks like this:

     ```
     Checked 23 crds
	 Checked 9 Istio Deployments
	 Istio is installed successfully
	 ```
 
7. Enable automatic sidecar injection for `default`namespace:

    ```
    $ kubectl label namespace default istio-injection=enabled
    ```

After this you can use the following tools:

*(Please note that these commands do not work with Istio versions prior to 1.4.0! For prior versions check the Istio documentation.)*

[**Kiali Dashboard**](https://www.kiali.io/gettingstarted/)


```
$ istioctl dashboard kiali
```
(User: admin, Password: admin)

[**Jaeger Dashboard**](https://www.jaegertracing.io/docs/1.6/getting-started/)

```
$ istioctl dashboard jaeger
```


[**Grafana Dashboard**](https://grafana.com/dashboards)

```
$ istioctl dashboard grafana
```


[**Prometheus Dashboard**](https://prometheus.io/docs/practices/consoles/)

```
$ istioctl dashboard prometheus
```





