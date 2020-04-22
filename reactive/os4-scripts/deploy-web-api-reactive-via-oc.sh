#!/bin/bash

root_folder=$(cd $(dirname $0); cd ..; pwd)

exec 3>&1

function _out() {
  echo "$(date +'%F %H:%M:%S') $@"
}

function setup() {
  _out Deploying web-api-reactive
  
  cd ${root_folder}/web-api-reactive
  oc delete -f deployment/os4-kubernetes.yaml --ignore-not-found
  oc delete route web-api-reactive --ignore-not-found
  oc delete is web-api-reactive --ignore-not-found

  cd ${root_folder}/web-api-reactive/src/main/resources
  sed -e "s/KAFKA_BOOTSTRAP_SERVERS/my-cluster-kafka-external-bootstrap.kafka:9094/g" \
      -e "s/CNS_ARTICLES_PORT/8080/g" \
      -e "s/CNS_AUTHORS_PORT/3000/g" \
      -e "s/CNS_LOCAL/false/g" \
      application.properties.template > application.properties

  cd ${root_folder}/web-api-reactive
  oc new-build --name web-api-reactive --binary --strategy docker
  oc start-build web-api-reactive --from-dir=.

  sed -e "s+web-api-reactive:latest+image-registry.openshift-image-registry.svc:5000/cloud-native-starter/web-api-reactive:latest+g" \
      -e "s+  type: NodePort+\#  type: NodePort+g" \
      -e "s+        imagePullPolicy: Never+#        imagePullPolicy: Never+g" \
      deployment/kubernetes.yaml > deployment/os4-kubernetes.yaml

  oc apply -f deployment/os4-kubernetes.yaml
  oc expose svc/web-api-reactive
  
  route=$(oc get route web-api-reactive --template='{{ .spec.host }}')  
  _out Done deploying web-api-reactive
  _out Wait until the pod has been started: "kubectl get pod --watch | grep web-api-reactive"
  _out Stream endpoint: http://$route/v2/server-sent-events
  _out API Explorer: http://$route/explorer
  _out Sample API - Read articles: curl -X GET \"http://$route/v2/articles\" -H \"accept: application/json\"
}

setup