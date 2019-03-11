#!/bin/bash

root_folder=$(cd $(dirname $0); cd ..; pwd)

exec 3>&1

function _out() {
  echo "$(date +'%F %H:%M:%S') $@"
}

function setup() {
  _out Deleting web-api-java-jee
  
  cd ${root_folder}/web-api-java-jee
  kubectl delete -f deployment/kubernetes-service.yaml
  kubectl delete -f deployment/kubernetes-deployment-v1.yaml
  kubectl delete -f deployment/kubernetes-deployment-v2.yaml
  kubectl delete -f deployment/istio-service-v2.yaml

  sed 's/10/5/' src/main/java/com/ibm/webapi/business/Service.java > src/main/java/com/ibm/webapi/business/Service2.java
  rm src/main/java/com/ibm/webapi/business/Service.java
  mv src/main/java/com/ibm/webapi/business/Service2.java src/main/java/com/ibm/webapi/business/Service.java
  
  _out Done deleting web-api-java-jee
}

setup