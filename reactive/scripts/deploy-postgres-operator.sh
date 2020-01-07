#!/bin/bash

root_folder=$(cd $(dirname $0); cd ..; pwd)

exec 3>&1

function _out() {
  echo "$(date +'%F %H:%M:%S') $@"
}

function setup() {
  _out Deploying postgres operator

  curl -sL https://github.com/operator-framework/operator-lifecycle-manager/releases/download/0.13.0/install.sh | bash -s 0.13.0

  kubectl create -f https://operatorhub.io/install/postgres-operator.yaml
  
  _out Done deploying postgres operator
  _out Wait until the pod has been started: "kubectl get csv -n operators --watch"
  _out Once finished, run deploy-postgres-cluster.sh
}

setup