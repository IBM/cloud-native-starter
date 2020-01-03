#!/bin/bash

root_folder=$(cd $(dirname $0); cd ..; pwd)

exec 3>&1

function _out() {
  echo "$(date +'%F %H:%M:%S') $@"
}

function setup() {
  _out Deploying Istio Ingress definitions for web-api v1 only
  
  cd ${root_folder}/os4-scripts
  oc apply -f istio-ingress-gateway.yaml
  oc apply -f istio-ingress-service-web-api-v1-only.yaml
  
  _out Done deploying Istio Ingress definitions
}

setup
