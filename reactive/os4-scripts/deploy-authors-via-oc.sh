#!/bin/bash

root_folder=$(cd $(dirname $0); cd ..; pwd)

exec 3>&1

function _out() {
  echo "$(date +'%F %H:%M:%S') $@"
}

function templates() {
  _out --- Preparing YAML files for Kubernetes Deployment
  cd ${root_folder}/../authors-nodejs/deployment  
  sed -e "s+<URL>+ +g" -e "s+<DB>+local+g" -e "s+authors:1+image-registry.openshift-image-registry.svc:5000/cloud-native-starter/authors:latest+g" deployment.yaml.template > os4-deployment.yaml
  }

function setup() {

  _out --- Clean-up 
  oc delete all -l app=authors --ignore-not-found
  oc delete is authors --ignore-not-found
  
  cd ${root_folder}/../authors-nodejs
  
  _out --- Deploy to OpenShift
  oc new-build --name authors --binary --strategy docker
  oc start-build authors --from-dir=.

  cd ${root_folder}/../authors-nodejs/deployment
  oc apply -f os4-deployment.yaml
  oc expose svc/authors

  _out Done deploying authors-nodejs
  _out Wait until the pod has been started: "oc get pod --watch | grep authors"
  _out Sample API call: curl http://$(oc get route authors --template='{{ .spec.host }}')/api/v1/getauthor?name=Niklas%20Heidloff
}

_out Deploying authors-nodejs
templates
setup
