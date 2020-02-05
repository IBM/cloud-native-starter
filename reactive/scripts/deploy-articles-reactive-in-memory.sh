#!/bin/bash

root_folder=$(cd $(dirname $0); cd ..; pwd)

exec 3>&1

function _out() {
  echo "$(date +'%F %H:%M:%S') $@"
}

function setup() {
  _out Deploying articles-reactive
  
  cd ${root_folder}/articles-reactive
  kubectl delete deployment articles-reactive --ignore-not-found
  kubectl delete configmap articles-config --ignore-not-found

  cd ${root_folder}/articles-reactive/src/main/resources
  sed "s/KAFKA_BOOTSTRAP_SERVERS/my-cluster-kafka-external-bootstrap.kafka:9094/g" application.properties.template > application.properties.temp

  sed "s/IN_MEMORY_STORE/true/g" application.properties.temp > application.properties.temp2

  sed "s/POSTGRES_URL/database-articles.my-postgresql-operator-dev4devs-com:5432/g" application.properties.temp2 > application.properties
  rm application.properties.temp
  rm application.properties.temp2

  cd ${root_folder}/articles-reactive
  eval $(minikube docker-env) 
  docker build -f ${root_folder}/articles-reactive/Dockerfile -t articles-reactive:latest .

  kubectl apply -f deployment/kubernetes.yaml
  
  minikubeip=$(minikube ip)
  nodeport=$(kubectl get svc articles-reactive --output 'jsonpath={.spec.ports[*].nodePort}')
   
  _out Done deploying articles-reactive
  _out API Explorer: http://${minikubeip}:${nodeport}/explorer
  _out Sample API - Read articles: curl -X GET \"http://${minikubeip}:${nodeport}/v2/articles?amount=10\" -H \"accept: application/json\"
  _out Wait until the pod has been started: \"kubectl get pod --watch | grep articles-reactive\"
}

setup
