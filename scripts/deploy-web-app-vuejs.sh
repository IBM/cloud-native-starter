#!/bin/bash

root_folder=$(cd $(dirname $0); cd ..; pwd)

function _out() {
  echo "$(date +'%F %H:%M:%S') $@"
}

function configureVUEminikubeIP(){
  cd ${root_folder}/web-app-vuejs/src
  
  _out configure API endpoint in web-app
  minikubeip=$(minikube ip)
  _out Minikube IP - $minikubeip
  ingressport=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.spec.ports[?(@.name=="http2")].nodePort}')
  _out Istio Ingress NodePort - ${ingressport}

  rm "store.js"
  sed -e "s/endpoint-api-ip/$minikubeip/g" -e "s/ingress-np/${ingressport}/g" store.js.template > store.js
  
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

#  minikubeip=$(minikube ip)
#  nodeport=$(kubectl get svc web-app --output 'jsonpath={.spec.ports[*].nodePort}')
#  _out Minikube IP: ${minikubeip}
#  _out NodePort: ${nodeport}
  
  _out Done deploying web-app-vuejs
  _out Wait until the pod has been started: "kubectl get pod --watch | grep web-app"
  _out Open the app: http://${minikubeip}:${ingressport}/
}

setupLog
setup
