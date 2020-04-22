#!/bin/bash

root_folder=$(cd $(dirname $0); cd ..; pwd)

exec 3>&1

function _out() {
  echo "$(date +'%F %H:%M:%S') $@"
}

function setup() {
  _out Deploying articles-reactive
  
  _out Cleanup
  cd ${root_folder}/articles-reactive
  oc delete -f deployment/os4-kubernetes.yaml --ignore-not-found
  oc delete route articles-reactive --ignore-not-found
  oc delete is articles-reactive --ignore-not-found
  
  cd ${root_folder}/articles-reactive/src/main/resources
  sed -e "s/KAFKA_BOOTSTRAP_SERVERS/my-cluster-kafka-external-bootstrap.kafka:9094/g" \
      -e "s/IN_MEMORY_STORE/false/g" \
      -e "s/POSTGRES_URL/database-articles.postgres:5432/g" \
       application.properties.template > application.properties

  cd ${root_folder}/articles-reactive

  oc new-build --name articles-reactive --binary --strategy docker
  oc start-build articles-reactive --from-dir=.
  
  sed -e "s+articles-reactive:latest+image-registry.openshift-image-registry.svc:5000/cloud-native-starter/articles-reactive:latest+g" \
      -e "s+        imagePullPolicy: Never+#        imagePullPolicy: Never+g" \
      deployment/kubernetes.yaml > deployment/os4-kubernetes.yaml

  oc apply -f deployment/os4-kubernetes.yaml
  oc expose svc/articles-reactive
   
  _out Done deploying articles-reactive
  ROUTE=$(oc get route articles-reactive --template='{{ .spec.host }}')
  _out Wait until the pod has been started: \"kubectl get pod --watch | grep articles-reactive\"
  _out Wait a minute more then test:
  _out API Explorer: http://$ROUTE/explorer
  _out Sample API - Read articles: curl -X GET \"http://$ROUTE/v2/articles?amount=10\" -H \"accept: application/json\"
}

setup