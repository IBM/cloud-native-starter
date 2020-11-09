#!/bin/bash

root_folder=$(cd $(dirname $0); cd ..; pwd)

exec 3>&1

function _out() {
  echo "$(date +'%F %H:%M:%S') $@"
}

CFG_FILE=${root_folder}/local.env
# Check if config file exists
if [ ! -f $CFG_FILE ]; then
     _out Config file local.env is missing! Check our instructions!
     exit 1
fi  
source $CFG_FILE


# Login to IBM Cloud Image Registry
ibmcloud cr region-set $IBM_CLOUD_REGION
ibmcloud cr login


function templates() {
  _out Preparing YAML files for Kubernetes Deployment

  # Check if config file exists, in this case it will have been modified
  #template=${root_folder}/scripts/template.deploy-authors-nodejs.cfg
  #cfgfile=${root_folder}/scripts/deploy-authors-nodejs.cfg
  #if [ ! -f $cfgfile ]; then
  #   cp $template $cfgfile
  #fi   

  
  _out DB is $AUTHORS_DB
  _out Cloudant URL is $CLOUDANT_URL
  # CLOUDANT_URL is read from local.env
  # '##*@' removes everything up to and including the @ sign
  CLOUDANTHOST=${CLOUDANT_URL##*@}
  cd ${root_folder}/authors-nodejs/deployment
  sed -e "s|<URL>|$CLOUDANT_URL|g" -e "s|<DB>|$AUTHORS_DB|g" deployment.yaml.template > deployment.yaml
  sed "s|<HOST>|$CLOUDANTHOST|g" istio-egress-cloudant.yaml.template > istio-egress-cloudant.yaml
  # cd ${root_folder}/authors-nodejs
  # sed -e "s|<URL>|$CLOUDANT_URL|g" -e "s|<DB>|$AUTHORS_DB|g" config.json.template > config.json
}

function setup() {

  _out Clean-up 
  if [ $AUTHORS_DB != "local" ]; then
     kubectl delete serviceentry cloudant --ignore-not-found
     kubectl delete gateway istio-egressgateway --ignore-not-found
     kubectl delete destinationrule egressgateway-for-cloudant --ignore-not-found
  fi
  kubectl delete all -l app=authors --ignore-not-found

  
  _out Build Docker Image
  cd ${root_folder}/authors-nodejs
  # docker build for ICR
  docker build -f Dockerfile --tag $REGISTRY/$REGISTRY_NAMESPACE/authors:1 .
  docker push $REGISTRY/$REGISTRY_NAMESPACE/authors:1
 
  _out Deploy to IKS
  cd ${root_folder}/authors-nodejs/deployment
  # Add ICR tags to K8s deployment.yaml  
  sed "s+authors:1+$REGISTRY/$REGISTRY_NAMESPACE/authors:1+g" deployment.yaml > IKS-deployment.yaml  
  kubectl apply -f IKS-deployment.yaml 
  kubectl apply -f istio.yaml

  if [ $AUTHORS_DB != "local" ]; then
     kubectl create -f istio-egress-cloudant.yaml
  fi

  _out Done deploying authors-nodejs
  _out Wait until the pod has been started. Check with this command: 
  _out "kubectl get pod --watch | grep authors"
}

_out Deploying authors-nodejs
templates
setup
