#!/bin/bash

root_folder=$(cd $(dirname $0); cd ..; pwd)

exec 3>&1

function _out() {
  echo "$(date +'%F %H:%M:%S') $@"
}

function login() {
    CFG_FILE=${root_folder}/local.env
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
       _out Log in to OpenShift failed!
       exit 1   
    else
       _out ----- OK   
    fi

    oc new-project $PROJECT  > /dev/null 2>&1
    if [ $? != 0 ]; then 
      oc project $PROJECT
    fi
}

function delete() {

  _out --- Delete articles
  oc delete all -l app=articles
  oc delete is articles

}


login
delete