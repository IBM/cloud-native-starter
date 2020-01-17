#!/bin/bash

root_folder=$(cd $(dirname $0); cd ..; pwd)

# Check if IKS deployment, set kubectl environment and IKS deployment options in local.env
if [[ -e "iks-scripts/cluster-config.sh" ]]; then source iks-scripts/cluster-config.sh; fi
if [[ -e "local.env" ]]; then source local.env; fi

exec 3>&1

function _out() {
  echo "$(date +'%F %H:%M:%S') $@"
}

function setup() {
  _out Logging into IBM Cloud, please wait

  source ${root_folder}/iks-scripts/login.sh

  clusterip=$(ibmcloud ks workers --cluster $CLUSTER_NAME | awk '/Ready/ {print $2;exit;}')

  _out ------------------------------------------------------------------------------------
  _out Kafka Strimzi operator
  nodeport=$(kubectl get svc my-cluster-kafka-external-bootstrap -n kafka --ignore-not-found --output 'jsonpath={.spec.ports[*].nodePort}')
  targetport=$(kubectl get svc my-cluster-kafka-external-bootstrap -n kafka --ignore-not-found --output 'jsonpath={.spec.ports[*].targetPort}')
  
  if [ -z "$nodeport" ]; then
    _out Kafka is not available. Run the command: \"sh iks-scripts/deploy-kafka.sh\"
  else 
    _out Kafka bootstrap server - external URL: http://${clusterip}:${targetPort}
    _out Kafka bootstrap server - internal URL: my-cluster-kafka-external-bootstrap.kafka:9094
  fi
  _out ------------------------------------------------------------------------------------
  
   _out Service: articles-reactive
  nodeport=$(kubectl get svc articles-reactive --ignore-not-found --output 'jsonpath={.spec.ports[*].nodePort}')
  if [ -z "$nodeport" ]; then
    _out articles-reactive is not available. Run the command: \"sh iks-scripts/deploy-articles-reactive.sh\"
  else 
    _out API explorer: http://${clusterip}:${nodeport}/explorer
    _out Sample API - Read articles: curl -X GET \"http://${clusterip}:${nodeport}/v2/articles?amount=10\" -H \"accept: application/json\"
    _out Sample API - Create article: curl -X POST \"http://${clusterip}:${nodeport}/v2/articles\" -H \"accept: application/json\" -H \"Content-Type: application/json\" -d \"{\\\"author\\\":\\\"Niklas Heidloff\\\",\\\"title\\\":\\\"Title\\\",\\\"url\\\":\\\"http://heidloff.net\\\"}\"
  fi
  _out ------------------------------------------------------------------------------------

  _out Service: web-api-reactive
  nodeport=$(kubectl get svc web-api-reactive --ignore-not-found --output 'jsonpath={.spec.ports[*].nodePort}')
  if [ -z "$nodeport" ]; then
    _out web-api-reactive is not available. Run the command: \"sh iks-scripts/deploy-web-api-reactive.sh\"
  else 
    _out Stream endpoint: http://${clusterip}:${nodeport}/v2/server-sent-events
    _out API explorer: http://${clusterip}:${nodeport}/explorer
    _out Sample API - Read articles: curl -X GET \"http://${clusterip}:${nodeport}/v2/articles\" -H \"accept: application/json\"   
  fi
  _out ------------------------------------------------------------------------------------

  _out Service: authors
  nodeport=$(kubectl get svc authors --ignore-not-found --output 'jsonpath={.spec.ports[*].nodePort}')
  if [ -z "$nodeport" ]; then
    _out authors is not available. Run 'iks-scripts/deploy-authors.sh'
  else 
    _out Sample API: curl \"http://${clusterip}:${nodeport}/api/v1/getauthor?name=Niklas%20Heidloff\"
  fi
  _out ------------------------------------------------------------------------------------
  
  _out Web app: web-app-reactive
  nodeport=$(kubectl get svc web-app-reactive --ignore-not-found --output 'jsonpath={.spec.ports[*].nodePort}')

  if [ -z "$nodeport" ]; then
    _out web-app-reactive is not available. Run the command: \"sh iks-scripts/deploy-web-app-reactive.sh\"
  else 
    _out Home page: http://${clusterip}:${nodeport}
  fi
  _out ------------------------------------------------------------------------------------

}

setup