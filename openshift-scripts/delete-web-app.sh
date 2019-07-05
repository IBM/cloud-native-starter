#!/bin/bash

root_folder=$(cd $(dirname $0); cd ..; pwd)

exec 3>&1

CFG_FILE=${root_folder}/local.env
# Check if config file exists, in this case it will have been modified
if [ ! -f $CFG_FILE ]; then
     _out Config file local.env is missing! Check our instructions!
     exit 1
fi  
source $CFG_FILE

function _out() {
  echo "$(date +'%F %H:%M:%S') $@"
}

function openshift_url() {
# Check if OpenShift Cluster URL has been retreived already  
if [ .$OPENSHIFT_URL == . ]; then
  _out Cannot find a link your OpenShift cluster! 
  _out Did you mss to run the script "openshift-scripts/setup-project.sh"?
  exit 1
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
  _out Deleting web-app-vuejs

  cd ${root_folder}/web-app-vuejs

  # Delete previously created objects
  oc delete all -l app=web-app --ignore-not-found
  oc delete pod web-app-1-build --ignore-not-found
  
  _out Done Deleting web-app-vuejs
} 

openshift_url
login
setup    