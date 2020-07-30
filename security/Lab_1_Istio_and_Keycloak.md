# Install Istio and Keycloak

We need Keycloak for authentication and authorization. And we need Istio to secure access to our services. In this exercise we will:

1. Install Istio on the IBM Cloud Kubernetes Service (IKS).  
2. We will use the Istio Ingress gateway to gain access to our sample application and to Keycloak externally with a DNS entry.
3. We will secure the Istio Ingress gateway with HTTPS using a certificate that is automatically generated.
4. Install Keycloak within the Istio Service Mesh.

---

## 1. Install Istio

Normally in a production size Kubernetes cluster on IBM Cloud we would install Istio as an Add-On. There are 5 Kubernetes add-ons available: Istio, Knative, Kubernetes Terminal, Diagnostic and Debug Tools, and Static Route. Istio installed via the add-on is a managed service and it creates a production grade Istio instance and it requires a cluster with at least 3 worker nodes with 4 CPUs and 16 GB of memory which our lab Kubernetes cluster doesn't have.

Instead, in this lab we will install the Istio demo profile manually using `istioctl` and its standalone operator. `istioctl` is available in IBM Cloud Shell, when I wrote these instructions it was at version 1.5.4 which means we will install Istio 1.5.4.

DRAFT

1. "Get environment": cluster name, cluster ip@
   
   ```
     cd IKS
     getenv.sh    <<<< funktioniert nur im Lab (1 cluster)
     source local.env
   ```
   
   --> Data in local.env 

/DRAFT

1. Execute the following commands:
   
   ```
    istioctl operator init
    kubectl create ns istio-system
    kubectl apply -f istio.yaml
   ```
   
    These commands install the Istio operator, create a namespace for the Istio backplane, and start to install the Istio backplane.

2. Check the status of Istio:
   
   ```
    kubectl get pod -n istio-system 
   ```
   
    When install completed the result should look like this:
   
   ```
    NAME                                    READY   STATUS    RESTARTS   AGE
    grafana-5cc7f86765-65fc6                1/1     Running   0          3m28s
    istio-egressgateway-5c8f9897f7-s8tfq    1/1     Running   0          3m32s
    istio-ingressgateway-65dd885d75-vrcg8   1/1     Running   0          3m29s
    istio-tracing-8584b4d7f9-7krd2          1/1     Running   0          3m13s
    istiod-7d6dff85dd-29mjb                 1/1     Running   0          3m29s
    kiali-696bb665-8rrhr                    1/1     Running   0          3m12s
    prometheus-564768879c-2r87j             2/2     Running   0          3m12s
   ```

3. We will be using the Kiali dashboard during this workshop. With `istioctl dashboard xxx` it is easy to access Kiali and the other telemetry services. Unfortunately, the required port-forwarding doesn't work in IBM Cloud Shell. We will now enable NodePorts for those services with a script / hack:
   
   ```
    ./telemetry.sh
   ```
   
    This will delete and recreate the Kubernetes service objects for the telemetry services. The recreated services will then expose a NodePort. The command will also enable Istio sidecar auto-injection on the 'default' namespace. 

<!--    Check with:

    ```
    kubectl get svc -n istio-system
    NAME                        TYPE           CLUSTER-IP       EXTERNAL-IP    PORT(S)                                                                      AGE
    grafana                     ClusterIP      172.21.147.225   <none>         3000/TCP                                                                     65s
    istio-egressgateway         ClusterIP      172.21.200.119   <none>         80/TCP,443/TCP,15443/TCP                                                     7m17s
    istio-ingressgateway        LoadBalancer   172.21.78.193    169.51.69.11   15020:30508/TCP,80:31048/TCP,443:31663/TCP,31400:31033/TCP,15443:30645/TCP   7m17s
    istiod                      ClusterIP      172.21.192.243   <none>         15010/TCP,15012/TCP,443/TCP,15014/TCP,853/TCP                                7m22s
    jaeger-agent                ClusterIP      None             <none>         5775/UDP,6831/UDP,6832/UDP                                                   7m13s
    jaeger-collector            ClusterIP      172.21.22.37     <none>         14267/TCP,14268/TCP,14250/TCP                                                7m13s
    jaeger-collector-headless   ClusterIP      None             <none>         14250/TCP                                                                    7m13s
    jaeger-query                NodePort       172.21.71.168    <none>         16686:31003/TCP                                                              64s
    kiali                       ClusterIP      172.21.123.26    <none>         20001/TCP                                                                    64s
    prometheus                  NodePort       172.21.59.193    <none>         9090:30272/TCP                                                               64s
    tracing                     ClusterIP      172.21.9.235     <none>         80/TCP                                                                       7m13s
    zipkin                      ClusterIP      172.21.81.81     <none>         9411/TCP                                                                     7m13s
  ```
-->

DRAFT
Das Ersetzen des Services für NodePort funktioniert mit Kiali nicht mehr ... wird wieder überschrieben. Muss ich was überlegen ...
/DRAFT

---

## 2. Expose the Istio Ingress gateway via DNS

The following procedures are platform specific and work with a "standard classic" Kubernetes Cluster provided by the IBM Cloud Kubernetes Service (IKS) on the IBM Cloud. If you are using a VPC based or a free ("Lite") Kubernetes Cluster on the IBM Cloud or another Cloud provider or something like Minikube, the following sections will **not** work! 

When we install Istio on our pre-provisioned Kubernetes Clusters on IBM Cloud, the Istio Ingress is created with a Kubernetes service of type LoadBalancer and is assigned a "floating" IP address through which it can be reached via the public Internet. You can determine this address with the following command:

```
kubectl get svc -n istio-system | grep istio-ingressgateway
```

The output should look like this:

```
istio-ingressgateway   LoadBalancer  172.21.213.52  149.***.131.***   15020:31754/TCP,...
```

Our Ingress gateway is in fact of type LoadBalancer, the second IP address is the external (public) IP address. This is the `ingressIP` in the next command. 

To create a DNS subdomain, a URL, for the Ingress gateway (= loadbalancer, nlb) use the following command:

```
ibmcloud ks nlb-dns create classic --cluster $MYCLUSTER --ip <ingressIP>
```

The output should look like this:

```
OK
NLB hostname was created as harald-uebele-k8s-fra05-********************-0001.eu-de.containers.appdomain.cloud
```

The new subdomain will have the form `[cluster name]-[globally unique hash]-[region]-containers.appdomain.cloud`.

Save this name in another variable in `local.env`, e.g.:

```
INGRESSURL=harald-uebele-k8s-fra05-********************-0001.eu-de.containers.appdomain.cloud
```

## 3. Expose the Istio Ingress gateway via DNS with TLS enabled

In the last section we have created a DNS entry for the Ingress controller. But access to our resources was using unsecure HTTP on port 80. In this section we enable secure HTTPS access on port 443.

The procedure we will use in this section is documented [here](https://cloud.ibm.com/docs/containers?topic=containers-istio-mesh#istio_expose_bookinfo_tls).

There is also generic documentation about [Secure Gateways](https://istio.io/latest/docs/tasks/traffic-management/ingress/secure-ingress/) available in the Istio documentation.

The Istio Ingress gateway on the IBM Cloud is of type LoadBalancer and in the last section we created a **DNS subdomain** for it. This also **automatically generates a Let's Encrypt certificate for HTTPS/TLS traffic** and creates a Kubernetes secret containing this certificate. We need to pull the certificate from this secret, change its name, and create a new secret so that the Istio Ingress gateway can use it. 

List the DNS subdomains:

```
ibmcloud ks nlb-dns ls --cluster $MYCLUSTER
```

You should see 2 entries, the first is for the Kubernetes Ingress that is created for you when the cluster is created.

The second is the Istio Ingress subdomain you created in the last section. Copy the "SSL Cert Secret Name" (should end on -0001) and paste it into another environment variable:

```
INGRESSSECRET=harald-uebele-k8s-fra05-********************-0001
```

Pull the secret and save it into a file 'mysecret.yaml':

```
kubectl get secret $INGRESSSECRET --namespace default --export -o yaml > mysecret.yaml
```

The secret was created in the 'default' namespace. In order to use it with Istio, we want to modify the name and place it in the 'istio-system' namespace.

Open the mysecret.yaml file in an editor (nano, vim), change the value of `name:` from the secret name to `istio-ingressgateway-certs` and save the file. It should look similar to this example:

```
apiVersion: v1
data:
  tls.crt: LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk...
  tls.key: LS0tLS1CRUdJTiBSU0EgUFJJVkFURSBLRVktLS...
kind: Secret
metadata:
  annotations:
    ingress.cloud.ibm.com/cert-source: ibm
    kubectl.kubernetes.io/last-applied-configuration: |
      {"apiVersion":"v1","data":{"tls.crt":"LS0tLS1CRUdJTiBDRVJUSUZJQ0FU...
  creationTimestamp: null
  name: istio-ingressgateway-certs
  selfLink: /api/v1/namespaces/default/secrets/harald-uebele-k8s-***************-0001
type: Opaque
```

Then load and activate the secret with these commands:

```
kubectl apply -f ./mysecret.yaml -n istio-system
kubectl delete pod -n istio-system -l istio=ingressgateway
```

The last command deletes the Istio Ingress pod to force it to reload the newly created secret.

Edit the file `istio-ingress-tls.yaml` in the istio directory. Replace the 2 occurances of wildcard "*", one in the Gateway, one in the VirtualService definition:

```
hosts:
- "*"
```

with the $INGRESSURL you obtained in the last section:

```
hosts:
- "harald-uebele-k8s-fra05-**********-0001.eu-de.containers.appdomain.cloud"
```

Watch out for the correct indents, this is YAML!

Apply the change with:

```
kubectl apply -f istio-ingress-tls.yaml
```

Note: This last step, replacing the wildcard host "*" with the correct DNS name, is not really necessary. But now you have a correct configuration that is secure.

`istio-ingress-tls.yaml` creates an Istio Gateway configuration using the TLS certificate stored in a Kubernetes secret. It also generates a VirtualService definition for this Gateway with routes to services that do not exist at the moment.

There is a blog on the Istio page that describes how to [Direct encrypted traffic from IBM Cloud Kubernetes Service Ingress to Istio Ingress Gateway](https://istio.io/latest/blog/2020/alb-ingress-gateway-iks/). With this scenario you can have non-Istio secured services communicate with services secured by Istio, e.g. while you are migrating your application into Istio.

This blog contains an important piece of information regarding the Let's Encrypt certificates used:

> The certificates provided by IKS expire every 90 days and are automatically renewed by IKS 37 days before they expire. You will have to recreate the secrets by rerunning the instructions of this section every time the secrets provided by IKS are updated. You may want to use scripts or operators to automate this and keep the secrets in sync.

---

## 4. Install Keycloak

**Installation basics:**

[Keycloak - Guide - Keycloak on Kubernetes](https://www.keycloak.org/getting-started/getting-started-kube)

We have Istio installed and will be using the Istio Ingress to access Keycloak externally.

**Deployment:**

We have modified the original `keycloak.yaml` and removed NodePort. Install Keycloak:

```bash
kubectl apply -f keycloak.yaml
```

Wait until the Keycloak pod is started. 

**Access Keycloak:**

Then, in your browser, open this URL:

```bash
echo "https://"$INGRESSURL"/auth"
```

**This is the Keycloak URL you will need in the following exercises!** 

Click on 'Administration Console'. Login In with username 'admin' and password 'admin'.

**Configuration:**

Move your mouse pointer over 'Master' in the upper left corner and click the blue 'Add realm' button.

DRAFT
Wir müssen uns überlegen, wo die JSON file herkommt, im Zweifel aus der Cloud Shell runterladen oder per wget aus unserem Github Repo ... 
/DRAFT

In the 'Add realm' dialog click 'Select file', open the 'quarkus-realm.json' file, then click 'Create'.

You should see a message pop up: "Success! Realm created"

Try to create an access token, this requires the $INGRESSURL environment variable to be set:

```bash
curl -sk --data "username=alice&password=alice&grant_type=password&client_id=frontend" \
        https://$INGRESSURL/auth/realms/quarkus/protocol/openid-connect/token  \
        | jq ".access_token" | sed 's|"||g'
```
