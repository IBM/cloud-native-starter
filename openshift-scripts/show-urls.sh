#!/bin/bash

root_folder=$(cd $(dirname $0); cd ..; pwd)

exec 3>&1

function _out() {
  echo "$(date +'%F %H:%M:%S') $@"
}

CFG_FILE=${root_folder}/local.env
# Check if config file exists, in this case it will have been modified
if [ ! -f $CFG_FILE ]; then
     _out Config file local.env is missing! Check our instructions!
     exit 1
fi  
source $CFG_FILE


function login() {
  oc login -u apikey -p $IBMCLOUD_API_KEY --server=$OPENSHIFT_URL
  if [ ! $? == 0 ]; then
    _out ERROR: Could not login to OpenShift, please try again
    exit 1
  fi  
  oc project cloud-native-starter
}

function openshift_url() {
# Check if OpenShift Cluster URL has been retreived already  
if [ .$OPENSHIFT_URL == . ]; then
  _out Cannot find a link your OpenShift cluster! 
  _out Did you mss to run the script "openshift-scripts/setup-project.sh"?
  exit 1
fi
}

function setup() {
  _out ------------------------------------------------------------------------------------
  _out URLS

# Currently no Istio!
#  _out ------------------------------------------------------------------------------------
#  
#  _out kiali
#  _out Open https://$(oc get route kiali -n istio-system -o jsonpath={.spec.host}) with username: admin, password: admin
# 
#  _out ------------------------------------------------------------------------------------
#
#  _out prometheus
#  _out Open https://$(oc get route prometheus -n istio-system -o jsonpath={.spec.host}) 
# 
#  _out ------------------------------------------------------------------------------------
#
#  _out jaeger
#  _out Access via Kiali: Distributed Tracing
#
#  _out ------------------------------------------------------------------------------------
#
  _out articles
  url=$(oc get route articles -o jsonpath={.spec.host}) &>/dev/null
  if [ -z "$url" ]; then
    _out articles is not available. Run 'minishift-scripts/deploy-articles-java-jee.sh'
  else 
    _out OpenAPI explorer: http://$url/openapi/ui/
    _out Sample request: curl -X GET "http://$url/articles/v1/getmultiple?amount=10" -H "accept: application/json"
  fi
  _out ------------------------------------------------------------------------------------

  _out authors
  url=$(oc get route authors -o jsonpath={.spec.host}) &>/dev/null
  if [ -z "$url" ]; then
    _out authors is not available. Run 'minishift-scripts/deploy-authors-nodejs.sh'
  else 
    _out Sample request: curl http://$url/api/v1/getauthor?name=Harald%20Uebele
  fi

  _out ------------------------------------------------------------------------------------
  
  _out web-api

  url=$(oc get route web-api -o jsonpath={.spec.host}) &>/dev/null
  if [ -z "$url" ]; then
    _out web-api is not available. Run 'minishift-scripts/deploy-web-api-java-jee.sh'
  else 
    _out OpenAPI explorer: http://$url/openapi/ui/
    _out Sample request: curl "http://$url/web-api/v1/getmultiple"

  fi
  
  _out ------------------------------------------------------------------------------------
  
  _out web-app
  url=$(oc get route web-app -o jsonpath={.spec.host}) &>/dev/null
  if [ -z "$url" ]; then
    _out web-app is not available. Run 'minishift-scripts/deploy-web-app.sh'
  else 
  _out Access service via http://$url 
  fi
# Currently no Istio!
#  httpcode=$(curl -s -o /dev/null -w "%{http_code}" $(oc get route istio-ingressgateway -n istio-system -o jsonpath={.spec.host}))
#  if [ $httpcode == 503 ]; then
#    _out Istio Ingress is not configured. Run 'minishift-scripts/deploy-istio-ingress-v1.sh'
#  else 
#  _out or via Istio Ingress http://$url
#  fi
  
  _out ------------------------------------------------------------------------------------

}

openshift_url
login
setup