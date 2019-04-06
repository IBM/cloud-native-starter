#!/bin/bash

root_folder=$(cd $(dirname $0); cd ..; pwd)

function _out() {
  echo "$(date +'%F %H:%M:%S') $@"
}

function configureVUEminikubeIP(){
  cd ${root_folder}/web-app-vuejs/src
  
  _out configure API endpoint in web-app
  minikubeip=$(minikube ip)

  rm "store.js"
  cp "store.js.template" "store.js"
  sed "s/endpoint-api-ip/$minikubeip/g" store.js.template > store.js.1
  sed "s/endpoint-login-ip/$minikubeip/g" store.js.1 > store.js.2
  sed "s/endpoint-login-port/31380/g" store.js.2 > store.js.3
  sed "s/authentication-enabled-no/authentication-enabled-yes/g" store.js.3 > store.js
  rm store.js.1
  rm store.js.2
  rm store.js.3
  
  cd ${root_folder}/web-app-vuejs
}

function setup() {
  _out Deploying web-app-vuejs
  
  cd ${root_folder}/web-app-vuejs
  kubectl delete -f deployment/kubernetes.yaml --ignore-not-found
  kubectl delete -f deployment/istio.yaml --ignore-not-found
  
  configureVUEminikubeIP

  eval $(minikube docker-env) 
  docker build -f Dockerfile -t web-app:1 .

  kubectl apply -f deployment/kubernetes.yaml
  kubectl apply -f deployment/istio.yaml

  cd ${root_folder}/web-app-vuejs/src
  cp "store.js.template" "store.js"

  minikubeip=$(minikube ip)
  nodeport=$(kubectl get svc web-app --output 'jsonpath={.spec.ports[*].nodePort}')
  _out Minikube IP: ${minikubeip}
  _out NodePort: ${nodeport}
  
  _out Done deploying web-app-vuejs
  _out Wait until the pod has been started: "kubectl get pod --watch | grep web-app"
  _out Open the app: http://${minikubeip}:${nodeport}/
}

setupLog
setup