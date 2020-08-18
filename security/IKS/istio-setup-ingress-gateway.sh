#!/bin/bash

function createSubDomain() {
  ingress_ip=$(kubectl get svc -n istio-system | awk '/istio-ingressgateway/ {print $4}')
  ibmcloud ks nlb-dns create classic --cluster $MYCLUSTER --ip $ingress_ip
}

function getIngressURL() {
 ingress_url=$(ibmcloud ks nlb-dns ls --cluster $MYCLUSTER | awk '/-0001./ {print $1}')
 export INGRESSURL=$ingress_url
 echo "------------------------------------------------------------------------"
 echo Ingress-URL: $INGRESSURL
 echo Cluster Name: $MYCLUSTER
 echo "------------------------------------------------------------------------"
}

createSubDomain
getIngressURL
