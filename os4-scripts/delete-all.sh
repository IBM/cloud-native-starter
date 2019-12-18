#!/bin/bash

root_folder=$(cd $(dirname $0); cd ..; pwd)

exec 3>&1

function _out() {
  echo "$(date +'%F %H:%M:%S') $@"
}

function delete() {

  _out --- Delete articles
  oc delete all -l app=articles
  oc delete is articles
  _out --- Delete authors
  oc delete all -l app=authors --ignore-not-found
  oc delete is authors
  _out --- Delete web-api
  oc delete all -l app=web-api --ignore-not-found
  oc delete is web-api

}

source ${root_folder}/os4-scripts/login.sh
delete