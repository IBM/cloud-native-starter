#!/bin/bash

root_folder=$(cd $(dirname $0); cd ..; pwd)

exec 3>&1

function _out() {
  echo "$(date +'%F %H:%M:%S') $@"
}

function setup() {
  _out Deploying web-api-reactive
  
  cd ${root_folder}/web-api-reactive
  kubectl delete -f deployment/kubernetes.yaml --ignore-not-found

  cd ${root_folder}/web-api-reactive/src/main/resources
  sed "s/KAFKA_BOOTSTRAP_SERVERS/my-cluster-kafka-external-bootstrap.kafka:9094/g" application.properties.template > application.properties

  cd ${root_folder}/web-api-reactive
  eval $(minikube docker-env) 
  docker build -f ${root_folder}/web-api-reactive/Dockerfile -t web-api-reactive:latest .

  kubectl apply -f deployment/kubernetes.yaml
  
  minikubeip=$(minikube ip)
  nodeport=$(kubectl get svc web-api-reactive --output 'jsonpath={.spec.ports[*].nodePort}')
  
  _out Done deploying web-api-reactive
  _out Stream endpoint: http://${minikubeip}:${nodeport}/v1/server-sent-events
  _out API Explorer: http://${minikubeip}:${nodeport}/explorer
  _out Sample API - Read articles: curl -X GET \"http://${minikubeip}:${nodeport}/v2/articles\" -H \"accept: application/json\"
  _out Wait until the pod has been started: "kubectl get pod --watch | grep web-api-reactive"
}

setup