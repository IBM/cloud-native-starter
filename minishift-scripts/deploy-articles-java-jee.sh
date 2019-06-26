#!/bin/bash

root_folder=$(cd $(dirname $0); cd ..; pwd)

exec 3>&1

function login() {
  eval $(minishift docker-env)
  oc login -u developer -p developer
  docker login -u developer -p $(oc whoami -t) $(minishift openshift registry)
  oc project cloud-native-starter
}

function _out() {
  echo "$(date +'%F %H:%M:%S') $@"
}

function setup() {
  _out Deploying articles-java-jee
  
  cd ${root_folder}/articles-java-jee
  oc delete route articles
  kubectl delete -f deployment/kubernetes-minishift.yaml --ignore-not-found
  kubectl delete -f deployment/istio.yaml --ignore-not-found

  file="${root_folder}/articles-java-jee/liberty-opentracing-zipkintracer-1.2-sample.zip"
  if [ -f "$file" ]
  then
	  echo "$file found"
  else
	  curl -L -o $file https://github.com/WASdev/sample.opentracing.zipkintracer/releases/download/1.2/liberty-opentracing-zipkintracer-1.2-sample.zip
  fi
  unzip -o liberty-opentracing-zipkintracer-1.2-sample.zip -d liberty-opentracing-zipkintracer/
  
  mvn package

  docker build -f Dockerfile -t articles:1 .
  docker tag articles:1 $(minishift openshift registry)/cloud-native-starter/articles:1
  docker push $(minishift openshift registry)/cloud-native-starter/articles:1

  cd ${root_folder}/articles-java-jee/deployment
  sed "s+articles:1+$(minishift openshift registry)/cloud-native-starter/articles:1+g" kubernetes.yaml > kubernetes-minishift.yaml
  # to be done: add the annotation for sidecar inject

  kubectl apply -f kubernetes-minishift.yaml
  kubectl apply -f istio.yaml
  oc expose svc/articles

  _out Done deploying articles-java-jee
  _out OpenAPI explorer: http://articles-cloud-native-starter.$(minishift ip).nip.io/openapi/ui/
  _out Sample request: curl -X GET "http://articles-cloud-native-starter.$(minishift ip).nip.io/articles/v1/getmultiple?amount=10" -H "accept: application/json"
}

login
setup
