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
  _out Deleting articles-java-jee
  
  cd ${root_folder}/articles-java-jee
  oc delete all -l app=articles --ignore-not-found
  oc delete all -l app=articles --ignore-not-found
  oc delete configmap -l app=articles --ignore-not-found
  oc delete -f deployment/istio.yaml --ignore-not-found

  _out Done Deleting articles-java-jee
}

login
setup
