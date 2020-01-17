#!/bin/bash

root_folder=$(cd $(dirname $0); cd ..; pwd)
cns_root_folder=$(cd $(dirname $0); cd ../..; pwd)
exec 3>&1


function _out() {
  echo "$(date +'%F %H:%M:%S') $@"
}

function setup_logging () {
  # SETUP logging (redirect stdout and stderr to a log file)
  readonly CR_LOG_FILE=${root_folder}/iks-scripts/login_cr.log 
  touch $CR_LOG_FILE
}

function check_local_env () {
  # Check if IKS deployment, set kubectl environment and IKS deployment options in local.env
  CFG_FILE=${cns_root_folder}/local.env
  # Check if config file exists
  if [ ! -f $CFG_FILE ]; then
      _out Config file local.env is missing! Check our instructions!
      exit 1
  fi  
  source $CFG_FILE >> $CR_LOG_FILE 2>&1
  CLUSTER_CFG=${root_folder}/iks-scripts/cluster-config.sh
  # Check if config file exists
  if [ ! -f $CLUSTER_CFG ]; then
      _out Cluster config file iks-scripts/cluster-config.sh is missing! Run iks-scripts/cluster-get-config.sh first!
      exit 1
  fi  
  source $CLUSTER_CFG >> $CR_LOG_FILE 2>&1
}

function login_cr () {
    # Login to IBM Cloud Image Registry
    ibmcloud ks region set $IBM_CLOUD_REGION >> $CR_LOG_FILE 2>&1
    ibmcloud cr region-set $IBM_CLOUD_REGION >> $CR_LOG_FILE 2>&1
    ibmcloud cr login >> $CR_LOG_FILE 2>&1
}

setup_logging
check_local_env
login_cr