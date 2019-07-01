#!/bin/bash

root_folder=$(cd $(dirname $0); cd ..; pwd)

exec 3>&1

function login() {
  oc login -u developer -p developer
  oc project cloud-native-starter
}

function _out() {
  echo "$(date +'%F %H:%M:%S') $@"
}

function setup() {
  _out Deleting Istio Ingress definitions
  
  cd ${root_folder}/istio
  oc delete -f istio-ingress-gateway.yaml --ignore-not-found
  oc delete -f istio-ingress-service-web-api-v1-v2-80-20.yaml --ignore-not-found
  
  _out Done deleting Istio Ingress definitions
}

login
setup