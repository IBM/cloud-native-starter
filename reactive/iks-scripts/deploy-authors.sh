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
   _out Deploying authors
  
  cd ${cns_root_folder}/authors
  kubectl delete -f deployment/IKS-kubernetes.yaml --ignore-not-found

  clusterip=$(ibmcloud ks workers --cluster $CLUSTER_NAME | awk '/Ready/ {print $2;exit;}')

  # Login to IBM Cloud Image Registry
  _out Set IBM Cloud Image Registry
  source ${root_folder}/iks-scripts/logincr.sh

  cd ${cns_root_folder}/authors-nodejs 

  _out Build container authors
  # docker build replacement for ICR 
  ibmcloud cr build -f ${cns_root_folder}/authors-nodejs/Dockerfile --tag $REGISTRY/$REGISTRY_NAMESPACE/authors:1 .

  # Add ICR tags to K8s deployment.yaml
  sed -e "s|<URL>|notused|g" -e "s|<DB>|local|g" ${cns_root_folder}/authors-nodejs/deployment/deployment.yaml.template > ${cns_root_folder}/authors-nodejs/deployment/temp-deployment.yaml

  sed "s+authors:1+$REGISTRY/$REGISTRY_NAMESPACE/authors:1+g" ${cns_root_folder}/authors-nodejs/deployment/temp-deployment.yaml > ${cns_root_folder}/authors-nodejs/deployment/IKS-kubernetes.yaml 
  
  rm ${cns_root_folder}/authors-nodejs/deployment/temp-deployment.yaml 

  kubectl apply -f ${cns_root_folder}/authors-nodejs/deployment/IKS-kubernetes.yaml 

  clusterip=$(ibmcloud ks workers --cluster $CLUSTER_NAME | awk '/Ready/ {print $2;exit;}') 
  nodeport=$(kubectl get svc authors --output 'jsonpath={.spec.ports[*].nodePort}')

  _out Done deploying authors
  _out Wait until the pod has been started: \"kubectl get pod --watch | grep authors\"
  nodeport=$(kubectl get svc authors --ignore-not-found --output 'jsonpath={.spec.ports[*].nodePort}')
  _out Sample API call: \"curl http://$(clusterip):${nodeport}/api/v1/getauthor?name=Niklas%20Heidloff\"
}

local_env
source ${root_folder}/iks-scripts/login.sh
setup