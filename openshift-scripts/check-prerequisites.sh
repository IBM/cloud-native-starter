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
    awk --version &> /dev/null || MISSING_TOOLS="${MISSING_TOOLS} awk"
    #docker -v &> /dev/null || MISSING_TOOLS="${MISSING_TOOLS} docker"
    unzip -version &> /dev/null || MISSING_TOOLS="${MISSING_TOOLS} unzip"
    ibmcloud --version &> /dev/null|| MISSING_TOOLS="${MISSING_TOOLS} ibmcloud CLI"
    #kubectl version --client=true &> /dev/null || MISSING_TOOLS="${MISSING_TOOLS} kubectl"
    oc version &> /dev/null || MISSING_TOOLS="${MISSING_TOOLS} oc"
    #mvn -v &> /dev/null || MISSING_TOOLS="${MISSING_TOOLS} mvn"
    if [[ -n "$MISSING_TOOLS" ]]; then
      _out "Some tools (${MISSING_TOOLS# }) could not be found, please install them first"
      exit 1
    else
      _out You have all necessary prerequisites installed
    fi
}

checkPrerequisites
