#!/bin/bash

root_folder=$(cd $(dirname $0); cd ..; pwd)
cns_root_folder=$(cd $(dirname $0); cd ../..; pwd)
exec 3>&1

function _out() {
  echo "$(date +'%F %H:%M:%S') $@"
}

function setup_logging () {
  # SETUP logging (redirect stdout and stderr to a log file)
  readonly P_LOG_FILE=${root_folder}/iks-scripts/depoly-postgres.log 
  touch $P_LOG_FILE
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

function setup() {
  _out Deploying postgres

  kubectl create ns my-postgresql-operator-dev4devs-com

  cd ${root_folder}
  kubectl create -f iks-scripts/postgres.yaml

  clusterip=$(ibmcloud ks workers --cluster $CLUSTER_NAME | awk '/Ready/ {print $2;exit;}')

  kubectl config set-context --current --namespace=my-postgresql-operator-dev4devs-com
  nodeport=$(kubectl get svc database-articles --output 'jsonpath={.spec.ports[*].nodePort}')
  targetPort=$(kubectl get svc database-articles --output 'jsonpath={.spec.ports[*].targetPort}')
  kubectl config set-context --current --namespace=default

  _out Done deploying postgres admin UI
  _out Wait until the pod has been started: \"kubectl get pods -n my-postgresql-operator-dev4devs-com --watch\"
  _out URL: http://${clusterip}:${targetPort}
  _out Credentials - user: admin, password: admin
}

local_env
source ${root_folder}/iks-scripts/login.sh
setup