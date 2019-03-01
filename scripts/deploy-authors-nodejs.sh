#!/bin/bash -e

root_folder=$(cd $(dirname $0); cd ..; pwd)

exec 3>&1

function _out() {
  echo "$(date +'%F %H:%M:%S') $@"
}

function templates() {
  _out Preparing YAML files for Kubernetes Deployment

  cfgfile=deploy-authors-nodejs.cfg

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


}

function setup() {
  _out Deploying authors-nodejs
  
  cd ${root_folder}/authors-nodejs

  _out Clean-up Minikube
  #istioctl delete serviceentry cloudant
  #istioctl delete virtualservice cloudant
  #kubectl delete all -l app=authors-service


  
  _out Build Docker Image
  eval $(minikube docker-env)
  #docker build -f Dockerfile.previousdownload -t articles:1 .

  #kubectl apply -f deployment/kubernetes.yaml
  #kubectl apply -f deployment/istio.yaml

  
  _out Done deploying authors-nodejs
  }

templates
setup