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
  _out Deleting web-app
  
  cd ${root_folder}/web-app-vuejs
  oc delete all -l app=web-app --ignore-not-found
  oc delete pod -l app=web-app --ignore-not-found
  oc delete pod web-app-1-build --ignore-not-found
  oc delete istag web-app:latest --ignore-not-found
  oc delete -f deployment/istio.yaml --ignore-not-found

  _out Done Deleting web-app
}

login
setup
