#!/bin/bash

root_folder=$(cd $(dirname $0); cd ..; pwd)
cns_root_folder=$(cd $(dirname $0); cd ../..; pwd)

exec 3>&1

function _out() {
  echo "$(date +'%F %H:%M:%S') $@"
}

function local_env () {
  # Check if IKS deployment, set kubectl environment and IKS deployment options in local.env
  CFG_FILE=${cns_root_folder}/local.env
  # Check if config file exists
  if [ ! -f $CFG_FILE ]; then
      _out Config file local.env is missing! Check our instructions!
      exit 1
  fi  
  source $CFG_FILE
}

function login () {
  _out Logging into IBM Cloud
  ibmcloud config --check-version=false
  ibmcloud api --unset
  ibmcloud api https://cloud.ibm.com
  ibmcloud login --apikey $IBMCLOUD_API_KEY -r $IBM_CLOUD_REGION
}

function delete() {

  cd ${root_folder}/articles-reactive
  kubectl delete -f deployment/IKS-kubernetes.yaml --ignore-not-found

}

local_env
login
delete
