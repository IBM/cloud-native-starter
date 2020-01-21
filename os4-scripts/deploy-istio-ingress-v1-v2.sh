#!/bin/bash

root_folder=$(cd $(dirname $0); cd ..; pwd)

exec 3>&1

function _out() {
  echo "$(date +'%F %H:%M:%S') $@"
}

function setup() {
  _out Deploying Istio Ingress definitions for web-api v1 and v2 80 20

  cd ${root_folder}/os4-scripts
  oc apply -f istio-ingress-gateway.yaml
  oc delete -f istio-ingress-service-web-api-v1-only.yaml --ignore-not-found
  oc apply -f istio-ingress-service-web-api-v1-v2-80-20.yaml
  
  _out Done deploying Istio Ingress definitions
}

source ${root_folder}/os4-scripts/login.sh
setup
