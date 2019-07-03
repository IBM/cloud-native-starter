#!/bin/bash

root_folder=$(cd $(dirname $0); cd ..; pwd)

exec 3>&1

function login() {
  eval $(minishift docker-env)
  oc login -u developer -p developer
  docker login -u developer -p $(oc whoami -t) $(minishift openshift registry)
  oc project cloud-native-starter
}

function _out() {
  echo "$(date +'%F %H:%M:%S') $@"
}

function configureVUEminikubeIP(){
  cd ${root_folder}/web-app-vuejs/src
  
  _out configure API endpoint in web-app
  istioingress=istio-ingressgateway-istio-system.$(minishift ip).nip.io

  rm "store.js"
  cp "store.js.template" "store.js"
  sed "s/endpoint-api-ip:31380/$istioingress/g" store.js.template > store.js
  
  cd ${root_folder}/web-app-vuejs
}

function setup() {
  _out Deploying web-app
  
  cd ${root_folder}/web-app-vuejs
  oc delete all -l app=web-app --ignore-not-found
  oc delete all -l app=web-app --ignore-not-found
  oc delete -f deployment/istio.yaml --ignore-not-found
  oc delete bc web-app --ignore-not-found
  oc delete build web-app-1 --ignore-not-found
  oc delete pod web-app-1-build --ignore-not-found
  oc delete istag web-app:latest --ignore-not-found

  configureVUEminikubeIP

  oc new-build --name web-app --binary --strategy docker
  oc start-build web-app --from-dir=.

  cd ${root_folder}/web-app-vuejs/deployment
  sed "s+web-app:1+$(minishift openshift registry)/cloud-native-starter/web-app:latest+g" kubernetes.yaml > kubernetes-minishift.yaml  

  oc apply -f kubernetes-minishift.yaml
  oc apply -f istio.yaml
  oc expose svc/web-app

  _out Done deploying web-app
  _out The build will take a while. Check with "oc get pod --watch | grep web-app"
  _out There will be 2 pods.
  _out The pod web-app-1-build must reach status Completed first.
  _out Until then the pod web-app-xxxxxxxxx-yyyyy will be in status ImagePullBackOff or ErrImagePull.
  _out Once it is Ready, access via http://$(oc get route web-app -o jsonpath={.spec.host})
  _out But it will NOT display content until you deploy the Istio Ingress configuration next for full functionality!

}

login
setup
