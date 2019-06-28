#!/bin/bash

root_folder=$(cd $(dirname $0); cd ..; pwd)

exec 3>&1

function _out() {
  echo "$(date +'%F %H:%M:%S') $@"
}

function test() {
  command -v minishift >/dev/null 2>&1 || { echo >&2 "You need to install minishift first!  Aborting."; exit 1; }
}

function setup() {
  minishift profile set istio
  minishift config set vm-driver virtualbox
  minishift config set memory 8GB 
  minishift config set cpus 4
  minishift config set image-caching true 
  minishift config set openshift-version v3.10.0
  minishift addon enable admin-user
  minishift addon enable anyuid
  minishift addon enable admissions-webhook
  minishift start
}

test
setup