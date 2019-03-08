## Istio Deploy

1. Destination Rules `istioctl create -f destinationrule.yaml`
2. Virtual Service wep-api `istioctl create -f istio-service-web-api-v1-v2-weighted.yaml`
3. Virtual Service articles `istioctl create -f istio-service-articles-v1.yaml.yaml`
4. Virtual Services authors `istioctl create -f istio-service-authors-v1.yaml`
5. Ingress `istioctl create -f istio-ingress.yaml`


Access via istio-ingresscontroller (Port is always 31380):
curl  "http://192.168.99.100:31380/web-api/v1/getmultiple"

