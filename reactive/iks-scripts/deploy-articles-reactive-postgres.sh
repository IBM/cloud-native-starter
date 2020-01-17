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

function setup() {
  _out Deploying articles-reactive for postgres
  
  # Configure source code
  cd ${root_folder}/articles-reactive
  kubectl delete -f deployment/kubernetes.yaml --ignore-not-found

  cd ${root_folder}/articles-reactive/src/main/resources
  sed "s/KAFKA_BOOTSTRAP_SERVERS/my-cluster-kafka-external-bootstrap.kafka:9094/g" application.properties.template > application.properties.temp

  sed "s/IN_MEMORY_STORE/no/g" application.properties.temp > application.properties.temp2

  sed "s/POSTGRES_URL/database-articles.my-postgresql-operator-dev4devs-com:5432/g" application.properties.temp2 > application.properties
  rm application.properties.temp
  rm application.properties.temp2

  clusterip=$(ibmcloud ks workers --cluster $CLUSTER_NAME | awk '/Ready/ {print $2;exit;}')

  cd ${root_folder}/articles-reactive
  
  # Login to IBM Cloud Image Registry
  _out Set IBM Cloud Image Registry
  source ${root_folder}/iks-scripts/login_cr.sh

  _out Build container articles-reactive-postgres.
  # docker build replacement for ICR 

  ibmcloud cr build -f ${root_folder}/articles-reactive/Dockerfile --tag $REGISTRY/$REGISTRY_NAMESPACE/articles-reactive:latest .

  # Add ICR tags to K8s deployment.yaml  
  sed "s+articles-reactive:latest+$REGISTRY/$REGISTRY_NAMESPACE/articles-reactive:latest+g" ${root_folder}/articles-reactive/deployment/kubernetes.yaml > ${root_folder}/articles-reactive/deployment/temp-kubernetes.yaml 
  
  # Replace imagePullPolicy
  sed "s+Never+Always+g" ${root_folder}/articles-reactive/deployment/temp-kubernetes.yaml > ${root_folder}/articles-reactive/deployment/IKS-kubernetes.yaml 
  
  rm ${root_folder}/articles-reactive/deployment/temp-kubernetes.yaml 

  kubectl apply -f ${root_folder}/articles-reactive/deployment/IKS-kubernetes.yaml 

  clusterip=$(ibmcloud ks workers --cluster $CLUSTER_NAME | awk '/Ready/ {print $2;exit;}') 
  nodeport=$(kubectl get svc articles-reactive --output 'jsonpath={.spec.ports[*].nodePort}')

  _out Done deploying articles-reactive
  _out API Explorer: http://${clusterip}:${nodeport}/explorer
  _out Sample API - Read articles: curl -X GET \"http://${clusterip}:${nodeport}/v2/articles?amount=10\" -H \"accept: application/json\"
  _out Wait until the pod has been started: \"kubectl get pod --watch | grep articles-reactive\"
}

local_env
source ${root_folder}/iks-scripts/login.sh
setup