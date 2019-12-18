#!/bin/bash

root_folder=$(cd $(dirname $0); cd ..; pwd)

exec 3>&1

function _out() {
  echo "$(date +'%F %H:%M:%S') $@"
}

function setup() {
  _out --- Deploying articles-java-jee
  
  cd ${root_folder}/articles-java-jee

  _out --- Clean-up   
  oc delete all -l app=articles
  oc delete is articles
  #oc delete -f deployment/istio.yaml --ignore-not-found
  #oc delete route articles --igore-not-found

  file="${root_folder}/articles-java-jee/liberty-opentracing-zipkintracer-1.3-sample.zip"
  if [ -f "$file" ]
  then
	  echo "$file found"
  else
	  curl -L -o $file https://github.com/WASdev/sample.opentracing.zipkintracer/releases/download/1.3/liberty-opentracing-zipkintracer-1.3-sample.zip
  fi
  unzip -o liberty-opentracing-zipkintracer-1.3-sample.zip -d liberty-opentracing-zipkintracer/
 
  # Build Docker image and push to repo
  _out --- Build and push Docker image
  docker build -f Dockerfile.nojava -t articles:1 .
  docker tag articles:1 $REGISTRYURL/$PROJECT/articles:1
  docker push $REGISTRYURL/$PROJECT/articles:1

  # Add OS repo tags to K8s deployment.yaml  
  _out --- Deploy to OpenShift
  sed "s+articles:1+$REGISTRY/$PROJECT/articles:1+g" deployment/kubernetes.yaml > deployment/os4-kubernetes.yaml
  oc apply -f deployment/os4-kubernetes.yaml
  oc apply -f deployment/istio.yaml
  oc expose svc/articles

  _out Done deploying articles-java-jee
  _out Wait until the pod has been started: "oc get pod --watch | grep articles"
  _out Open the OpenAPI explorer: http://$(oc get route articles --template='{{ .spec.host }}')/openapi/ui/
}

source ${root_folder}/os4-scripts/login.sh
setup
