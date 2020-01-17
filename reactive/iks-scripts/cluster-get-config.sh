#!/bin/bash

root_folder=$(cd $(dirname $0); cd ..; pwd)
cns_root_folder=$(cd $(dirname $0); cd ../..; pwd)

echo $root_folder
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
}

function test_cluster() {
  _out Logging into IBM Cloud
  ibmcloud config --check-version=false
  ibmcloud login --apikey $IBMCLOUD_API_KEY -r $IBM_CLOUD_REGION
  _out Check if Kubernetes Cluster is available ...
  STATE=$(ibmcloud ks cluster-get $CLUSTER_NAME -s | awk '/^State:/ {print $2}')
  if [ $STATE != "normal" ]; then 
    _out -- Your Kubernetes cluster is in $STATE state and not ready
    _out ---- Please wait a few more minutes and then try this command again 
    exit 1
   else
    _out Saving kubectl config in iks-scripts/cluster-config.sh
    CLUSTER_CONFIG=$(ibmcloud ks cluster config $CLUSTER_NAME)
    echo '#!/bin/bash' > iks-scripts/cluster-config.sh 2> /dev/null
    echo $(ibmcloud ks cluster config $CLUSTER_NAME --export) >> iks-scripts/cluster-config.sh
    chmod +x iks-scripts/cluster-config.sh
    source iks-scripts/cluster-config.sh
    echo $root_folder
    _out --
    _out -- The Cluster $CLUSTER_NAME is ready.
    _out -- 
    _out -- $CLUSTER_CONFIG
    _out -- 
  fi
}

local_env
test_cluster

