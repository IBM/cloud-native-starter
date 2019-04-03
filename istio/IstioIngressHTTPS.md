# Configure Istio Ingress for HTTPS

Following these [instructions](https://istio.io/docs/tasks/traffic-management/secure-ingress/mount/#configure-a-tls-ingress-gateway-with-a-file-mount-based-approach)

## Modify /etc/hosts on your notebook

TLS certificates are specific for a host, e.g. web-api.local. Use minikube ip and use the resulting IP@

/etc/hosts:
192.168.99.100   web-api.local

## Create TLS certificate

```
openssl req -x509 -newkey rsa:4096 -sha256 -nodes -keyout web-api.key -out web-api.crt \
    -subj "/CN=web-api.local" -days 365
```

## Create K8s key

In the directory where the certificate files are stored:

```
kubectl create -n istio-system secret tls istio-ingressgateway-certs --key web-api.key --cert web-api.crt
```

Verify (can take a few seconds to show up):

```
kubectl exec -it -n istio-system $(kubectl -n istio-system get pods -l istio=ingressgateway -o jsonpath='{.items[0].metadata.name}') -- ls -al /etc/istio/ingressgateway-certs

lrwxrwxrwx 1 root root   14 Apr  2 09:02 tls.crt -> ..data/tls.crt
lrwxrwxrwx 1 root root   14 Apr  2 09:02 tls.key -> ..data/tls.key
```

## Deploy Ingress configuration

First delete the HTTP, then create HTTPS config:

```
$ kubectl delete -f istio-ingress-gateway.yaml
$ kubectl delete -f istio-ingress-service-web-api-v1-only.yaml
$ kubectl apply -f istio-ingress-gateway-HTTPS.yaml
$ kubectl apply -f istio-ingress-service-web-api-v1-only-HTTPS.yaml
```

Web-App will not work as it still calls the HTTP-API, Web-API can be called like this:

```
curl --cacert web-api.crt https://web-api.local:31390/web-api/v1/getmultiple
```


