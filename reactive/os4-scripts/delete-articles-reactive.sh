#!/bin/bash

root_folder=$(cd $(dirname $0); cd ..; pwd)

exec 3>&1

function _out() {
  echo "$(date +'%F %H:%M:%S') $@"
}

function setup() {

  oc delete all -l app=articles-reactive --ignore-not-found

}

source ${root_folder}/os4-scripts/login.sh
setup
