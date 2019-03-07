#!/bin/bash

root_folder=$(cd $(dirname $0); cd ..; pwd)

exec 3>&1

function _out() {
  echo "$(date +'%F %H:%M:%S') $@"
}

function setup() {
  _out Deploying web-app-vuejs
  
  cd ${root_folder}/web-app-vuejs
  kubectl delete -f deployment/kubernetes.yaml
  kubectl delete -f deployment/istio.yaml

  eval $(minikube docker-env) 
  docker build -f Dockerfile -t web-app:1 .

  kubectl apply -f deployment/kubernetes.yaml
  kubectl apply -f deployment/istio.yaml

  minikubeip=$(minikube ip)
  nodeport=$(kubectl get svc web-app --output 'jsonpath={.spec.ports[*].nodePort}')
  _out Minikube IP: ${minikubeip}
  _out NodePort: ${nodeport}
  
  _out Done deploying web-app-vuejs
  _out Open the app: http://${minikubeip}:${nodeport}/
}

setup