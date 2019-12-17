#!/bin/bash

root_folder=$(cd $(dirname $0); cd ..; pwd)

exec 3>&1

function _out() {
  echo "$(date +'%F %H:%M:%S') $@"
}

function setup() {

  minikubeip=$(minikube ip)
  _out ------------------------------------------------------------------------------------
  
  _out Kafka Strimzi operator
  nodeport=$(kubectl get svc my-cluster-kafka-external-bootstrap -n kafka --ignore-not-found --output 'jsonpath={.spec.ports[*].nodePort}')
  if [ -z "$nodeport" ]; then
    _out Kafka is not available. Run the command: sh scripts/deploy-kafka.sh
  else 
    _out Kafka bootstrap server - external URL: ${minikubeip}:${nodeport}
  fi
  _out ------------------------------------------------------------------------------------

  _out Service: articles-reactive
  nodeport=$(kubectl get svc articles-reactive --ignore-not-found --output 'jsonpath={.spec.ports[*].nodePort}')
  if [ -z "$nodeport" ]; then
    _out articles-reactive is not available. Run the command: sh scripts/deploy-articles-reactive.sh
  else 
    _out API explorer: http://${minikubeip}:${nodeport}/explorer
    _out Sample API - Read articles: curl -X GET \"http://${minikubeip}:${nodeport}/v1/getmultiple?amount=10\" -H \"accept: application/json\"
    _out Sample API - Create article: curl -X POST \"http://${minikubeip}:${nodeport}/v1/create\" -H \"accept: application/json\" -H \"Content-Type: application/json\" -d \"{\\\"author\\\":\\\"Niklas Heidloff\\\",\\\"title\\\":\\\"Title\\\",\\\"url\\\":\\\"http://heidloff.net\\\"}\"
  fi
  _out Endpoints when running locally:
  _out -- API explorer: http://localhost:8080/explorer
  _out -- Sample API - Read articles: curl -X GET \"http://localhost:8080/v1/getmultiple?amount=10\" -H \"accept: application/json\"
  _out -- Sample API - Create article: curl -X POST \"http://localhost:8080/v1/create\" -H \"accept: application/json\" -H \"Content-Type: application/json\" -d \"{\\\"author\\\":\\\"Niklas Heidloff\\\",\\\"title\\\":\\\"Title\\\",\\\"url\\\":\\\"http://heidloff.net\\\"}\"
  _out ------------------------------------------------------------------------------------

  _out Service: web-api-reactive
  nodeport=$(kubectl get svc web-api-reactive --ignore-not-found --output 'jsonpath={.spec.ports[*].nodePort}')
  if [ -z "$nodeport" ]; then
    _out web-api-reactive is not available. Run the command: sh scripts/deploy-web-api-reactive.sh
  else 
    _out Stream endpoint: http://${minikubeip}:${nodeport}/v1/stream
    _out API explorer: http://${minikubeip}:${nodeport}/explorer
    _out Sample API - Read articles: curl -X GET \"http://${minikubeip}:${nodeport}/v1/getmultiple\" -H \"accept: application/json\"   
  fi
  _out Endpoints when running locally:
  _out -- Stream endpoint: http://localhost:8080/v1/stream
  _out -- API explorer: http://localhost:8080/explorer
  _out -- Sample API - Read articles: curl -X GET \"http://localhost:8080/v1/getmultiple\" -H \"accept: application/json\"
  _out ------------------------------------------------------------------------------------
}

setup