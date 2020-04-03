### Standard Kubernetes Cluster on IBM Cloud

A Standard (paid) Kubernetes Cluster has a K8s Ingress available together with a default Ingress subdomain. This is not available with free (lite) clusters!


```
$ ibmcloud ks cluster-get <clustername>
```

It has the form 'clustername'.'region'.containers.appdomain.cloud and also has generic subdomains registered in the DNS (*.'clustername'.'region'.containers.appdomain.cloud). We can use this to enable the Kubernetes Ingress as some form of proxy to the Istio Ingress, using this configuration (template.k8s-ingress.yaml):


```
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
 name: cloudnative-ingress
 namespace: istio-system
spec:
 rules:
 - host: cloudnative.'clustername'.'region'.containers.appdomain.cloud 
   http:
     paths:
     - path: /
       backend:
         serviceName: istio-ingressgateway
         servicePort: 80
```

Edit the spec.rules.host variable to reflect your clusters subdomain and deploy the yaml file with kubectl.

Access the app with http://cloudnative.'clustername'.'region'.containers.appdomain.cloud

