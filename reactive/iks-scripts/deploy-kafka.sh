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
  readonly KAFKA_LOG_FILE=${root_folder}/iks-scripts/deploy-kafka.log 
  touch $KAFKA_LOG_FILE
}

function setup() {
  _out Installing Kafka
  
  kubectl create namespace kafka >> $KAFKA_LOG_FILE 2>&1
    
  curl -L https://github.com/strimzi/strimzi-kafka-operator/releases/download/0.15.0/strimzi-cluster-operator-0.15.0.yaml \
    | sed 's/namespace: .*/namespace: kafka/' \
    | kubectl apply -f - -n kafka >> $KAFKA_LOG_FILE 2>&1

  kubectl apply -f ${root_folder}/iks-scripts/kafka-cluster.yaml -n kafka >> $KAFKA_LOG_FILE 2>&1
  
  kubectl wait kafka/my-cluster --for=condition=Ready --timeout=300s -n kafka >> $KAFKA_LOG_FILE 2>&1

  _out Done installing Kafka
  _out Wait until the pods have been started
  _out Run this command \(potentially multiple times\): \"kubectl wait kafka/my-cluster --for=condition=Ready --timeout=300s -n kafka\"
  _out After this run \"sh iks-scripts/show-urls.sh\" to get the Kafka broker URL
}

local_env
setup_logging
source ${root_folder}/iks-scripts/login.sh
setup

