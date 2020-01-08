#!/bin/bash

root_folder=$(cd $(dirname $0); cd ..; pwd)

exec 3>&1

function _out() {
  echo "$(date +'%F %H:%M:%S') $@"
}

function setup() {
  _out Installing Kafka
  
  kubectl create namespace kafka
    
  curl -L https://github.com/strimzi/strimzi-kafka-operator/releases/download/0.15.0/strimzi-cluster-operator-0.15.0.yaml \
    | sed 's/namespace: .*/namespace: kafka/' \
    | kubectl apply -f - -n kafka 

    kubectl apply -f ${root_folder}/scripts/kafka-cluster.yaml -n kafka 
   
  _out Done installing Kafka
  _out Wait until the pods have been started
  _out Run this command \(potentially multiple times\): \"kubectl wait kafka/my-cluster --for=condition=Ready --timeout=300s -n kafka\"
  _out After this run \"sh scripts/show-urls\" to get the Kafka broker URL
}

setup

