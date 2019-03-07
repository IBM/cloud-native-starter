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
  kubectl delete all -l app=authors

  _out Done deleting authors-nodejs
  }

_out Deleting authors-nodejs
setup