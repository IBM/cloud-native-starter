#!/bin/bash

root_folder=$(cd $(dirname $0); cd ..; pwd)

exec 3>&1

function _out() {
  echo "$(date +'%F %H:%M:%S') $@"
}

function setup() {
  _out Deleting articles-java-jee-quarkus
  
  cd ${root_folder}/articles-java-jee
  kubectl delete -f deployment/kubernetes-quarkus.yaml
  kubectl delete -f deployment/istio-quarkus.yaml
  
  _out Done deleting articles-java-jee-quarkus
}

setup