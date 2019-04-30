#!/bin/sh 

root_folder=$(cd $(dirname $0); cd ..; pwd)
readonly ENV_FILE="${root_folder}/local.env"

exec 3>&1

function _out() {
  echo "$(date +'%F %H:%M:%S') $@"
}

function setup() {
  _out Deploying web-api-java-jee v1

  cd ${root_folder}/istio
  kubectl delete -f protect-web-api.yaml --ignore-not-found
  
  cd ${root_folder}/web-api-java-jee
  kubectl delete -f deployment/kubernetes-service.yaml --ignore-not-found
  kubectl delete -f deployment/kubernetes-deployment-v1.yaml --ignore-not-found
  kubectl delete -f deployment/kubernetes-deployment-v2.yaml --ignore-not-found
  kubectl delete -f deployment/istio-service-v2.yaml --ignore-not-found

  file="${root_folder}/web-api-java-jee/liberty-opentracing-zipkintracer-1.2-sample.zip"
  if [ -f "$file" ]
  then
	  echo "$file found"
  else
	  curl -L -o $file https://github.com/WASdev/sample.opentracing.zipkintracer/releases/download/1.2/liberty-opentracing-zipkintracer-1.2-sample.zip
  fi

  sed 's/10/5/' src/main/java/com/ibm/webapi/business/Service.java > src/main/java/com/ibm/webapi/business/Service2.java
  rm src/main/java/com/ibm/webapi/business/Service.java
  mv src/main/java/com/ibm/webapi/business/Service2.java src/main/java/com/ibm/webapi/business/Service.java
  
  if [ -z "$APPID_ISSUER" ]
  then
    _out App ID has NOT been configured
  else
    _out App ID has been configured
    _out ${APPID_ISSUER}
    _out ${APPID_JWKS_URI}
    cd ${root_folder}/web-api-java-jee
    sed "s+https://us-south.appid.cloud.ibm.com/oauth/v4/xxx+$APPID_ISSUER+g" liberty/server.xml > liberty/server2.xml
    rm liberty/server.xml
    mv liberty/server2.xml liberty/server.xml
  fi
  
  eval $(minikube docker-env) 
  docker build -f Dockerfile.nojava -t web-api:1 .

  kubectl apply -f deployment/kubernetes-service.yaml
  kubectl apply -f deployment/kubernetes-deployment-v1.yaml
  kubectl apply -f deployment/istio-service-v1.yaml

  cd ${root_folder}/istio
  kubectl apply -f protect-web-api.yaml

  if [ -z "$APPID_ISSUER" ]
  then
    _out App ID has NOT been configured
  else
    cd ${root_folder}/web-api-java-jee
    sed "s+$APPID_ISSUER+https://us-south.appid.cloud.ibm.com/oauth/v4/xxx+g" liberty/server.xml > liberty/server2.xml
    rm liberty/server.xml
    mv liberty/server2.xml liberty/server.xml
  fi

  minikubeip=$(minikube ip)
  nodeport=$(kubectl get svc web-api --output 'jsonpath={.spec.ports[*].nodePort}')
  _out Minikube IP: ${minikubeip}
  _out NodePort: ${nodeport}
  
  _out Done deploying web-api-java-jee v1
  _out Wait until the pod has been started: "kubectl get pod --watch | grep web-api"
  _out Open the OpenAPI explorer: http://${minikubeip}:${nodeport}/openapi/ui/
}

function readEnv() {
  if [ -f "$ENV_FILE" ]
  then
	  source $ENV_FILE
  fi
}

readEnv 
setup