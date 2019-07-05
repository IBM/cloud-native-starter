#!/bin/bash

root_folder=$(cd $(dirname $0); cd ..; pwd)

exec 3>&1

CFG_FILE=${root_folder}/local.env
# Check if config file exists, in this case it will have been modified
if [ ! -f $CFG_FILE ]; then
     _out Config file local.env is missing! Check our instructions!
     exit 1
fi  
source $CFG_FILE

function openshift_url() {
# Check if OpenShift Cluster URL has been retreived already  
if [ .$OPENSHIFT_URL == . ]; then
  _out Cannot find a link your OpenShift cluster! 
  _out Did you mss to run the script "openshift-scripts/setup-project.sh"?
  exit 1
fi
}

function login() {
  oc login -u apikey -p $IBMCLOUD_API_KEY --server=$OPENSHIFT_URL
  if [ ! $? == 0 ]; then
    _out ERROR: Could not login to OpenShift, please try again
    exit 1
  fi  
  oc project cloud-native-starter
}

function _out() {
  echo "$(date +'%F %H:%M:%S') $@"
}

function configureVUEminikubeIP(){
  cd ${root_folder}/web-app-vuejs/src
  
  _out configure API endpoint in web-app
  endpoint=http://$(oc get route web-api -o jsonpath={.spec.host})

  rm "store.js"
  cp "store.js.template" "store.js"
  sed "s/endpoint-api-ip:31380/$endpoint/g" store.js.template > store.js
  
  cd ${root_folder}/web-app-vuejs
}

function setup() {
  _out Deploying web-app
  
  cd ${root_folder}/web-app-vuejs
  oc delete all -l app=web-app --ignore-not-found
  oc delete pod web-app-1-build --ignore-not-found
 
  configureVUEminikubeIP

  oc new-build --name web-app --binary --strategy docker --to web-app:1 -l app=web-app
  oc start-build web-app --from-dir=.

  cd ${root_folder}/web-app-vuejs/deployment
  sed "s+web-app:1+docker-registry.default.svc:5000/cloud-native-starter/web-app:1+g" kubernetes.yaml > kubernetes-openshift.yaml  

  oc apply -f kubernetes-openshift.yaml
  #oc apply -f istio.yaml
  oc expose svc/web-app

  _out Done deploying web-app
  _out The build will take a while. Check with "oc get pod --watch | grep web-app"
  _out There will be 2 pods.
  _out The pod web-app-1-build must reach status Completed first.
  _out Until then the pod web-app-xxxxxxxxx-yyyyy will be in status ImagePullBackOff or ErrImagePull.
  _out Once it is Running, access via http://$(oc get route web-app -o jsonpath={.spec.host})

}

openshift_url
login
setup
