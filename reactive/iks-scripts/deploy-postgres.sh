#!/bin/bash

root_folder=$(cd $(dirname $0); cd ..; pwd)
cns_root_folder=$(cd $(dirname $0); cd ../..; pwd)
exec 3>&1

function _out() {
  echo "$(date +'%F %H:%M:%S') $@"
}

function setup_logging () {
  # SETUP logging (redirect stdout and stderr to a log file)
  LOG_FILE=${root_folder}/iks-scripts/deploy-postgres.log  
  touch $LOG_FILE
}

function local_env () {
  _out Get environment from local.env
  # Check if IKS deployment, set kubectl environment and IKS deployment options in local.env
  CFG_FILE=${cns_root_folder}/local.env
  # Check if config file exists
  if [ ! -f $CFG_FILE ]; then
      _out Config file local.env is missing! Check our instructions!
      exit 1
  fi  
  source $CFG_FILE
  _out End - Get environment from local.env

  _out Verify "cluster-config.sh" exists
  CLUSTER_CFG=${root_folder}/iks-scripts/cluster-config.sh
  # Check if config file exists
  if [ ! -f $CLUSTER_CFG ]; then
      _out Cluster config file iks-scripts/cluster-config.sh is missing! Run iks-scripts/cluster-get-config.sh first!
      exit 1
  fi  
  source $CLUSTER_CFG
  _out End - Verify that the file "cluster-config.sh" exists
}

function login () {
  _out Logging into IBM Cloud
  ibmcloud config --check-version=false >> $LOG_FILE 2>&1
  ibmcloud api --unset >> $LOG_FILE 2>&1
  ibmcloud api https://cloud.ibm.com >> $LOG_FILE 2>&1
  ibmcloud login --apikey $IBMCLOUD_API_KEY -r $IBM_CLOUD_REGION >> $LOG_FILE 2>&1
  
  # Ensure the cluster config
  _out Set cluster-config 
  CLUSTER_CONFIG=$(ibmcloud ks cluster config $CLUSTER_NAME --export) >> $LOG_FILE 2>&1
  $CLUSTER_CONFIG >> $LOG_FILE 2>&1
  _out End - Logging into IBM Cloud
}

function setup() {
  _out Deploying postgres # >> $LOG_FILE 2>&1
  
  _out Create namespace my-postgresql-operator-dev4devs-com
  kubectl create ns my-postgresql-operator-dev4devs-com # >> $LOG_FILE 2>&1

  cd ${root_folder}
  _out Deploy postgres
  kubectl create -f iks-scripts/postgres.yaml # >> $LOG_FILE 2>&1

  clusterip=$(ibmcloud ks workers --cluster $CLUSTER_NAME | awk '/Ready/ {print $2;exit;}')

  _out Get nodePort and targetPort 
  kubectl config set-context --current --namespace=my-postgresql-operator-dev4devs-com # >> $LOG_FILE 2>&1
  nodeport=$(kubectl get svc database-articles --output 'jsonpath={.spec.ports[*].nodePort}')
  targetPort=$(kubectl get svc database-articles --output 'jsonpath={.spec.ports[*].targetPort}')
  kubectl config set-context --current --namespace=default # >> $LOG_FILE 2>&1
  
  _out Status
  kubectl get pods -n my-postgresql-operator-dev4devs-com

  _out End - Deploying postgres
  _out 
  _out Wait until the pod has been started:
  _out 1.) \"kubectl config set-context --current --namespace=my-postgresql-operator-dev4devs-com\" 
  _out 2.) \"kubectl get pods \" optional with (--watch)
  _out 3.) \"kubectl get svc database-articles\"
  _out 4.) \"kubectl port-forward svc/database-articles ${targetPort}:${targetPort}\"
  _out 5.) Ensure you have psql client installed (https://www.ibm.com/cloud/blog/new-builders/postgresql-tips-installing-the-postgresql-client)
  _out 6.) Open new terminal
  _out 7.) Insert: \"psql -h 127.0.0.1 -U postgres\"
  _out 8.) Now you connected to postgres
  _out Credentials - user: postgres, password: postgres
}

local_env
setup_logging
login
setup