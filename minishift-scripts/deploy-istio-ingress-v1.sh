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
  _out Deploying Istio Ingress

  cd ${root_folder}/minishift-scripts
  oc apply -f istio-ingress-gateway.yaml
  oc apply -f istio-ingress-service-web-api-v1-only.yaml

  _out Done Deploying Istio Ingress
}

login
setup
