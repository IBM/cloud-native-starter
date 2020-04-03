#!/bin/bash

root_folder=$(cd $(dirname $0); cd ..; pwd)
cns_root_folder=$(cd $(dirname $0); cd ../..; pwd)
exec 3>&1

function _out() {
  echo "$(date +'%F %H:%M:%S') $@"
}

function setup_logging () {
  # SETUP logging (redirect stdout and stderr to a log file)
  LOG_FILE=${root_folder}/iks-scripts/deploy-articles-reactive-postgres.log  
  touch $LOG_FILE
}

function login () {
  _out Logging into IBM Cloud
  ibmcloud config --check-version=false >> $LOG_FILE 2>&1
  ibmcloud api --unset >> $LOG_FILE 2>&1
  ibmcloud api https://cloud.ibm.com >> $LOG_FILE 2>&1
  ibmcloud login --apikey $IBMCLOUD_API_KEY -r $IBM_CLOUD_REGION >> $LOG_FILE 2>&1
  
  # Ensure the cluster config
  _out Set cluster-config 
  CLUSTER_CONFIG=$(ibmcloud ks cluster config $CLUSTER_NAME --export) >> $LOG_FILE 2>&1
  $CLUSTER_CONFIG >> $LOG_FILE 2>&1
  _out End - Logging into IBM Cloud
}

function login_cr () {
    _out Logging into IBM Cloud Image Registry
    # Login to IBM Cloud Image Registry
    ibmcloud ks region set $IBM_CLOUD_REGION >> $LOG_FILE 2>&1
    ibmcloud cr region-set $IBM_CLOUD_REGION >> $LOG_FILE 2>&1
    ibmcloud cr login >> $LOG_FILE 2>&1
    _out End Logging into IBM Cloud Image Registry
}

function local_env () {
  _out Get environment from local.env
  # Check if IKS deployment, set kubectl environment and IKS deployment options in local.env
  CFG_FILE=${cns_root_folder}/local.env
  # Check if config file exists
  if [ ! -f $CFG_FILE ]; then
      _out Config file local.env is missing! Check our instructions!
      exit 1
  fi  
  source $CFG_FILE
  _out End - Get environment from local.env

  _out Verify "cluster-config.sh" exists
  CLUSTER_CFG=${root_folder}/iks-scripts/cluster-config.sh
  # Check if config file exists
  if [ ! -f $CLUSTER_CFG ]; then
      _out Cluster config file iks-scripts/cluster-config.sh is missing! Run iks-scripts/cluster-get-config.sh first!
      exit 1
  fi  
  source $CLUSTER_CFG
  _out End - Verify that the file "cluster-config.sh" exists
}

function setup() {
  _out Deploying articles-reactive for postgres # >> $LOG_FILE 2>&1
  
  # Configure source code
  cd ${root_folder}/articles-reactive
  kubectl delete -f deployment/kubernetes.yaml --ignore-not-found

  _out Configure source code
  cd ${root_folder}/articles-reactive/src/main/resources
  _out - Set Kafka external bootstrap server
  sed "s/KAFKA_BOOTSTRAP_SERVERS/my-cluster-kafka-external-bootstrap.kafka:9094/g" application.properties.template > application.properties.temp
  
  _out - Set memory for the storage
  sed "s/IN_MEMORY_STORE/false/g" application.properties.temp > application.properties.temp2

  _out - Set url Postgres database
  sed "s/POSTGRES_URL/database-articles.my-postgresql-operator-dev4devs-com:5432/g" application.properties.temp2 > application.properties
  rm application.properties.temp
  rm application.properties.temp2
  _out End - Configure source code

  clusterip=$(ibmcloud ks workers --cluster $CLUSTER_NAME | awk '/Ready/ {print $2;exit;}')

  cd ${root_folder}/articles-reactive
  
  # Login to IBM Cloud Image Registry
  login_cr

  _out Build container articles-reactive-postgres.
  # docker build replacement for ICR 
  ibmcloud cr build -f ${root_folder}/articles-reactive/Dockerfile --tag $REGISTRY/$REGISTRY_NAMESPACE/articles-reactive:latest . # >> $LOG_FILE 2>&1
  _out End - Build container articles-reactive-postgres

  _out Create IKS-deployment file 
  # Add ICR tags to K8s deployment.yaml  
  sed "s+articles-reactive:latest+$REGISTRY/$REGISTRY_NAMESPACE/articles-reactive:latest+g" ${root_folder}/articles-reactive/deployment/kubernetes.yaml > ${root_folder}/articles-reactive/deployment/temp-kubernetes.yaml 
  
  # Replace imagePullPolicy
  sed "s+Never+Always+g" ${root_folder}/articles-reactive/deployment/temp-kubernetes.yaml > ${root_folder}/articles-reactive/deployment/IKS-kubernetes.yaml 
  
  rm ${root_folder}/articles-reactive/deployment/temp-kubernetes.yaml 
  _out End - Create IKS-deployment file 

  _out Deploying articles-reactive-postgres to Kubernetes
  kubectl apply -f ${root_folder}/articles-reactive/deployment/IKS-kubernetes.yaml # >> $LOG_FILE 2>&1

  clusterip=$(ibmcloud ks workers --cluster $CLUSTER_NAME | awk '/Ready/ {print $2;exit;}') 
  nodeport=$(kubectl get svc articles-reactive --output 'jsonpath={.spec.ports[*].nodePort}')

  _out End - deploying articles-reactive
  _out API Explorer: http://${clusterip}:${nodeport}/explorer
  _out Sample API - Read articles: curl -X GET \"http://${clusterip}:${nodeport}/v2/articles?amount=10\" -H \"accept: application/json\"
  _out Wait until the pod has been started: \"kubectl get pod --watch | grep articles-reactive\"
}

local_env
setup_logging
login
setup