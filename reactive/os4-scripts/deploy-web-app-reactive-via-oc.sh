#!/bin/bash

root_folder=$(cd $(dirname $0); cd ..; pwd)

function _out() {
  echo "$(date +'%F %H:%M:%S') $@"
}

function setup() {
  _out Deploying web-app-reactive
  
  cd ${root_folder}/web-app-reactive
  oc delete -f deployment/os4-kubernetes.yaml --ignore-not-found
  oc delete route web-app-reactive --ignore-not-found
  oc delete is web-app-reactive --ignore-not-found
  
  route=$(oc get route web-api-reactive --template='{{ .spec.host }}')
  if [ -z "$route" ]; then
    _out web-api-reactive is not available. Run the command: sh os4-scripts/deploy-web-api-reactive.sh
    exit
  else 
    cd ${root_folder}/web-app-reactive/src
    sed "s/endpoint-api-ip:ingress-np/${route}/g" store.js.template > store.js

    cd ${root_folder}/web-app-reactive
    mv Dockerfile Dockerfile.k8s
    mv Dockerfile.os4 Dockerfile

    oc new-build --name web-app-reactive --binary --strategy docker
    oc start-build web-app-reactive --from-dir=.

    mv Dockerfile.k8s Dockerfile
    rm Dockerfile.os4
    
    sed -e "s+web-app-reactive:latest+image-registry.openshift-image-registry.svc:5000/cloud-native-starter/web-app-reactive:latest+g" \
      -e "s+  type: NodePort+\#  type: NodePort+g" \
      -e "s+        imagePullPolicy: Never+\#        imagePullPolicy: Never+g" \
      -e "s/ort: 80/ort: 8080/g" \
      deployment/kubernetes.yaml > deployment/os4-kubernetes.yaml
    oc apply -f deployment/os4-kubernetes.yaml
    oc expose svc/web-app-reactive
  
    route1=$(oc get route web-app-reactive --template='{{ .spec.host }}')
    _out Done deploying web-app-reactive
    _out Wait until the pod has been started: \"oc get pod --watch \| grep web-app-reactive\"
    _out Open the app: http://$route1/
  fi

}

setup
