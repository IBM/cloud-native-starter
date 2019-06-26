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

function setup() {
  _out Deleting articles-java-jee
  
  cd ${root_folder}/articles-java-jee
  oc delete route articles
  kubectl delete -f deployment/kubernetes-minishift.yaml --ignore-not-found
  kubectl delete -f deployment/istio.yaml --ignore-not-found

  _out Done Deleting articles-java-jee
}

login
setup
