#!/bin/bash

root_folder=$(cd $(dirname $0); cd ..; pwd)

exec 3>&1

CFG_FILE=${root_folder}/local.env
# Check if config file exists, in this case it will have been modified
if [ ! -f $CFG_FILE ]; then
     _out Config file local.env is missing!
     _out -- Copy template.local.env to local.env and edit according to our instructions!
     exit 1
fi  
source $CFG_FILE

function _out() {
  echo "$(date +'%F %H:%M:%S') $@"
}

function openshift_url() {
# Check if OpenShift Cluster URL has been retreived already  

if [ .$OPENSHIFT_URL == . ]; then
  ibmcloud api https://cloud.ibm.com 
  ibmcloud login --apikey $IBMCLOUD_API_KEY -r $IBM_CLOUD_REGION
  url=$(ibmcloud ks cluster-get --cluster $CLUSTER_NAME |  awk '/^Master URL/ {print $3}')
  _out OpenShift Master URL $url 
  echo "\nOPENSHIFT_URL=$url\n" >> $CFG_FILE
fi
}

function setup() {
   oc login -u apikey -p $IBMCLOUD_API_KEY --server=$OPENSHIFT_URL
   oc new-project cloud-native-starter
   oc project cloud-native-starter
   # "anyuid"
   oc adm policy add-scc-to-user anyuid -z default
} 

openshift_url
setup    