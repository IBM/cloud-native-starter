#!/bin/bash

root_folder=$(cd $(dirname $0); cd ..; pwd)

exec 3>&1

function _out() {
  echo "$(date +'%F %H:%M:%S') $@"
}

function setup() {
  _out Deploying web-api-reactive
  minikubeip=$(minikube ip)
  
  cd ${root_folder}/web-api-reactive
  kubectl delete -f deployment/kubernetes.yaml --ignore-not-found

  cd ${root_folder}/web-api-reactive/src/main/resources
  sed "s/KAFKA_BOOTSTRAP_SERVERS/my-cluster-kafka-external-bootstrap.kafka:9094/g" application.properties.template > application.properties.tmp

  nodeport=$(kubectl get svc articles-reactive --ignore-not-found --output 'jsonpath={.spec.ports[*].nodePort}')
  sed "s/CNS_ARTICLES_PORT/${nodeport}/g" application.properties.tmp > application.properties.tmp2

  nodeport=$(kubectl get svc authors --ignore-not-found --output 'jsonpath={.spec.ports[*].nodePort}')
  sed "s/CNS_AUTHORS_PORT/${nodeport}/g" application.properties.tmp2 > application.properties.tmp3

  sed "s/CNS_MINIKUBE_IP/${minikubeip}/g" application.properties.tmp3 > application.properties.tmp4

  sed "s/CNS_LOCAL/false/g" application.properties.tmp4 > application.properties
  rm application.properties.tmp
  rm application.properties.tmp2
  rm application.properties.tmp3
  rm application.properties.tmp4

  cd ${root_folder}/web-api-reactive
  eval $(minikube docker-env) 
  docker build -f ${root_folder}/web-api-reactive/Dockerfile -t web-api-reactive:latest .

  kubectl apply -f deployment/kubernetes.yaml
  
  nodeport=$(kubectl get svc web-api-reactive --output 'jsonpath={.spec.ports[*].nodePort}')
  
  _out Done deploying web-api-reactive
  _out Stream endpoint: http://${minikubeip}:${nodeport}/v2/server-sent-events
  _out API Explorer: http://${minikubeip}:${nodeport}/explorer
  _out Sample API - Read articles: curl -X GET \"http://${minikubeip}:${nodeport}/v2/articles\" -H \"accept: application/json\"
  _out Wait until the pod has been started: "kubectl get pod --watch | grep web-api-reactive"
}

setup
