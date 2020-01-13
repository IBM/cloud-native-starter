#!/bin/bash

root_folder=$(cd $(dirname $0); cd ..; pwd)

exec 3>&1

function _out() {
  echo "$(date +'%F %H:%M:%S') $@"
}

function setup() {
  _out Deploying authors

  cd ${root_folder}/../authors-nodejs
  eval $(minikube docker-env)
  docker build -f Dockerfile -t  authors:1 .

  cd ${root_folder}/../authors-nodejs/deployment
  sed -e "s|<URL>|notused|g" -e "s|<DB>|local|g" deployment.yaml.template > deployment.yaml
  kubectl delete -f deployment.yaml --ignore-not-found
  kubectl apply -f deployment.yaml
  rm deployment.yaml
    
  _out Done deploying authors
  _out Wait until the pod has been started: \"kubectl get pod --watch | grep authors\"
  nodeport=$(kubectl get svc authors --ignore-not-found --output 'jsonpath={.spec.ports[*].nodePort}')
  _out Sample API call: \"curl http://$(minikube ip):${nodeport}/api/v1/getauthor?name=Niklas%20Heidloff\"
}

setup