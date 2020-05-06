#!/bin/bash

root_folder=$(cd $(dirname $0); cd ..; pwd)

exec 3>&1

function _out() {
  echo "$(date +'%F %H:%M:%S') $@"
}

function setup() {

  nodeport=$(oc get svc my-cluster-kafka-external-bootstrap -n kafka --ignore-not-found --output 'jsonpath={.spec.ports[*].nodePort}')
  if [ -z "$nodeport" ]; then
    _out Kafka is not available. Run the command: $ROOT_FOLDER/os4-scripts/deploy-kafka-oc-only.sh 
  else 
    _out Press Ctrl-C twice to stop web-api-reactive
   
    osip=$(oc get route my-cluster-kafka-external-bootstrap --template='{{ .spec.host }}' --namespace kafka)
    cd ${root_folder}/web-api-reactive/src/main/resources
    sed "s/KAFKA_BOOTSTRAP_SERVERS/${osip}/g" application.properties.template > application.properties.tmp

    nodeport=$(oc get svc articles-reactive --ignore-not-found --output 'jsonpath={.spec.ports[*].nodePort}')
    sed "s/CNS_ARTICLES_PORT/80/g" application.properties.tmp > application.properties.tmp2

    nodeport=$(oc get svc authors --ignore-not-found --output 'jsonpath={.spec.ports[*].nodePort}')
    sed "s/CNS_AUTHORS_PORT/${nodeport}/g" application.properties.tmp2 > application.properties.tmp3

    sed "s/CNS_MINIKUBE_IP/${osip}/g" application.properties.tmp3 > application.properties.tmp4

    sed "s/CNS_LOCAL/true/g" application.properties.tmp4 > application.properties
    rm application.properties.tmp
    rm application.properties.tmp2
    rm application.properties.tmp3
    rm application.properties.tmp4
  
    cd ${root_folder}/web-api-reactive
    mvn compile quarkus:dev 
  fi 
}

setup