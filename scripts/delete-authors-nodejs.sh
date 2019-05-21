#!/bin/bash

root_folder=$(cd $(dirname $0); cd ..; pwd)

exec 3>&1

function _out() {
  echo "$(date +'%F %H:%M:%S') $@"
}

function setup() {

  _out Deleting authors-nodejs
  
  kubectl delete serviceentry cloudant --ignore-not-found
  kubectl delete gateway istio-egressgateway --ignore-not-found
  kubectl delete destinationrule egressgateway-for-cloudant --ignore-not-found
  cd ${root_folder}/authors-nodejs/deployment
  kubectl delete -f deployment.yaml --ignore-not-found
  kubectl delete -f istio.yaml --ignore-not-found

  _out Done deleting authors-nodejs
  }

setup