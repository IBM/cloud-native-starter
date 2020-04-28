#!/bin/bash

root_folder=$(cd $(dirname $0); cd ..; pwd)
cns_root_folder=$(cd $(dirname $0); cd ../..; pwd)
exec 3>&1

function _out() {
  echo "$(date +'%F %H:%M:%S') $@"
}

function setup_logging () {
  # SETUP logging (redirect stdout and stderr to a log file)
  LOG_FILE=${root_folder}/iks-scripts/deploy-web-app-reactive.log  
  touch $LOG_FILE
}

function login () {
  _out Logging into IBM Cloud
  ibmcloud config --check-version=false >> $LOG_FILE 2>&1
  ibmcloud api --unset >> $LOG_FILE 2>&1
  ibmcloud api https://cloud.ibm.com >> $LOG_FILE 2>&1
  ibmcloud login --apikey $IBMCLOUD_API_KEY -r $IBM_CLOUD_REGION >> $LOG_FILE 2>&1
}

function login_cr () {
    _out Logging into IBM Cloud Image Registry
    # Login to IBM Cloud Image Registry
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
}

function setup() {
  _out Deploying web-app-reactive # >> $LOG_FILE 2>&1
  
  cd ${root_folder}/web-app-reactive
  kubectl delete -f deployment/IKS-kubernetes.yaml --ignore-not-found

  clusterip=$(ibmcloud ks workers --cluster $CLUSTER_NAME | awk '/Ready/ {print $2;exit;}')
  nodeport=$(kubectl get svc web-api-reactive --output 'jsonpath={.spec.ports[*].nodePort}')

  if [ -z "$nodeport" ]; then
    _out web-api-reactive is not available. Run the command: sh iks-scripts/deploy-web-api-reactive.sh
  else 
    _out Configure source code
    cd ${root_folder}/web-app-reactive/src
    sed "s/endpoint-api-ip:ingress-np/${clusterip}:${nodeport}/g" store.js.template > store.js
    _out End - Configure source code

    # Login to IBM Cloud Image Registry
    login_cr

    cd ${root_folder}/web-app-reactive

    _out Build container web-app-reactive
    # docker build replacement for ICR 
    echo ${root_folder}
    echo $REGISTRY/$REGISTRY_NAMESPACE
    ibmcloud cr build -f ${root_folder}/web-app-reactive/Dockerfile --tag $REGISTRY/$REGISTRY_NAMESPACE/web-app-reactive:latest . # >> $LOG_FILE 2>&1
    _out End - Build container web-app-reactive
    
    _out Create IKS-deployment file 
    # Add ICR tags to K8s deployment.yaml  
    sed "s+web-app-reactive:latest+$REGISTRY/$REGISTRY_NAMESPACE/web-app-reactive:latest+g" ${root_folder}/web-app-reactive/deployment/kubernetes.yaml > ${root_folder}/web-app-reactive/deployment/temp-kubernetes.yaml 
  
    # Replace imagePullPolicy
    sed "s+Never+Always+g" ${root_folder}/web-app-reactive/deployment/temp-kubernetes.yaml > ${root_folder}/web-app-reactive/deployment/IKS-kubernetes.yaml 
  
    rm ${root_folder}/web-app-reactive/deployment/temp-kubernetes.yaml
    _out End - Create IKS-deployment file 

     _out Deploying web-app-reactive to kubernetes
    kubectl apply -f ${root_folder}/web-app-reactive/deployment/IKS-kubernetes.yaml # >> $LOG_FILE 2>&1

    #clusterip=$(ibmcloud ks workers --cluster $CLUSTER_NAME | awk '/Ready/ {print $2;exit;}') 
    nodeport=$(kubectl get svc web-app-reactive --output 'jsonpath={.spec.ports[*].nodePort}')
    _out End - deploying web-app-reactive
    _out Wait until the pod has been started: "kubectl get pod --watch | grep web-app-reactive"
    _out Open the app: http://${clusterip}:${nodeport}/
  fi
}

local_env
setup_logging
login
setup