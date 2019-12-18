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
  sed -e "s/endpoint-api-ip:ingress-np/$ingressgw/g"  store.js.template > store.js
  
  cd ${root_folder}/web-app-vuejs
}

function setup() {
  _out --- Deploying web-app-vuejs
  
  _out --- Cleanup
  cd ${root_folder}/web-app-vuejs
  oc delete -f deployment/kubernetes.yaml --ignore-not-found
  oc delete -f deployment/istio.yaml --ignore-not-found
  oc delete is web-app
  
  configureVUEminikubeIP

  _out --- Build Docker image
  docker build -f Dockerfile.nonroot -t web-app:1 .
  docker tag web-app:1 $REGISTRYURL/$PROJECT/web-app:1
  docker push $REGISTRYURL/$PROJECT/web-app:1

  _out --- Deploying to OpenShift
  sed "s+web-app:1+$REGISTRY/$PROJECT/web-app:1+g" deployment/kubernetes.yaml > deployment/os4-kubernetes.yaml
  oc apply -f deployment/os4-kubernetes.yaml
  oc apply -f deployment/istio.yaml

  _out Done deploying web-app-vuejs
  _out Wait until the pod has been started: "kubectl get pod --watch | grep web-app"
  _out Open the app: http://${ingressgw}/
}

source ${root_folder}/os4-scripts/login.sh
setup
