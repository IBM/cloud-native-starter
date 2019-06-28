#!/bin/bash

root_folder=$(cd $(dirname $0); cd ..; pwd)

exec 3>&1

function login() {
  oc login -u developer -p developer
  oc project cloud-native-starter
}

function _out() {
  echo "$(date +'%F %H:%M:%S') $@"
}

function setup() {
  _out --------------------------------------------------------
  _out Deleting articles-java-jee
  
  cd ${root_folder}/articles-java-jee
  oc delete all -l app=articles --ignore-not-found
  oc delete all -l app=articles --ignore-not-found
  oc delete configmap -l app=articles --ignore-not-found
  oc delete -f deployment/istio.yaml --ignore-not-found

  _out Done Deleting articles-java-jee
  _out --------------------------------------------------------
  _out Deleting authors-nodejs
  
  cd ${root_folder}/authors-nodejs
  oc delete all -l app=authors --ignore-not-found
  oc delete all -l app=authors --ignore-not-found
  kubectl delete -f deployment/istio.yaml --ignore-not-found

  _out Done Deleting authors-nodejs
  _out --------------------------------------------------------
  _out Deleting web-api-java-jee
  
  cd ${root_folder}/web-api-java-jee
  oc delete all -l app=web-api --ignore-not-found
  oc delete all -l app=web-api --ignore-not-found
  oc delete -f deployment/istio-service-v2.yaml --ignore-not-found

  _out Done Deleting web-api-java-jee
  _out --------------------------------------------------------
  _out Deleting web-app
  
  cd ${root_folder}/web-app-vuejs
  oc delete all -l app=web-app --ignore-not-found
  oc delete all -l app=web-app --ignore-not-found
  oc delete -f deployment/istio.yaml --ignore-not-found
  oc delete bc web-app --ignore-not-found
  oc delete build web-app-1 --ignore-not-found
  oc delete pod web-app-1-build --ignore-not-found
  oc delete istag web-app:latest --ignore-not-found

  _out Done Deleting web-app
  _out --------------------------------------------------------   
  _out Deleting Istio Ingress

  cd ${root_folder}/minishift-scripts
  oc delete -f istio-ingress-gateway.yaml
  oc delete -f istio-ingress-service-web-api-v1-only.yaml

  _out Done Deleting Istio Ingress
  _out -------------------------------------------------------- 

}

login
setup
