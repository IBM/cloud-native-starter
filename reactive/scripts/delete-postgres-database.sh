#!/bin/bash

root_folder=$(cd $(dirname $0); cd ..; pwd)

exec 3>&1

function _out() {
  echo "$(date +'%F %H:%M:%S') $@"
}

function setup() {
  _out Delete postgres database

  cd ${root_folder}/scripts
  kubectl delete -f postgres-cluster.yaml -n my-postgresql-operator-dev4devs-com
}

setup