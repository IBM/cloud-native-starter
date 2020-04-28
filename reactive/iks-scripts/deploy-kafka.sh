#!/bin/bash

root_folder=$(cd $(dirname $0); cd ..; pwd)
cns_root_folder=$(cd $(dirname $0); cd ../..; pwd)
exec 3>&1


function _out() {
  echo "$(date +'%F %H:%M:%S') $@"
}

function setup_logging () {
  # SETUP logging (redirect stdout and stderr to a log file)
  LOG_FILE=${root_folder}/iks-scripts/deploy-kafka.log  
  touch $LOG_FILE
}

function local_env () {
  _out Get environment from local.env
  CFG_FILE=${cns_root_folder}/local.env
  # Check if config file exists
  if [ ! -f $CFG_FILE ]; then
      _out Config file local.env is missing! Check our instructions!
      exit 1
  fi  
  source $CFG_FILE
  _out End - Get environment from local.env
}

function login () {
  _out Logging into IBM Cloud
  ibmcloud config --check-version=false >> $LOG_FILE 2>&1
  ibmcloud api --unset >> $LOG_FILE 2>&1
  ibmcloud api https://cloud.ibm.com >> $LOG_FILE 2>&1
  ibmcloud login --apikey $IBMCLOUD_API_KEY -r $IBM_CLOUD_REGION >> $LOG_FILE 2>&1
  _out End - Logging into IBM Cloud
}

function setup() {
  _out Installing Kafka # >> $LOG_FILE 2>&1
  
  _out - Create namespace kafka
  kubectl create namespace kafka # >> $LOG_FILE 2>&1

  _out - Download kafka  
  curl -L https://github.com/strimzi/strimzi-kafka-operator/releases/download/0.15.0/strimzi-cluster-operator-0.15.0.yaml \
    | sed 's/namespace: .*/namespace: kafka/' \
    | kubectl apply -f - -n kafka # >> $LOG_FILE 2>&1

  _out - Deploy kafka into CLuster
  kubectl apply -f ${root_folder}/iks-scripts/kafka-cluster.yaml -n kafka # >> $LOG_FILE 2>&1
  
  _out - Wait for kafka/my-cluster
  kubectl wait kafka/my-cluster --for=condition=Ready --timeout=300s -n kafka # >> $LOG_FILE 2>&1

  _out End - installing Kafka
  _out Wait until the pods have been started
  _out Run this command \(potentially multiple times\): \"kubectl wait kafka/my-cluster --for=condition=Ready --timeout=300s -n kafka\"
  _out After this run \"sh iks-scripts/show-urls.sh\" to get the Kafka broker URL
  _out Note: You can\'t interact with the Kafka broker URL via the browser UI.
}

local_env
setup_logging
login
setup

