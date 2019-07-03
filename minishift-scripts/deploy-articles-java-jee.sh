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
  oc delete all -l app=articles --ignore-not-found
  oc delete all -l app=articles --ignore-not-found
  oc delete configmap -l app=articles --ignore-not-found
  oc delete -f deployment/istio.yaml --ignore-not-found

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

  oc apply -f kubernetes-minishift.yaml
  oc apply -f istio.yaml
  oc expose svc/articles

  _out Done deploying articles-java-jee
  _out Wait until the pod has been started: "oc get pod --watch | grep articles"
  _out OpenAPI explorer: http://$(oc get route articles -o jsonpath={.spec.host})/openapi/ui/
  _out Sample request: curl -X GET "http://$(oc get route articles -o jsonpath={.spec.host})/articles/v1/getmultiple?amount=10" -H "accept: application/json"
}

login
setup
