#!/bin/bash

root_folder=$(cd $(dirname $0); cd ..; pwd)
cns_root_folder=$(cd $(dirname $0); cd ../..; pwd)

function _out() {
  echo "$(date +'%F %H:%M:%S') $@"
}

function _err() {
  echo "$@" >&4
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
  CLUSTER_CFG=${root_folder}/iks-scripts/cluster-config.sh
  # Check if config file exists
  if [ ! -f $CLUSTER_CFG ]; then
      _out Cluster config file iks-scripts/cluster-config.sh is missing! Run iks-scripts/cluster-get-config.sh first!
      exit 1
  fi  
  source $CLUSTER_CFG
} 

function setup_logging () {
  # SETUP logging (redirect stdout and stderr to a log file)
  readonly CRR_LOG_FILE=${root_folder}/iks-scripts/create-registry.log  
  touch $CRR_LOG_FILE
}

function test_existing_namespace () {
  
  _out "Check for existing container registry namespace name in local.env"

  if [ "$REGISTRY_NAMESPACE" = "cloud-native" ]; then
      # Create a randomized registry namespace name and save it in local.env
      _out "We need to create a unique name for the REGISTRY_NAMESPACE."
      CR_NAMESPACE=cloud-native-$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 10 | head -n 1 | tr '[:upper:]' '[:lower:]')
      sed -i "s/REGISTRY_NAMESPACE=cloud-native/REGISTRY_NAMESPACE=$CR_NAMESPACE/g"  $CFG_FILE
      _out "REGISTRY_NAMESPACE: $CR_NAMESPACE"
  else
      _out "REGISTRY_NAMESPACE: $REGISTRY_NAMESPACE"
  fi

}

function create_registry() {

  _out Check registry and namespace in IBM Cloud Container Registry

  ibmcloud cr login  >> $CRR_LOG_FILE 2>&1
  
  RESULT=$(ibmcloud cr info | awk '/Container Registry  / {print $3}') >> $CRR_LOG_FILE 2>&1
  
  if [ "$RESULT" = "$REGISTRY" ]; then
    _out $REGISTRY already exists in the local.env file.
  else
    _out Add $RESULT to the local.env file.
    echo -e "\nREGISTRY=$RESULT" >> $CFG_FILE
  fi

  RESULT=$(ibmcloud cr namespaces | grep $REGISTRY_NAMESPACE | sed "s/ //g" ) >> $LOG_FILE 2>&1

  if [ "$RESULT" = "$REGISTRY_NAMESPACE" ]; then
    _out Namespace:$REGISTRY_NAMESPACE in IBM Cloud Container Registry already exists
  else
    _out Creating Namespace $REGISTRY_NAMESPACE
    ibmcloud cr namespace-add $REGISTRY_NAMESPACE >> $CRR_LOG_FILE 2>&1
    # check if something went wrong
    if [ $? == 0 ]; then 
     _out Namespace:$REGISTRY_NAMESPACE in IBM Cloud Container Registry created
    else
     _out SOMETHING WENT WRONG! Check the iks-scripts/create-registry.log  
    fi 
  fi
}

local_env
source ${root_folder}/iks-scripts/login.sh
setup_logging
test_existing_namespace
create_registry

