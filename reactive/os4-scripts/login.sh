#!/bin/bash

root_folder=$(cd $(dirname $0); cd ..; pwd)

exec 3>&1

function _out() {
  echo "$(date +'%F %H:%M:%S') $@"
}


CFG_FILE=${root_folder}/../local.env
# Check if config file exists, in this case it will have been modified
if [ ! -f $CFG_FILE ]; then
    _out Config file local.env is missing! Check our instructions!
    exit 1
else
    _out --- Config file local.env found 
fi  
source $CFG_FILE

_out --- Login to OpenShift
oc login --token=$APITOKEN --server=$OS4SERVER > /dev/null
    if [ $? != 0 ]; then 
    _out Log in to OpenShift failed, most likely due to expired API token in local.env
    exit 1   
else
    _out ----- OK   
fi

_out --- Login to OpenShift Container Registry
oc whoami -t | docker login -u developer --password-stdin $REGISTRYURL  > /dev/null 
if [ $? != 0 ]; then 
    _out Log in to OpenShift Container Registry failed!
    exit 1 
else
    _out ----- OK 
fi

oc project $PROJECT  > /dev/null 2>&1
if [ $? != 0 ]; then 
    oc new-project $PROJECT
fi

