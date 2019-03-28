#!/bin/bash

root_folder=$(cd $(dirname $0); cd ..; pwd)

exec 3>&1

function _out() {
  echo "$(date +'%F %H:%M:%S') $@"
}

function setup() {
  _out Configuring Prometheus
  
  cd ${root_folder}/istio

  rm ${root_folder}/istio/prometheus-config-new.yaml

  rm ${root_folder}/istio/prometheus-config-org.yaml
  kubectl get configmap prometheus -n istio-system -oyaml > ${root_folder}/istio/prometheus-config-org.yaml
  
  sed -e '/kind: ConfigMap/r ./prometheus-config.yaml' -e '/kind: ConfigMap/d' ${root_folder}/istio/prometheus-config-org.yaml > ${root_folder}/istio/prometheus-config-new.yaml

  kubectl replace --force -f ${root_folder}/istio/prometheus-config-new.yaml

  pod=$(kubectl get pods -n istio-system | grep prometheus | awk ' {print $1} ')
  kubectl delete pod $pod -n istio-system

  _out Done configuring Prometheus

  _out Wait until the pod has been started: "kubectl get pod -n istio-system --watch | grep prometheus"

  command1="kubectl -n istio-system port-forward $"
  command2="(kubectl -n istio-system get pod -l app=prometheus -o jsonpath='{.items[0].metadata.name}') 9090:9090 &"
  _out Run the command: ${command1}${command2}
  _out Then open http://localhost:9090/
}

setup