#!/bin/bash 

root_folder=$(cd $(dirname $0); cd ..; pwd)

exec 3>&1

function _out() {
  echo "$(date +'%F %H:%M:%S') $@"
}

function setup() {
  _out Deploying web-api-java-jee v1

  cd ${root_folder}/istio
  protectyaml="${root_folder}/web-api-java-jee/istio/protect-web-api.yaml"
  if [ -f "$protectyaml" ]
  then
    kubectl delete -f protect-web-api.yaml --ignore-not-found
  fi
  
  _out --- Cleanup
  cd ${root_folder}/web-api-java-jee
  oc delete -f deployment/kubernetes-service.yaml --ignore-not-found
  oc delete -f deployment/kubernetes-deployment-v1.yaml --ignore-not-found
  oc delete -f deployment/kubernetes-deployment-v2.yaml --ignore-not-found
  oc delete -f deployment/istio-service-v2.yaml --ignore-not-found
  oc delete istag web-api:1

  file="${root_folder}/web-api-java-jee/liberty-opentracing-zipkintracer-1.3-sample.zip"
  if [ -f "$file" ]
  then
	  echo "$file found"
  else
	  curl -L -o $file https://github.com/WASdev/sample.opentracing.zipkintracer/releases/download/1.3/liberty-opentracing-zipkintracer-1.3-sample.zip
  fi
  unzip -o liberty-opentracing-zipkintracer-1.3-sample.zip -d liberty-opentracing-zipkintracer/

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
  
  _out --- Build Docker Image
  docker build -f Dockerfile.nojava -t web-api:1 .
  docker tag web-api:1 $REGISTRYURL/$PROJECT/web-api:1
  docker push $REGISTRYURL/$PROJECT/web-api:1

   _out --- Deploy to OpenShift
  sed "s+web-api:1+$REGISTRY/$PROJECT/web-api:1+g" deployment/kubernetes-deployment-v1.yaml > deployment/os4-kubernetes-deployment-v1.yaml
  oc apply -f deployment/kubernetes-service.yaml
  oc apply -f deployment/os4-kubernetes-deployment-v1.yaml
  oc apply -f deployment/istio-service-v1.yaml
  oc expose svc/web-api

  if [ -f "$protectyaml" ]
  then
      cd ${root_folder}/istio
      kubectl apply -f protect-web-api.yaml
  fi


  if [ -z "$APPID_ISSUER" ]
  then
    _out App ID has NOT been configured
  else
    cd ${root_folder}/web-api-java-jee
    sed "s+$APPID_ISSUER+https://us-south.appid.cloud.ibm.com/oauth/v4/xxx+g" liberty/server.xml > liberty/server2.xml
    rm liberty/server.xml
    mv liberty/server2.xml liberty/server.xml
  fi

  
  _out Done deploying web-api-java-jee v1
  _out Wait until the pod has been started: "kubectl get pod --watch | grep web-api"
  _out Open the OpenAPI explorer: http://$(oc get route web-api --template='{{ .spec.host }}')/openapi/ui/
}


source ${root_folder}/os4-scripts/login.sh
setup
