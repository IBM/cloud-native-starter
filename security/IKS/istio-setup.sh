#!/bin/bash

STATUS="Running"

function installIstio() {
  echo "------------------------------------------------------------------------"
  echo "Install Istio"
  echo "------------------------------------------------------------------------"
  istioctl operator init
  kubectl create ns istio-system
  kubectl apply -f IKS/istio.yaml
  echo "Waiting for Istio pods to start"
  sleep 20
  kubectl get pod -n istio-system
}

function checkIstioInstallation() {
  array=("grafana" "istiod" "prometheus" "istio-egressgateway" "istio-ingressgateway" "istio-tracing")
  for i in "${array[@]}"
  do 
    echo ""
    echo "------------------------------------------------------------------------"
    echo "Check $i"
    while :
    do
        FIND=$i
        STATUS_CHECK=$(kubectl get pod -n istio-system | grep $FIND | awk '{print $3}')
        echo "Status: $STATUS_CHECK"
        if [ "$STATUS" = "$STATUS_CHECK" ]; then
            echo "$(date +'%F %H:%M:%S') Status: $FIND is Ready"
            echo "------------------------------------------------------------------------"
            break
        else
            echo "$(date +'%F %H:%M:%S') Status: $FIND($STATUS_CHECK)"
            echo "------------------------------------------------------------------------"
        fi
        sleep 5
    done
  done
}

function setuptelemetry() {
 echo "------------------------------------------------------------------------"
 echo "Replace telemetry config to expose nodeports"
 echo "------------------------------------------------------------------------"
 kubectl delete svc grafana -n istio-system
 kubectl delete svc kiali -n istio-system
 kubectl delete svc prometheus -n istio-system
 kubectl delete svc jaeger-query -n istio-system
 kubectl apply -f IKS/istio-tele-services.yaml
 echo " "
}

function configNamespace() {
 echo "------------------------------------------------------------------------"
 echo "Label namespace 'default' for auto injection"
 kubectl label namespace default istio-injection=enabled
 echo "------------------------------------------------------------------------"
 echo " "
}

installIstio
checkIstioInstallation
#setuptelemetry  // we don't use Kiali in this exercise (kubectl port-forward svc/kiali 3000:20001 -n istio-system)
configNamespace