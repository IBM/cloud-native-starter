#!/bin/bash

root_folder=$(cd $(dirname $0); cd ..; pwd)

exec 3>&1

function _out() {
  echo "$(date +'%F %H:%M:%S') $@"
}

function checkPrerequisites() {
    MISSING_TOOLS=""
    git --version &> /dev/null || MISSING_TOOLS="${MISSING_TOOLS} git"
    curl --version &> /dev/null || MISSING_TOOLS="${MISSING_TOOLS} curl"
    which sed &> /dev/null || MISSING_TOOLS="${MISSING_TOOLS} sed"
    docker -v &> /dev/null || MISSING_TOOLS="${MISSING_TOOLS} docker"
    kubectl version &> /dev/null || MISSING_TOOLS="${MISSING_TOOLS} kubectl"
    ibmcloud --version &> /dev/null|| MISSING_TOOLS="${MISSING_TOOLS} ibmcloud CLI"
    if [[ -n "$MISSING_TOOLS" ]]; then
      _out "Some tools (${MISSING_TOOLS# }) could not be found, please install them first"
      exit 1
    else
      _out You have all necessary prerequisites installed
    fi
    if  ! kubectl describe namespace default | grep istio-injection=enabled ; then
       _out "Istio automatic sidecar injection needs to be enabled. See LocalEnvironment.md"
    fi   
}

checkPrerequisites