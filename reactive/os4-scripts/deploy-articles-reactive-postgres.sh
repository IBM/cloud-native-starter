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
  oc delete route articles-reactive
  oc delete is articles-reactive
  
  cd ${root_folder}/articles-reactive/src/main/resources
  sed -e "s/KAFKA_BOOTSTRAP_SERVERS/my-cluster-kafka-external-bootstrap.kafka:9094/g" \
      -e "s/IN_MEMORY_STORE/no/g" \
      -e "s/POSTGRES_URL/database-articles.postgres:5432/g" \
       application.properties.template > application.properties

  cd ${root_folder}/articles-reactive
  docker build -f ${root_folder}/articles-reactive/Dockerfile -t articles-reactive:latest .
  docker tag articles-reactive:latest $REGISTRYURL/$PROJECT/articles-reactive:latest
  docker push $REGISTRYURL/$PROJECT/articles-reactive:latest

  sed -e "s+articles-reactive:latest+$REGISTRY/$PROJECT/articles-reactive:latest+g" \
      -e "s+  type: NodePort+#  type: NodePort+g" \
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

source ${root_folder}/os4-scripts/login.sh
setup