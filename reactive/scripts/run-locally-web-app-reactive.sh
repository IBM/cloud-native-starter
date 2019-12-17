#!/bin/bash

root_folder=$(cd $(dirname $0); cd ..; pwd)

exec 3>&1

function _out() {
  echo "$(date +'%F %H:%M:%S') $@"
}

function setup() {

  minikubeip=$(minikube ip)
  nodeport=$(kubectl get svc web-api-reactive --ignore-not-found --output 'jsonpath={.spec.ports[*].nodePort}')
  if [ -z "$nodeport" ]; then
    _out web-api-reactive is not available. Run the command: sh scripts/deploy-web-api-reactive.sh
  else 
    _out Press Ctrl-C to stop web-app-reactive
    _out Home page: http://localhost:8080/
    
    cd ${root_folder}/web-app-reactive/src
    sed "s/endpoint-api-ip:ingress-np/${minikubeip}:${nodeport}/g" store.js.template > store.js
  
    cd ${root_folder}/web-app-reactive
    yarn serve
  fi 
}

setup