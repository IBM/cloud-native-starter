#!/bin/bash

root_folder=$(cd $(dirname $0); cd ..; pwd)

exec 3>&1

function _out() {
  echo "$(date +'%F %H:%M:%S') $@"
}

function setup() {
  _out Deleting web-api-java-jee
  
  cd ${root_folder}/web-api-java-jee
  kubectl delete -f deployment/kubernetes.yaml
  kubectl delete -f deployment/istio.yaml
  
  _out Done deleting web-api-java-jee
}

setup