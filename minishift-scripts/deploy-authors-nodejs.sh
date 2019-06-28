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
  _out Deploying authors-nodejs
  cd ${root_folder}/authors-nodejs

  # Delete existing (first oc delete all typically fails to delete the pod)
  oc delete all -l app=authors --ignore-not-found
  oc delete all -l app=authors --ignore-not-found
  oc delete -f deployment/istio.yaml --ignore-not-found
  

  # Create Docker Image and push to registry
  eval $(minishift docker-env)
  docker login -u admin -p $(oc whoami -t) $(minishift openshift registry)
  imagestream=$(minishift openshift registry)/cloud-native-starter/authors:1
  docker build -f Dockerfile -t authors:1 .
  docker tag authors:1 $imagestream
  docker push $imagestream

  # Deploy
  cd ${root_folder}/authors-nodejs/deployment
  sed -e "s|<URL>|local|g" -e "s|<DB>|local|g" -e "s|authors:1|$imagestream|g" deployment.yaml.template > deployment-minishift.yaml
  sed -e "s|<URL>|local|g" -e "s|<DB>|local|g" ../config.json.template > ../config.json
  oc apply -f deployment-minishift.yaml
  oc expose svc/authors
  oc apply -f istio.yaml

  _out Done deploying authors-nodejs
  _out
  _out Sample request: curl http://$(oc get route authors -o jsonpath={.spec.host})/api/v1/getauthor?name=Harald%20Uebele
}

login
setup
