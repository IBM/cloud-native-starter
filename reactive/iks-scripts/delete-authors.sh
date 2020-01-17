#!/bin/bash

root_folder=$(cd $(dirname $0); cd ..; pwd)
cns_root_folder=$(cd $(dirname $0); cd ../..; pwd)
exec 3>&1

function _out() {
  echo "$(date +'%F %H:%M:%S') $@"
}

function delete() {

  cd ${cns_root_folder}/authors-nodejs
  kubectl delete -f deployment/IKS-deployment.yaml --ignore-not-found
}

source ${root_folder}/iks-scripts/login.sh
delete
