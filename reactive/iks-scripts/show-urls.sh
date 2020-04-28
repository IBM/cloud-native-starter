#!/bin/bash

root_folder=$(cd $(dirname $0); cd ..; pwd)
cns_root_folder=$(cd $(dirname $0); cd ../..; pwd)
exec 3>&1

function _out() {
  echo "$(date +'%F %H:%M:%S') $@"
}

function local_env () {
  _out Get environment from local.env
  # Check if IKS deployment, set kubectl environment and IKS deployment options in local.env
  CFG_FILE=${cns_root_folder}/local.env
  # Check if config file exists
  if [ ! -f $CFG_FILE ]; then
      _out Config file local.env is missing! Check our instructions!
      exit 1
  fi  
  source $CFG_FILE
  _out End - Get environment from local.env
}

function setup_logging () {
  # SETUP logging (redirect stdout and stderr to a log file)
  LOG_FILE=${root_folder}/iks-scripts/show-urls.log  
  touch $LOG_FILE
}

function login () {
  _out Logging into IBM Cloud
  ibmcloud config --check-version=false >> $LOG_FILE 2>&1
  ibmcloud api --unset >> $LOG_FILE 2>&1
  ibmcloud api https://cloud.ibm.com >> $LOG_FILE 2>&1
  ibmcloud login --apikey $IBMCLOUD_API_KEY -r $IBM_CLOUD_REGION >> $LOG_FILE 2>&1
  _out End - Logging into IBM Cloud
}

function setup() {

  clusterip=$(ibmcloud ks workers --cluster $CLUSTER_NAME | awk '/Ready/ {print $2;exit;}')

  _out ------------------------------------------------------------------------------------
  _out Kafka Strimzi operator
  nodeport=$(kubectl get svc my-cluster-kafka-external-bootstrap -n kafka --ignore-not-found --output 'jsonpath={.spec.ports[*].nodePort}')
  targetport=$(kubectl get svc my-cluster-kafka-external-bootstrap -n kafka --ignore-not-found --output 'jsonpath={.spec.ports[*].targetPort}')
  
  if [ -z "$nodeport" ]; then
    _out Kafka is not available. Run the command: \"sh iks-scripts/deploy-kafka.sh\"
  else 
    _out Kafka bootstrap server - external URL: http://${clusterip}:${nodeport}
    _out Maybe you will get the ERR_CONNECTION_RESET error in your browser, but the sample will work.
    _out 1. \"kubectl config set-context --current --namespace=kafka\" 
  _out 2. \"kubectl get pods\" optional with \(--watch\)
  _out 3. \"kubectl get svc my-cluster-kafka-external-bootstrap\"
  _out 4. \"kubectl port-forward svc/my-cluster-kafka-external-bootstrap ${targetPort}:${targetPort}\"
  _out Note: You can\'t interact with the Kafka broker URL via the browser UI http://localhost:${targetPort}
  fi
  
  _out ------------------------------------------------------------------------------------
  _out Postgres
  _out Status
  kubectl get pods -n my-postgresql-operator-dev4devs-com
  _out Wait until the pod has been started:
  _out 1. \"kubectl config set-context --current --namespace=my-postgresql-operator-dev4devs-com\" 
  _out 2. \"kubectl get pods \" optional with \(--watch\)
  _out 3. \"kubectl get svc database-articles\"
  _out 4. \"kubectl port-forward svc/database-articles ${targetPort}:${targetPort}\"
  _out 5. Ensure you have psql client installed \(https://www.ibm.com/cloud/blog/new-builders/postgresql-tips-installing-the-postgresql-client\)
  _out 6. Open new terminal
  _out 7. Insert: \"psql -h 127.0.0.1 -U postgres\"
  _out 8. Now you connected to postgres
  _out Credentials - user: postgres, password: postgres

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

local_env
setup_logging
login
setup