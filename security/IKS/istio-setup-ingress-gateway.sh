#!/bin/bash

function createSubDomain {
  cd $ROOT_FOLDER/IKS
  ingress_ip=$(kubectl get svc -n istio-system | grep istio-ingressgateway | awk '{print $4}')
  ibmcloud ks nlb-dns create classic --cluster $MYCLUSTER --ip $ingress_ip
}

function getIngressURL {
 ingress_url=$(ibmcloud ks nlb-dns ls --cluster $MYCLUSTER | grep 0001 | awk '{print $1}')
 export INGRESSURL=$ingress_url
 echo "------------------------------------------------------------------------"
 echo Ingress-URL: $INGRESSURL
 echo Cluster Name: $MYCLUSTER
 echo "------------------------------------------------------------------------"
}

createSubDomain
getIngressURL
