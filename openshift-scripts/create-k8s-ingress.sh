#!/bin/bash

root_folder=$(cd $(dirname $0); cd ..; pwd)

exec 3>&1

function _out() {
  echo "$(date +'%F %H:%M:%S') $@"
}

CFG_FILE=${root_folder}/local.env
# Check if config file exists, in this case it will have been modified
if [ ! -f $CFG_FILE ]; then
     _out Config file local.env is missing! Check our instructions!
     exit 1
fi  
source $CFG_FILE


function openshift_url() {
# Check if OpenShift Cluster URL has been retreived already  
if [ .$OPENSHIFT_URL == . ]; then
  _out Cannot find a link your OpenShift cluster! 
  _out Did you miss to run the script "openshift-scripts/setup-project.sh"?
  exit 1
fi
# Check for K8s Ingress URL
if [ .$INGRESS == . ]; then
  _out No Kubernetes Ingress URL set!
  _out Did you run the script "openshift-scripts/setup-project.sh"?
  exit -1
fi  
}

function login() {
  oc login -u apikey -p $IBMCLOUD_API_KEY --server=$OPENSHIFT_URL
  if [ ! $? == 0 ]; then
    _out ERROR: Could not login to OpenShift, please try again
    exit 1
  fi  
  oc project cloud-native-starter
}

function setup() {
  _out Creating Ingress for Web-App

  cd ${root_folder}/openshift-scripts

  # Delete previously created objects
  oc delete ingress cloudnative-ingress --ignore-not-found
  
  # Create ingress
  sed -e "s|#INGRESS|$INGRESS|g" k8s-ingress.yaml.template > k8s-ingress.yaml
  oc apply -f k8s-ingress.yaml

  _out Done Creating Ingress
  _out The web-app can be reached via http://cloudnative.$INGRESS

} 

openshift_url
login
setup    