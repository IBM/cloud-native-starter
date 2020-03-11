#!/bin/bash

root_folder=$(cd $(dirname $0); cd ..; pwd)

exec 3>&1

function _out() {
  echo "$(date +'%F %H:%M:%S') $@"
}

function templates() {
  _out --- Preparing YAML files for Kubernetes Deployment

  cd ${root_folder}/authors-nodejs/deployment  
  sed -e "s+<URL>+ +g" -e "s+<DB>+local+g" -e "s+authors:1+$REGISTRY/$PROJECT/authors:1+g" deployment.yaml.template > os4-deployment.yaml
  # sed "s|<HOST>|$CLOUDANTHOST|g" istio-egress-cloudant.yaml.template > istio-egress-cloudant.yaml
  }

function setup() {

  _out --- Clean-up 
  oc delete all -l app=authors --ignore-not-found
  oc delete is authors
  
  _out --- Build Docker Image
  cd ${root_folder}/authors-nodejs
  docker build -f Dockerfile -t  authors:1 .
  docker tag authors:1 $REGISTRYURL/$PROJECT/authors:1
  docker push $REGISTRYURL/$PROJECT/authors:1

  _out --- Deploy to OpenShift
  cd ${root_folder}/authors-nodejs/deployment
  oc apply -f os4-deployment.yaml
  oc expose svc/authors
  oc apply -f istio.yaml

  _out Done deploying authors-nodejs
  _out Wait until the pod has been started: "oc get pod --watch | grep authors"
  # _out Sample API call: curl http://$(oc get route authors --template='{{ .spec.host }}')/api/v1/getauthor?name=Niklas%20Heidloff
}

_out Deploying authors-nodejs
source ${root_folder}/os4-scripts/login.sh
templates
setup
