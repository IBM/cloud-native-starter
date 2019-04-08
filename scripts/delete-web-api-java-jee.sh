#!/bin/bash

root_folder=$(cd $(dirname $0); cd ..; pwd)

exec 3>&1

function _out() {
  echo "$(date +'%F %H:%M:%S') $@"
}

function setup() {
  _out Deleting web-api-java-jee
  
  cd ${root_folder}/web-api-java-jee
  kubectl delete -f deployment/kubernetes-service.yaml --ignore-not-found
  kubectl delete -f deployment/kubernetes-deployment-v1.yaml --ignore-not-found
  kubectl delete -f deployment/kubernetes-deployment-v2.yaml --ignore-not-found
  kubectl delete -f deployment/istio-service-v2.yaml --ignore-not-found

  sed 's/10/5/' src/main/java/com/ibm/webapi/business/Service.java > src/main/java/com/ibm/webapi/business/Service2.java
  rm src/main/java/com/ibm/webapi/business/Service.java
  mv src/main/java/com/ibm/webapi/business/Service2.java src/main/java/com/ibm/webapi/business/Service.java
  
  cd ${root_folder}/istio
  kubectl delete -f protect-web-api.yaml --ignore-not-found

  _out Done deleting web-api-java-jee
}

setup