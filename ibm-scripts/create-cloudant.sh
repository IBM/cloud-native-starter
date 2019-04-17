#!/bin/bash

root_folder=$(cd $(dirname $0); pwd)

readonly LOG_FILE="${root_folder}/create-cloudant.log"
readonly ENV_FILE="${root_folder}/../local.env"
readonly AUTHOR_CFG="${root_folder}/../scripts/deploy-authors-nodejs.cfg"
touch $LOG_FILE
exec 3>&1 
exec 4>&2 
exec 1>$LOG_FILE 2>&1

function _out() {
  echo "$@" >&3
  echo "$(date +'%F %H:%M:%S') $@"
}

function _err() {
  echo "$@" >&4
  echo "$(date +'%F %H:%M:%S') $@"
}

function check_tools() {
    MISSING_TOOLS=""
    ibmcloud --version &> /dev/null || MISSING_TOOLS="${MISSING_TOOLS} ibmcloud"    
    if [[ -n "$MISSING_TOOLS" ]]; then
      _err "Some tools (${MISSING_TOOLS# }) could not be found, please install them first and then run scripts/setup-app-id.sh"
      exit 1
    fi
}

function ibmcloud_login() {
  ibmcloud config --check-version=false
  ibmcloud api --unset
  ibmcloud api https://cloud.ibm.com
  ibmcloud login --apikey $IBMCLOUD_API_KEY -r $IBM_CLOUD_REGION
}

function setup() {
  _out Creating Cloudant service instance
  ibmcloud resource service-instance-create cloudant-cloud-native-starter cloudantnosqldb lite $IBM_CLOUD_REGION  -p '{"location": "$IBM_CLOUD_REGION", "hipaa": "false", "legacyCredentials": true}'
  ibmcloud resource service-key-create cred4cloudant-cloud-native-starter Manager --instance-name cloudant-cloud-native-starter
  cloudanturl=$(ibmcloud resource service-key cred4cloudant-cloud-native-starter | awk '/url: /{ print $2 }')
  echo DB="cloud" > $AUTHOR_CFG
  echo CLOUDANTURL="$cloudanturl" >> $AUTHOR_CFG

  _out Creating Cloudant database 
  curl "$cloudanturl/authors" -X PUT

  _out Creating Cloudant database view
  JSON=$(<$root_folder/../authors-nodejs/authorview.json)
  curl "$cloudanturl/authors" \
    -X POST \
    -H "Content-Type: application/json" \
    -d "$JSON"

  _out Loading sample database
  JSON=$(<$root_folder/../authors-nodejs/authordata.json)
  curl "$cloudanturl/authors/_bulk_docs" \
    -X POST \
    -H "Content-Type: application/json" \
    -d "$JSON"

}


# Main script starts here
check_tools

# Load configuration variables
if [ ! -f $ENV_FILE ]; then
  _err "Before deploying, copy template.local.env into local.env and fill in environment specific values."
  exit 1
fi
source $ENV_FILE

_out Full install output in $LOG_FILE

ibmcloud_login

setup $@

_out Cloudant instance created, credentials are in directory scripts, file deploy-authors-nodejs.cfg
_out Continue with deploy-authors-nodejs.sh in directory scripts for Minikube or iks-scripts for IBM Cloud