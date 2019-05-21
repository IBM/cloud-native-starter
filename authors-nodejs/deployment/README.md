* deployment.yaml

K8s deployment and service, you need to specify the URL for your specific Cloudant instance

Without automatic istio envoy injection:
`kubectl apply -f deployment.yaml`


* istio-egress-cloudant.yaml

Istio ServiceEntry, Gateway and DestinatonRule to access the Cloudant DB on IBM Cloud using https, you need to specify the host-part of the Cloudant URL (without user:password@) in 4 different places.

`istioctl create -f istio-egress-cloudant.yaml`


