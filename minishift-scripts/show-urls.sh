#!/bin/bash

root_folder=$(cd $(dirname $0); cd ..; pwd)

exec 3>&1

function login() {
  oc login -u admin -p admin
  oc project cloud-native-starter
}

function _out() {
  echo "$(date +'%F %H:%M:%S') $@"
}

function setup() {

  _out ------------------------------------------------------------------------------------
  
  _out kiali
  _out Open https://$(oc get route kiali -n istio-system -o jsonpath={.spec.host}) with username: admin, password: admin
 
  _out ------------------------------------------------------------------------------------

  _out prometheus
  _out Open https://$(oc get route prometheus -n istio-system -o jsonpath={.spec.host}) 
 
  _out ------------------------------------------------------------------------------------

  _out jaeger
  _out Access via Kiali: Distributed Tracing

  _out ------------------------------------------------------------------------------------

  _out articles
  _out OpenAPI explorer: http://$(oc get route articles -o jsonpath={.spec.host})/openapi/ui/
  _out Sample request: curl -X GET "http://$(oc get route articles -o jsonpath={.spec.host})/articles/v1/getmultiple?amount=10" -H "accept: application/json"
  
  _out ------------------------------------------------------------------------------------

  _out authors
  _out Sample request: curl http://$(oc get route authors -o jsonpath={.spec.host})/api/v1/getauthor?name=Harald%20Uebele

  _out ------------------------------------------------------------------------------------
  
  _out web-api

  _out OpenAPI explorer: http://$(oc get route web-api -o jsonpath={.spec.host})/openapi/ui/
  _out Sample request: curl "http://$(oc get route web-api -o jsonpath={.spec.host})/web-api/v1/getmultiple"

  _out ------------------------------------------------------------------------------------
  
  _out web-app

  _out Access service via http://$(oc get route web-app -o jsonpath={.spec.host}) or via
  _out Istio Ingress http://$(oc get route istio-ingressgateway -n istio-system -o jsonpath={.spec.host})

  _out ------------------------------------------------------------------------------------

}

login
setup