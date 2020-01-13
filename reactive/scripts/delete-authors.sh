#!/bin/bash

root_folder=$(cd $(dirname $0); cd ..; pwd)

exec 3>&1

function _out() {
  echo "$(date +'%F %H:%M:%S') $@"
}

function setup() {

  cd ${root_folder}/../authors-nodejs
  cp deployment.yaml.template deployment.yaml
  kubectl delete -f deployment/deployment.yaml --ignore-not-found
  rm deployment.yaml
}

setup
