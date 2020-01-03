#!/bin/bash

root_folder=$(cd $(dirname $0); cd ..; pwd)

function _out() {
  echo "$(date +'%F %H:%M:%S') $@"
}

function configureVUEminikubeIP(){
  cd ${root_folder}/web-app-vuejs/src
  
  _out --- Configure API endpoint in web-app
  
  ingressgw=$(oc get route istio-ingressgateway -n istio-system --template='{{ .spec.host }}')
  _out ----  Istio Ingress Gateway - ${ingressgw}

  rm "store.js"
  sed -e "s/endpoint-api-ip:ingress-np/$ingressgw/g" store.js.template > store.js
  
  cd ${root_folder}/web-app-vuejs
}

function setup() {
  _out --- Deploying web-app-vuejs
  
  _out --- Cleanup
  cd ${root_folder}/web-app-vuejs
  oc delete -f deployment/kubernetes.yaml --ignore-not-found
  oc delete -f deployment/istio.yaml --ignore-not-found
  oc delete build web-app-1
  oc delete is web-app
  
  configureVUEminikubeIP

  _out --- OpenShift Binary Build
  cp Dockerfile Dockerfile.ORG 
  cp Dockerfile.os4 Dockerfile
  oc new-build --name web-app --binary --strategy docker -l app=web-app
  oc start-build web-app --from-dir=.
  cp Dockerfile.ORG Dockerfile

  _out --- Deploying to OpenShift
  sed -e "s+web-app:1+$REGISTRY/$PROJECT/web-app:latest+g" -e "s/ort: 80/ort: 8080/g" deployment/kubernetes.yaml > deployment/os4-kubernetes.yaml
  oc apply -f deployment/os4-kubernetes.yaml
  oc apply -f deployment/istio.yaml
  oc expose svc/web-app 

  _out Done deploying web-app-vuejs
  _out Wait until the build pod web-app-1-build is Completed and the pod itself has been started: 
  _out "oc get pod --watch | grep web-app"
  _out Open the app: http://${ingressgw}/
}

source ${root_folder}/os4-scripts/login.sh
setup
