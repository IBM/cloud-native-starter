#!/bin/bash

root_folder=$(cd $(dirname $0); cd ..; pwd)
logname="create-demo-load.log"
max="200"

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

function createDemoLoad(){
  minikubeip=$(minikube ip)
  ingressport=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.spec.ports[?(@.name=="http2")].nodePort}')
  _out starting calling curl http://$minikubeip:${ingressport}/web-api/v1/getmultiple
  i="0"
  while [ $i -lt $max ]
  do
   curl http://$minikubeip:${ingressport}/web-api/v1/getmultiple
   i=$[$i+1]
   _out loop $i
   sleep .5
  done
}

#exection starts from here

setupLog
createDemoLoad





