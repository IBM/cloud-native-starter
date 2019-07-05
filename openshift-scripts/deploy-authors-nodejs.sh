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

function _out() {
  echo "$(date +'%F %H:%M:%S') $@"
}

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

function setup() {
  _out Deploying authors-nodejs

  cd ${root_folder}/authors-nodejs

  # Delete previously created objects
  oc delete all -l app=authors --ignore-not-found
  oc delete pod authors-1-build --ignore-not-found
  
  # Create build and image
  sed -e "s|<URL>|local|g" -e "s|<DB>|local|g" ../config.json.template > ../config.json
  oc new-build --name authors --binary --strategy docker --to authors:1 -l app=authors
  oc start-build authors --from-dir=.
  
  # Deployment
  cd ${root_folder}/authors-nodejs/deployment
  sed -e "s+<URL>+local+g" -e "s+<DB>+local+g" -e "s+authors:1+docker-registry.default.svc:5000/cloud-native-starter/authors:1+g" deployment.yaml.template > deployment-openshift.yaml  
  oc apply -f deployment-openshift.yaml
  ## No Istio for the time being
  ##oc apply -f istio.yaml
  oc expose svc/authors

  _out Done Deploying authors-nodejs
  _out The build will take a while. Check with "oc get pod --watch | grep authors"
  _out There will be 2 pods.
  _out The pod authors-1-build must reach status Completed first.
  _out Until then the pod authors-xxxxxxxxx-yyyyy will be in status ImagePullBackOff or ErrImagePull.
  _out Sample request: curl http://$(oc get route authors -o jsonpath={.spec.host})/api/v1/getauthor?name=Harald%20Uebele  

} 

openshift_url
login
setup    