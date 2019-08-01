#!/bin/bash

root_folder=$(cd $(dirname $0); cd ..; pwd)

exec 3>&1

function _out() {
  echo "$(date +'%F %H:%M:%S') $@"
}

function setup() {
  _out Deploying authors-java-spring-boot
  
  cd ${root_folder}/authors-java-spring-boot
  kubectl delete -f deployment/kubernetes.yaml --ignore-not-found
  kubectl delete -f deployment/istio.yaml --ignore-not-found
  
  eval $(minikube docker-env) 
  docker build -f Dockerfile.nojava -t authors:1 .

  kubectl apply -f deployment/kubernetes.yaml
  kubectl apply -f deployment/istio.yaml

  minikubeip=$(minikube ip)
  nodeport=$(kubectl get svc authors --output 'jsonpath={.spec.ports[*].nodePort}')
  _out Minikube IP: ${minikubeip}
  _out NodePort: ${nodeport}
  
  _out Done deploying authors-java-spring-boot
  _out Wait until the pod has been started: "kubectl get pod --watch | grep authors"
  _out Open the Swagger explorer: http://${minikubeip}:${nodeport}/swagger-ui.html
}

setup