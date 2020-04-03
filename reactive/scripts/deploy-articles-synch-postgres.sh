#!/bin/bash

root_folder=$(cd $(dirname $0); cd ..; pwd)

exec 3>&1

function _out() {
  echo "$(date +'%F %H:%M:%S') $@"
}

function setup() {
  _out Deploying articles-synch
  
  cd ${root_folder}/articles-reactive
  kubectl delete -f deployment/kubernetes.yaml --ignore-not-found

  cd ${root_folder}/articles-synch/src/main/resources
  sed "s/POSTGRES_URL/database-articles.my-postgresql-operator-dev4devs-com:5432/g" application.properties.template > application.properties

  cd ${root_folder}/articles-synch
  eval $(minikube docker-env) 
  docker build -f ${root_folder}/articles-synch/Dockerfile -t articles-reactive:latest .

  cd ${root_folder}/articles-reactive
  kubectl apply -f deployment/kubernetes.yaml
  
  minikubeip=$(minikube ip)
  nodeport=$(kubectl get svc articles-reactive --output 'jsonpath={.spec.ports[*].nodePort}')
   
  _out Done deploying articles-synch
  _out API Explorer: http://${minikubeip}:${nodeport}/explorer
  _out Sample API - Read articles: curl -X GET \"http://${minikubeip}:${nodeport}/v1/articles?amount=10\" -H \"accept: application/json\"
  _out Wait until the pod has been started: \"kubectl get pod --watch | grep articles-reactive\"
}

setup