#!/bin/bash

root_folder=$(cd $(dirname $0); cd ..; pwd)

exec 3>&1

function _out() {
  echo "$(date +'%F %H:%M:%S') $@"
}

function setup() {

  crcip=$(crc ip)
  _out ------------------------------------------------------------------------------------
  
  _out Kafka Strimzi operator
  nodeport=$(oc get svc my-cluster-kafka-external-bootstrap -n kafka --ignore-not-found --output 'jsonpath={.spec.ports[*].nodePort}')
  if [ -z "$nodeport" ]; then
    _out Kafka is not available. Run the command: \"sh scripts/deploy-kafka.sh\"
  else 
    _out Kafka bootstrap server - external URL: ${crcip}:${nodeport}
    _out Kafka bootstrap server - internal URL: my-cluster-kafka-external-bootstrap.kafka:9094
  fi
  _out ------------------------------------------------------------------------------------

  _out Service: articles-reactive
  route=$(oc get route articles-reactive --template='{{ .spec.host }}')
  if [ -z "$route" ]; then
    _out articles-reactive is not available. Run the command: \"sh scripts/deploy-articles-reactive.sh\"
  else 
    _out API explorer: http://${route}/explorer
    _out Sample API - Read articles: curl -X GET \"http://${route}/v2/articles?amount=10\" -H \"accept: application/json\"
    _out Sample API - Create article: curl -X POST \"http://${route}/v2/articles\" -H \"accept: application/json\" -H \"Content-Type: application/json\" -d \"{\\\"author\\\":\\\"Niklas Heidloff\\\",\\\"title\\\":\\\"Title\\\",\\\"url\\\":\\\"http://heidloff.net\\\"}\"
  fi
  _out ------------------------------------------------------------------------------------

  _out Service: web-api-reactive
  route=$(oc get route web-api-reactive --template='{{ .spec.host }}')
  if [ -z "$route" ]; then
    _out web-api-reactive is not available. Run the command: \"sh scripts/deploy-web-api-reactive.sh\"
  else 
    _out Stream endpoint: http://${route}/v2/server-sent-events
    _out API explorer: http://${route}/explorer
    _out Sample API - Read articles: curl -X GET \"http://${route}/v2/articles\" -H \"accept: application/json\"   
  fi
  _out ------------------------------------------------------------------------------------

  _out Service: authors
  route=$(oc get route author --template='{{ .spec.host }}')
  if [ -z "$route" ]; then
    _out authors is not available. Run the command: \"sh scripts/deploy-authors.sh\"
  else 
    _out Sample API call: curl http://${route}}/api/v1/getauthor?name=Niklas%20Heidloff
  fi
  _out ------------------------------------------------------------------------------------

  _out Web app: web-app-reactive
  route=$(oc get route web-app-reactive --template='{{ .spec.host }}')
  if [ -z "$route" ]; then
    _out web-app-reactive is not available. Run the command: \"sh scripts/deploy-web-app-reactive.sh\"
  else 
    _out Home page: http://${route}
  fi
  _out ------------------------------------------------------------------------------------
}

setup
