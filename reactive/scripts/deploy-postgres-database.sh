#!/bin/bash

root_folder=$(cd $(dirname $0); cd ..; pwd)

exec 3>&1

function _out() {
  echo "$(date +'%F %H:%M:%S') $@"
}

function setup() {
  _out Deploying postgres database

  cd ${root_folder}/scripts
  kubectl create -f postgres-cluster.yaml -n my-postgresql-operator-dev4devs-com

  sleep 10

  kubectl patch svc database-articles -n my-postgresql-operator-dev4devs-com -p '{"spec": {"ports": [{"port": 5432,"targetPort": 5432,"name": "database-articles", "protocol": "TCP"}],"type": "NodePort"}}'
  
  _out Done deploying postgres cluster
  _out Wait until the pod has been started: \"kubectl get pods -n my-postgresql-operator-dev4devs-com --watch \| grep database-articles\"
}

setup