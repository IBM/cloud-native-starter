#!/bin/bash

root_folder=$(cd $(dirname $0); cd ..; pwd)

exec 3>&1

function _out() {
  echo "$(date +'%F %H:%M:%S') $@"
}

function setup() {
  _out Deploying postgres operator

  curl -sL https://github.com/operator-framework/operator-lifecycle-manager/releases/download/0.13.0/install.sh | bash -s 0.13.0

  kubectl create -f https://operatorhub.io/install/postgresql-operator-dev4devs-com.yaml
  
  _out Done deploying postgres operator
  _out Wait until the operator has been started: \"kubectl get csv -n my-postgresql-operator-dev4devs-com --watch\"
  _out To doublecheck, make sure everything is green in the Minikube dashboard for all namespaces: \"minikube dashboard\"
  _out Once succeeded, run \"sh scripts/deploy-postgres-database.sh\"
}

setup