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
  _out Deleting web-api-java-jee
  
  cd ${root_folder}/web-api-java-jee
  oc delete all -l app=web-api --ignore-not-found
  oc delete all -l app=web-api --ignore-not-found
  oc delete -f deployment/istio-service-v2.yaml --ignore-not-found

  _out Done Deleting web-api-java-jee
}

login
setup
