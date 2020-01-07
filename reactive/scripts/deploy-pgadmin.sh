#!/bin/bash

root_folder=$(cd $(dirname $0); cd ..; pwd)

exec 3>&1

function _out() {
  echo "$(date +'%F %H:%M:%S') $@"
}

function setup() {
  _out Deploying pgadmin

  eval $(minikube docker-env)

  kubectl create ns demo
  kubectl create -f https://raw.githubusercontent.com/kubedb/cli/0.9.0/docs/examples/postgres/quickstart/pgadmin.yaml

  _out Done deploying pgadmin
  _out Wait until the pod has been started: "kubectl get pods -n demo --watch"
  
  _out "minikube service pgadmin -n demo --url"
  _out "admin, admin"
}

setup