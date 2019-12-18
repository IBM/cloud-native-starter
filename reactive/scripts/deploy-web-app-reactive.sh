#!/bin/bash

root_folder=$(cd $(dirname $0); cd ..; pwd)

function _out() {
  echo "$(date +'%F %H:%M:%S') $@"
}

function setup() {
  _out Deploying web-app-reactive
  
  cd ${root_folder}/web-app-reactive
  kubectl delete -f deployment/kubernetes.yaml --ignore-not-found
  
  minikubeip=$(minikube ip)
  nodeport=$(kubectl get svc web-api-reactive --ignore-not-found --output 'jsonpath={.spec.ports[*].nodePort}')
  if [ -z "$nodeport" ]; then
    _out web-api-reactive is not available. Run the command: sh scripts/deploy-web-api-reactive.sh
  else 
    cd ${root_folder}/web-app-reactive/src
    sed "s/endpoint-api-ip:ingress-np/${minikubeip}:${nodeport}/g" store.js.template > store.js

    cd ${root_folder}/web-app-reactive
    eval $(minikube docker-env) 
    docker build -f Dockerfile -t web-app-reactive:latest .

    kubectl apply -f deployment/kubernetes.yaml
  
    minikubeip=$(minikube ip)
    nodeport=$(kubectl get svc web-app-reactive --output 'jsonpath={.spec.ports[*].nodePort}')
    _out Done deploying web-app-reactive
    _out Wait until the pod has been started: "kubectl get pod --watch | grep web-app-reactive"
    _out Open the app: http://${minikubeip}:${nodeport}/
  fi

}

setup
