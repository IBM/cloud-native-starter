#!/bin/bash

root_folder=$(cd $(dirname $0); cd ..; pwd)
cns_root_folder=$(cd $(dirname $0); cd ../..; pwd)
exec 3>&1

function _out() {
  echo "$(date +'%F %H:%M:%S') $@"
}

function setup_logging () {
  # SETUP logging (redirect stdout and stderr to a log file)
  readonly WEBAPP_LOG_FILE=${root_folder}/iks-scripts/deploy-web-app.log 
  touch $WEBAPP_LOG_FILE
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
  _out Deploying web-app-reactive
  
  cd ${root_folder}/web-app-reactive
  kubectl delete -f deployment/IKS-kubernetes.yaml --ignore-not-found

  clusterip=$(ibmcloud ks workers --cluster $CLUSTER_NAME | awk '/Ready/ {print $2;exit;}')
  nodeport=$(kubectl get svc web-api-reactive --output 'jsonpath={.spec.ports[*].nodePort}')

  if [ -z "$nodeport" ]; then
    _out web-api-reactive is not available. Run the command: sh iks-scripts/deploy-web-api-reactive.sh
  else 

    cd ${root_folder}/web-app-reactive/src
    sed "s/endpoint-api-ip:ingress-np/${clusterip}:${nodeport}/g" store.js.template > store.js

     # Login to IBM Cloud Image Registry
    _out Set IBM Cloud Image Registry
    source ${root_folder}/iks-scripts/logincr.sh

    cd ${root_folder}/web-app-reactive

    _out Build container web-app-reactive
    # docker build replacement for ICR 
    echo ${root_folder}
    echo $REGISTRY/$REGISTRY_NAMESPACE
    ibmcloud cr build -f ${root_folder}/web-app-reactive/Dockerfile --tag $REGISTRY/$REGISTRY_NAMESPACE/web-app-reactive:latest .

    # Add ICR tags to K8s deployment.yaml  
    sed "s+web-app-reactive:latest+$REGISTRY/$REGISTRY_NAMESPACE/web-app-reactive:latest+g" ${root_folder}/web-app-reactive/deployment/kubernetes.yaml > ${root_folder}/web-app-reactive/deployment/temp-kubernetes.yaml 
  
    # Replace imagePullPolicy
    sed "s+Never+Always+g" ${root_folder}/web-app-reactive/deployment/temp-kubernetes.yaml > ${root_folder}/web-app-reactive/deployment/IKS-kubernetes.yaml 
  
    rm ${root_folder}/web-app-reactive/deployment/temp-kubernetes.yaml 

    kubectl apply -f ${root_folder}/web-app-reactive/deployment/IKS-kubernetes.yaml 

    clusterip=$(ibmcloud ks workers --cluster $CLUSTER_NAME | awk '/Ready/ {print $2;exit;}') 
    nodeport=$(kubectl get svc web-app-reactive --output 'jsonpath={.spec.ports[*].nodePort}')
    _out Done deploying web-app-reactive
    _out Wait until the pod has been started: "kubectl get pod --watch | grep web-app-reactive"
    _out Open the app: http://${clusterip}:${nodeport}/
  fi
}

local_env
source ${root_folder}/iks-scripts/login.sh
setup