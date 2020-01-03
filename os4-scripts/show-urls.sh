#!/bin/bash

root_folder=$(cd $(dirname $0); cd ..; pwd)

exec 3>&1

function _out() {
  echo "$(date +'%F %H:%M:%S') $@"
}

function setup() {

  _out ------------------------------------------------------------------------------------
  _out kiali
  _out URL: https://$(oc get route kiali -n istio-system -o jsonpath={.spec.host})
  _out Login credentials on CRC: crc console --credentials
  _out ------------------------------------------------------------------------------------

  _out prometheus
  _out URL: https://$(oc get route prometheus -n istio-system -o jsonpath={.spec.host})
  _out Login credentials on CRC: crc console --credentials
  _out ------------------------------------------------------------------------------------

  _out jaeger
  _out URL: https://$(oc get route jaeger -n istio-system -o jsonpath={.spec.host})
  _out Login credentials on CRC: crc console --credentials
  _out ------------------------------------------------------------------------------------

  _out grafana
  _out URL: https://$(oc get route grafana -n istio-system -o jsonpath={.spec.host})
  _out Login credentials on CRC: crc console --credentials
  _out ------------------------------------------------------------------------------------

  _out articles
  URL=$(oc get route articles --template='{{ .spec.host }}')
  if [ -z "$URL" ]; then
    _out articles is not available. Run 'os4-scripts/deploy-articles-java-jee.sh'
  else 
    _out Open the OpenAPI explorer: http://$URL/openapi/ui/
  fi
  _out ------------------------------------------------------------------------------------

  _out authors
  URL=$(oc get route authors --template='{{ .spec.host }}')
  if [ -z "$URL" ]; then
    _out authors is not available. Run 'os4-scripts/deploy-authors-nodejs.sh'
  else 
    _out Sample API call: 
    _out curl http://$URL/api/v1/getauthor?name=Niklas%20Heidloff
  fi
  _out ------------------------------------------------------------------------------------
  
  _out web-api
  URL=$(oc get route web-api --template='{{ .spec.host }}')
  if [ -z "$URL" ]; then
    _out articles is not available. Run 'os4-scripts/deploy-web-api-java-jee.sh'
  else 
    _out Open the OpenAPI explorer: http://$URL/openapi/ui/
  fi
  _out ------------------------------------------------------------------------------------
  
  _out web-app
  ingressgw=$(oc get route istio-ingressgateway -n istio-system --template='{{ .spec.host }}')
  URL=$(oc get route web-app --template='{{ .spec.host }}')
if [ -z "$URL" ]; then
    _out web-app is not available. Run 'os4-scripts/deploy-web-app-vuejs.sh'
  else 
    _out Open the app: http://$URL
    _out or through the Istio Ingress Gateway, this requires  os4-scripts/deploy-istio-ingress-v1.sh 
    _out http://${ingressgw}/
  fi 

  _out ------------------------------------------------------------------------------------

}

source ${root_folder}/os4-scripts/login.sh
setup
