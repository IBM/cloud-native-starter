#!/bin/bash

root_folder=$(cd $(dirname $0); cd ..; pwd)

exec 3>&1

function _out() {
  echo "$(date +'%F %H:%M:%S') $@"
}

function setup() {
  _out Deploying articles-java-jee
  
  cd ${root_folder}/articles-java-jee
  kubectl delete -f deployment/kubernetes.yaml
  kubectl delete -f deployment/istio.yaml

  mvn clean
  mvn package
  docker build -t articles:1 .

  kubectl apply -f deployment/kubernetes.yaml
  kubectl apply -f deployment/istio.yaml

  minikubeip=$(minikube ip)
  nodeport=$(kubectl get svc articles --output 'jsonpath={.spec.ports[*].nodePort}')
  _out Minikube IP: ${minikubeip}
  _out NodePort: ${nodeport}
  
  _out Done deploying articles-java-jee
  _out Open the OpenAPI explorer: http://${minikubeip}:${nodeport}/openapi/ui/
}

setup