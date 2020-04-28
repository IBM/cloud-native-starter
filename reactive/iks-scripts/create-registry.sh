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

readonly CFG_FILE=${cns_root_folder}/local.env
# Check if config file exists, in this case it will have been modified
if [ ! -f $CFG_FILE ]; then
     _out Config file local.env is missing!
     _out -- Copy template.local.env to local.env and edit according to our instructions!
     exit 1
fi  

# Create a randomized registry namespace name and save it in local.env
CR_NAMESPACE=cloud-native-$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 10 | head -n 1 | tr '[:upper:]' '[:lower:]')
sed -i "s/REGISTRY_NAMESPACE=cloud-nativ.*/REGISTRY_NAMESPACE=$CR_NAMESPACE/g"  $CFG_FILE

source $CFG_FILE

# SETUP logging (redirect stdout and stderr to a log file)
readonly LOG_FILE=${root_folder}/iks-scripts/create-registry.log 
touch $LOG_FILE

function create_registry() {
  _out Creating a Namespace in IBM Cloud Container Registry

  _out Logging into IBM Cloud
  ibmcloud config --check-version=false >> $LOG_FILE 2>&1
  ibmcloud api --unset >> $LOG_FILE 2>&1
  ibmcloud api https://cloud.ibm.com >> $LOG_FILE 2>&1
  ibmcloud login --apikey $IBMCLOUD_API_KEY -r $IBM_CLOUD_REGION >> $LOG_FILE 2>&1

  _out Creating Namespace $REGISTRY_NAMESPACE
  ibmcloud cr login  >> $LOG_FILE 2>&1
  registry=$(ibmcloud cr info | awk '/Container Registry  /  {print $3}')
  echo -e "\nREGISTRY=$registry" >> $CFG_FILE

  ibmcloud cr namespace-add $REGISTRY_NAMESPACE >> $LOG_FILE 2>&1
  # check if something went wrong
  if [ $? == 0 ]; then 
    _out Namespace in IBM Cloud Container Registry created
  else
    _out SOMETHING WENT WRONG! Check the iks-scripts/create-registry.log 
  fi


}

create_registry
