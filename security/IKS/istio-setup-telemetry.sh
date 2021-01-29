#!/bin/bash

function setuptelemetry() {
 echo "------------------------------------------------------------------------"
 echo "Replace telemetry config to expose nodeports"
 echo "------------------------------------------------------------------------"
 kubectl delete svc grafana -n istio-system
 kubectl delete svc kiali -n istio-system
 kubectl delete svc prometheus -n istio-system
 kubectl delete svc jaeger-query -n istio-system
 kubectl apply -f ./istio-tele-services.yaml
 echo " "
}

function showCommands () {
 echo "You can use following commands to access telemetry data"
 echo "in the IBM Cloud Shell to forward them to port '3000'"
 echo "-----------------------Grafana-----------------------------------------------"
 echo "kubectl port-forward svc/grafana 3000:3000 -n istio-system"
 echo "-----------------------Prometheus--------------------------------------------"
 echo "kubectl port-forward svc/prometheus 3000:9090 -n istio-system"
 echo "-----------------------Jaeger------------------------------------------------"
 echo "kubectl port-forward svc/jaeger-query 3000:16686 -n istio-system"

}

setuptelemetry
showCommands