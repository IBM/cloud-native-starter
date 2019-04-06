#!/bin/bash

root_folder=$(cd $(dirname $0); cd ..; pwd)

exec 3>&1

function _out() {
  echo "$(date +'%F %H:%M:%S') $@"
}

function setup() {
  _out Deploying authentication-nodejs
  
  cd ${root_folder}/authentication-nodejs
  kubectl delete -f deployment/kubernetes.yaml --ignore-not-found
  kubectl delete -f deployment/istio.yaml --ignore-not-found
  kubectl delete -f deployment/istio-egress.yaml --ignore-not-found
  
  cd ${root_folder}/authentication-nodejs
  eval $(minikube docker-env)
  docker build -f Dockerfile -t authentication:1 .

  cd ${root_folder}/authentication-nodejs/deployment
  kubectl apply -f kubernetes.yaml
  kubectl apply -f istio.yaml
  kubectl apply -f istio-egress.yaml

  minikubeip=$(minikube ip)
  nodeport=$(kubectl get svc authentication --output 'jsonpath={.spec.ports[*].nodePort}')
  _out Minikube IP: ${minikubeip}
  _out NodePort: ${nodeport}

  _out Done deploying authentication-nodejs
  _out Wait until the pod has been started: "kubectl get pod --watch | grep authentication"
  _out Login URL: http://${minikubeip}:31380/login
}

setup