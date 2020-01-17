#!/bin/bash

root_folder=$(cd $(dirname $0); cd ..; pwd)
cns_root_folder=$(cd $(dirname $0); cd ../..; pwd)
exec 3>&1

function _out() {
  echo "$(date +'%F %H:%M:%S') $@"
}

function delete() {
  _out Deleting postgres

  cd ${root_folder}
  kubectl delete -f iks-scripts/postgres.yaml

  _out Done 
}

source ${root_folder}/iks-scripts/login.sh
delete