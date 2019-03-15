#!/bin/bash

root_folder=$(cd $(dirname $0); cd ..; pwd)
logname="open-monitoring-jaeger.log"

function setupLog(){
 cd "${root_folder}/scripts"
 readonly LOG_FILE="${root_folder}/scripts/$logname"
 touch $LOG_FILE
 exec 3>&1 # Save stdout
 exec 4>&2 # Save stderr
 exec 1>$LOG_FILE 2>&1
 exec 3>&1
}

function _out() {
  echo "$(date +'%F %H:%M:%S') $@"
}

function forwardPort(){
  _out start Jaeger
  kubectl port-forward -n istio-system $(kubectl get pod -n istio-system -l app=jaeger -o jsonpath='{.items[0].metadata.name}') 16686:16686
}

#exection starts from here

setupLog
forwardPort