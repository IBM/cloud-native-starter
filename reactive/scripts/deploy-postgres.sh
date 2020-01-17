#!/bin/bash

root_folder=$(cd $(dirname $0); cd ..; pwd)

exec 3>&1

function _out() {
  echo "$(date +'%F %H:%M:%S') $@"
}

function setup() {
  _out Deploying postgres

  kubectl create ns my-postgresql-operator-dev4devs-com

  cd ${root_folder}
  kubectl create -f iks-scripts/postgres.yaml

  _out Done deploying postgres
  _out Wait until the pod has been started: \"kubectl get pods -n my-postgresql-operator-dev4devs-com --watch\"
}

setup