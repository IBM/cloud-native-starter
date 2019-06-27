#!/bin/bash

root_folder=$(cd $(dirname $0); cd ..; pwd)

exec 3>&1

function _out() {
  echo "$(date +'%F %H:%M:%S') $@"
}

function setup() {
  oc login -u admin -p admin
  oc new-project cloud-native-starter
  oc adm policy add-scc-to-user anyuid -z default -n cloud-native-starter
  oc adm policy add-scc-to-user privileged -z default -n cloud-native-starter
  oc adm policy add-role-to-user admin developer
  cd ${root_folder}/minishift-scripts
  oc apply -f no-mtls.yaml
}

setup
