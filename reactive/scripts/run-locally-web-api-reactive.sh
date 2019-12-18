#!/bin/bash

root_folder=$(cd $(dirname $0); cd ..; pwd)

exec 3>&1

function _out() {
  echo "$(date +'%F %H:%M:%S') $@"
}

function setup() {

  minikubeip=$(minikube ip)
  nodeport=$(kubectl get svc my-cluster-kafka-external-bootstrap -n kafka --ignore-not-found --output 'jsonpath={.spec.ports[*].nodePort}')
  if [ -z "$nodeport" ]; then
    _out Kafka is not available. Run the command: sh scripts/deploy-kafka.sh
  else 
    _out Press Ctrl-C twice to stop web-api-reactive
    _out Stream endpoint: http://localhost:8080/v1/server-sent-events
    _out API explorer: http://localhost:8080/explorer
    _out Sample API - Read articles: curl -X GET \"http://localhost:8080/v1/articles\" -H \"accept: application/json\"
   
    cd ${root_folder}/web-api-reactive/src/main/resources
    sed "s/KAFKA_BOOTSTRAP_SERVERS/${minikubeip}:${nodeport}/g" application.properties.template > application.properties
  
    cd ${root_folder}/web-api-reactive
    mvn compile quarkus:dev 
  fi 
}

setup