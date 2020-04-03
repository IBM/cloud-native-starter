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
  LOG_FILE=${root_folder}/iks-scripts/cleanup.log  
  touch $LOG_FILE
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

function delete_postgress() {
  _out Deleting postgres

  cd ${root_folder}
  kubectl delete -f iks-scripts/postgres.yaml
  kubectl delete namespaces my-postgresql-operator-dev4devs-com

  _out Done 
}

function delete_kafka() {
  _out Deleting Kafka
  
  kubectl delete ${root_folder}/iks-scripts/kafka-cluster.yaml 
  kubectl delete namespaces kafka

  _out Done
}

function delete_all_services() {

  _out Deleting all services

  cd ${root_folder}/articles-reactive
  kubectl delete -f deployment/IKS-kubernetes.yaml --ignore-not-found

  cd ${root_folder}/web-api-reactive
  kubectl delete -f deployment/IKS-kubernetes.yaml --ignore-not-found

  cd ${root_folder}/web-app-reactive
  kubectl delete -f deployment/IKS-kubernetes.yaml --ignore-not-found

  cd ${cns_root_folder}/authors-nodejs
  kubectl delete -f deployment/IKS-deployment.yaml --ignore-not-found
  
  _out Done
}

local_env
setup_logging
login
delete_kafka
delete_postgress
delete_all_services


