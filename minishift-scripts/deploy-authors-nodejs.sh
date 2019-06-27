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

  # Delete existing
  oc delete all -l app=authors
  oc delete pod -l app=authors
  ### How about istio.yaml?

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
  oc apply -f istio.yaml

}

login
setup
