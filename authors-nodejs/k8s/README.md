* deployment.yaml

K8s deployment and service, you need to specify the URL for your specific Cloudant instance

Without automatic istio envoy injection:
`kubectl apply -f <(istioctl kube-inject -f deployment.yaml)`


* istio-egress-cloudant.yaml

Istio ServiceEntry and VirtualService to access any Cloudant DB on IBM Cloud using https through generic URL 

`istioctl create -f istio-egress-cloudant.yaml`


