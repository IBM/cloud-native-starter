#!/bin/bash

root_folder=$(cd $(dirname $0); cd ..; pwd)

exec 3>&1

function _out() {
  echo "$(date +'%F %H:%M:%S') $@"
}

function setup() {
  _out Generating load

  minikubeip=$(minikube ip)
  nodeport=$(kubectl get svc web-api-reactive --output 'jsonpath={.spec.ports[*].nodePort}')

  start=`date +%s`
  version=2

  for i in {1..5000}
  do
    echo "Times /v${version}/articles invoked: $i"
    curl --silent --output /dev/null -X GET "http://${minikubeip}:${nodeport}/v${version}/articles" -H "accept: application/json"
  done
  
  end=`date +%s`
  duration=$((end-start))
  _out $duration
  
}

setup

