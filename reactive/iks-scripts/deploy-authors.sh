#!/bin/bash

root_folder=$(cd $(dirname $0); cd ..; pwd)
cns_root_folder=$(cd $(dirname $0); cd ../..; pwd)
exec 3>&1

function _out() {
  echo "$(date +'%F %H:%M:%S') $@"
}

function setup_logging () {
  # SETUP logging (redirect stdout and stderr to a log file)
  LOG_FILE=${root_folder}/iks-scripts/deploy-authors.log  
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

  _out Verify that the file "cluster-config.sh" exists
  CLUSTER_CFG=${root_folder}/iks-scripts/cluster-config.sh
  # Check if config file exists
  if [ ! -f $CLUSTER_CFG ]; then
      _out Cluster config file iks-scripts/cluster-config.sh is missing! Run iks-scripts/cluster-get-config.sh first!
      exit 1
  fi  
  source $CLUSTER_CFG
  _out End - Verify "cluster-config.sh" exists
}

function setup() {
   _out Deploying authors
  
  cd ${cns_root_folder}/authors-nodejs
  kubectl delete -f deployment/IKS-kubernetes.yaml --ignore-not-found >> $LOG_FILE 2>&1
  
  clusterip=$(ibmcloud ks workers --cluster $CLUSTER_NAME | awk '/Ready/ {print $2;exit;}')

  # Login to IBM Cloud Image Registry
  login_cr

  cd ${cns_root_folder}/authors-nodejs #>> $LOG_FILE 2>&1

  _out Build container authors
  # docker build replacement for ICR 
  ibmcloud cr build -f ${cns_root_folder}/authors-nodejs/Dockerfile --tag $REGISTRY/$REGISTRY_NAMESPACE/authors:1 . #>> $LOG_FILE 2>&1

  # Add ICR tags to K8s deployment.yaml
  _out Create IKS-deployment file
  sed -e "s|<URL>|notused|g" -e "s|<DB>|local|g" ${cns_root_folder}/authors-nodejs/deployment/deployment.yaml.template > ${cns_root_folder}/authors-nodejs/deployment/temp-deployment.yaml

  sed "s+authors:1+$REGISTRY/$REGISTRY_NAMESPACE/authors:1+g" ${cns_root_folder}/authors-nodejs/deployment/temp-deployment.yaml > ${cns_root_folder}/authors-nodejs/deployment/IKS-kubernetes.yaml #>> $LOG_FILE 2>&1
  
  rm ${cns_root_folder}/authors-nodejs/deployment/temp-deployment.yaml #>> $LOG_FILE 2>&1
  _out End IKS-deployment file
  
  _out Deploying authors to kubernetes
  kubectl apply -f ${cns_root_folder}/authors-nodejs/deployment/IKS-kubernetes.yaml  #>> $LOG_FILE 2>&1

  clusterip=$(ibmcloud ks workers --cluster $CLUSTER_NAME | awk '/Ready/ {print $2;exit;}') #>> $LOG_FILE 2>&1
  nodeport=$(kubectl get svc authors --output 'jsonpath={.spec.ports[*].nodePort}') #>> $LOG_FILE 2>&1

  _out End - deploying authors
  _out Wait until the pod has been started: \"kubectl get pod --watch | grep authors\"
  nodeport=$(kubectl get svc authors --ignore-not-found --output 'jsonpath={.spec.ports[*].nodePort}')
  _out Sample API call: \"curl 'http://${clusterip}:${nodeport}/api/v1/getauthor?name=Niklas%20Heidloff'\"
}

local_env
setup_logging
login
setup