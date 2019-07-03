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
  _out Deploying web-api-java-jee-v1
  
  cd ${root_folder}/web-api-java-jee
  oc delete all -l app=web-api --ignore-not-found
  oc delete all -l app=web-api --ignore-not-found
  oc delete -f deployment/istio-service-v2.yaml --ignore-not-found

  file="${root_folder}/web-api-java-jee/liberty-opentracing-zipkintracer-1.2-sample.zip"
  if [ -f "$file" ]
  then
	  echo "$file found"
  else
	  curl -L -o $file https://github.com/WASdev/sample.opentracing.zipkintracer/releases/download/1.2/liberty-opentracing-zipkintracer-1.2-sample.zip
  fi
  unzip -o liberty-opentracing-zipkintracer-1.2-sample.zip -d liberty-opentracing-zipkintracer/

  sed 's/10/5/' src/main/java/com/ibm/webapi/business/Service.java > src/main/java/com/ibm/webapi/business/Service2.java
  rm src/main/java/com/ibm/webapi/business/Service.java
  mv src/main/java/com/ibm/webapi/business/Service2.java src/main/java/com/ibm/webapi/business/Service.java

  mvn package

  docker build -f Dockerfile -t web-api:1 .
  docker tag web-api:1 $(minishift openshift registry)/cloud-native-starter/web-api:1
  docker push $(minishift openshift registry)/cloud-native-starter/web-api:1  

  cd ${root_folder}/web-api-java-jee/deployment
  sed "s+web-api:1+$(minishift openshift registry)/cloud-native-starter/web-api:1+g" kubernetes-deployment-v1.yaml > kubernetes-deployment-v1-minishift.yaml  

  oc apply -f kubernetes-service.yaml
  oc apply -f kubernetes-deployment-v1-minishift.yaml
  oc apply -f istio-service-v1.yaml
  oc expose svc/web-api

  _out Done deploying web-api-java-jee-v1
  _out Wait until the pod has been started: "oc get pod --watch | grep web-api"
  _out OpenAPI explorer: http://$(oc get route web-api -o jsonpath={.spec.host})/openapi/ui/
  _out Sample request: curl "http://$(oc get route web-api -o jsonpath={.spec.host})/web-api/v1/getmultiple"

}

login
setup
