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
  _out Deploying web-api-java-jee

  cd ${root_folder}/web-api-java-jee

  # Delete previously created objects
  oc delete all -l app=web-api --ignore-not-found
  oc delete pod web-api-1-build --ignore-not-found
  oc delete istag web-api:1 --ignore-not-found

  # OpenTracing lib
  file="${root_folder}/web-api-java-jee/liberty-opentracing-zipkintracer-1.2-sample.zip"
  if [ -f "$file" ]
  then
	  echo "$file found"
  else
	  curl -L -o $file https://github.com/WASdev/sample.opentracing.zipkintracer/releases/download/1.2/liberty-opentracing-zipkintracer-1.2-sample.zip
  fi
  unzip -o liberty-opentracing-zipkintracer-1.2-sample.zip -d liberty-opentracing-zipkintracer/

  # Create build and image
  # cp Dockerfiles around because binary build expects "Dockerfile"
  cp Dockerfile Dockerfile.java
  cp Dockerfile.nojava Dockerfile
  oc new-build --name web-api --binary --strategy docker --to web-api:1 -l app=web-api
  oc start-build web-api --from-dir=.
  cp Dockerfile.java Dockerfile
  
  # Deployment
  cd ${root_folder}/web-api-java-jee/deployment
  sed "s+web-api:1+docker-registry.default.svc:5000/cloud-native-starter/web-api:1+g" kubernetes-deployment-v1.yaml > kubernetes-deployment-v1-openshift.yaml  
  oc apply -f kubernetes-deployment-v1-openshift.yaml
  oc apply -f kubernetes-service.yaml
  ## No Istio for the time being
  ##oc apply -f istio.yaml
  oc expose svc/web-api

  _out Done Deploying web-api-java-jee
  _out The build will take a while. Check with "oc get pod --watch | grep web-api"
  _out There will be 2 pods.
  _out The pod web-api-1-build must reach status Completed first.
  _out Until then the pod web-api-xxxxxxxxx-yyyyy will be in status ImagePullBackOff or ErrImagePull.
  _out OpenAPI explorer: http://$(oc get route web-api -o jsonpath={.spec.host})/openapi/ui/
  _out Sample request: curl "http://$(oc get route web-api -o jsonpath={.spec.host})/web-api/v1/getmultiple"  

} 

openshift_url
login
setup    