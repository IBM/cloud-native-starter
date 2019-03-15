#!/bin/bash

root_folder=$(cd $(dirname $0); cd ..; pwd)
logname="open-monitoring-kiali.log"

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

function getMinikubeIP(){
  _out get minikube IP
  MINIKUBE_IP=$(minikube ip)
}

function getKialiPort(){
  _out get Kiali port
  KIALI_PORT=$(kubectl get svc -n istio-system | awk '/kiali/{ print $5 }' | sed 's/[/].*//' | sed 's/.*[:]//')
}

function openKialiDashboard(){
  _out  open Kiali in Browser
  open "https://$MINIKUBE_IP:$KIALI_PORT/kiali"
}

#execution starts here

setupLog
getMinikubeIP
getKialiPort
openKialiDashboard