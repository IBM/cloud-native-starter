#!/bin/bash

root_folder=$(cd $(dirname $0); cd ..; pwd)
logname="open-monitoring.log"

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

function startMinikube(){
  _out start minikube
  #minikube start
  #eval $(minikube docker-env)
  kubectl get pod -n istio-system
}

function openMonitoring(){
  _out forward port Jaeger
  open -a Terminal "./open-monitoring-jaeger.sh"
  _out open Jaeger Dashboard browser
  open "http://localhost:16686"

  _out forward port Grafana
  open -a Terminal "./open-monitoring-grafana.sh"

  _out open Grafana Dashboard browser
  open "http://localhost:3000/dashboard/db/istio-mesh-dashboard"

  _out forward port Prometheus
  open -a Terminal "./open-monitoring-prometheus.sh"

  _out open Prometheus Dashboard browser
  open "http://localhost:9090"

  _out open Kiali
  open -a Terminal "./open-monitoring-kiali.sh"
}

#exection starts from here

setupLog
startMinikube
openMonitoring





