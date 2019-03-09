#!/bin/bash

root_folder=$(cd $(dirname $0); cd ..; pwd)

exec 3>&1

function _out() {
  echo "$(date +'%F %H:%M:%S') $@"
}

function setup() {

  minikubeip=$(minikube ip)

  _out ------------------------------------------------------------------------------------
  nodeport=$(kubectl get svc -n istio-system kiali --output 'jsonpath={.spec.ports[*].nodePort}')
  _out kiali
  _out Web app:      https://${minikubeip}:${nodeport}/kiali
  nodeport=$(kubectl get svc articles --output 'jsonpath={.spec.ports[*].nodePort}')
  _out ------------------------------------------------------------------------------------
  _out articles
  _out API explorer: http://${minikubeip}:${nodeport}/openapi/ui/
  _out Sample API:   curl http://${minikubeip}:${nodeport}/articles/v1/getmultiple?amount=10
  _out ------------------------------------------------------------------------------------
  nodeport=$(kubectl get svc authors --output 'jsonpath={.spec.ports[*].nodePort}')
  _out authors
  _out API explorer: http://${minikubeip}:${nodeport}/explorer
  _out Sample API:   curl http://${minikubeip}:${nodeport}/api/v1/getauthor?name=Niklas%20Heidloff
  _out ------------------------------------------------------------------------------------
  _out web-api
  _out API explorer: http://${minikubeip}:31380/openapi/ui/
  _out Sample API:   curl http://${minikubeip}:31380/web-api/v1/getmultiple
  _out ------------------------------------------------------------------------------------
  _out web-app
  _out Web app:      http://${minikubeip}:31380/
  _out ------------------------------------------------------------------------------------

}

setup