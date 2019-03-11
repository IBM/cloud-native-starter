#!/bin/bash

root_folder=$(cd $(dirname $0); cd ..; pwd)

exec 3>&1

function _out() {
  echo "$(date +'%F %H:%M:%S') $@"
}

function setup() {

  _out Clean-up Minikube
  
  kubectl delete serviceentry cloudant
  kubectl delete virtualservice cloudant
  cd ${root_folder}/authors-nodejs/deployment
  kubectl delete -f deployment.yaml
  kubectl delete -f istio.yaml


  _out Done deleting authors-nodejs
  }

_out Deleting authors-nodejs
setup