#!/bin/bash

root_folder=$(cd $(dirname $0); cd ..; pwd)

exec 3>&1

function _out() {
  echo "$(date +'%F %H:%M:%S') $@"
}

function templates() {
  _out Preparing YAML files for Kubernetes Deployment

  cfgfile=deploy-authors-nodejs.cfg

set -e
  if [ -f $cfgfile ]
  then
      source $cfgfile
      echo $CLOUDANTURL
      # CLOUDANTURL is read from cfgfile
      # '##*@' removes everything up to and including the @ sign
      CLOUDANTHOST=${CLOUDANTURL##*@}
      cd ${root_folder}/authors-nodejs/deployment
      sed "s|<URL>|$CLOUDANTURL|g" deployment.yaml.template > deployment.yaml
      sed "s|<HOST>|$CLOUDANTHOST|g" istio-egress-cloudant.yaml.template > istio-egress-cloudant.yaml
  else
    echo The config file $cfgfile does not exist!
    exit 1
  fi
set +e  
}

function setup() {

  cd ${root_folder}/authors-nodejs

  _out Clean-up Minikube
  istioctl delete serviceentry cloudant
  istioctl delete virtualservice cloudant
  kubectl delete all -l app=authors-service
  
  _out Build Docker Image
  eval $(minikube docker-env)
  docker build -f Dockerfile -t  authors-service:1 .

  _out Deploy to Minikube
  cd deployment
  kubectl apply -f <(istioctl kube-inject -f deployment.yaml)
  istioctl create -f istio-egress-cloudant.yaml

  _out Done deploying authors-nodejs
  }

echo ""
_out Deploying authors-nodejs
templates
setup