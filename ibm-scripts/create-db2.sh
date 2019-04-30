#!/bin/bash

root_folder=$(cd $(dirname $0); pwd)

readonly LOG_FILE="${root_folder}/create-db2.log"
readonly ENV_FILE="${root_folder}/../local.env"

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

  ibmcloud target --cf-api $IBM_CLOUD_CF_API -o $IBM_CLOUD_CF_ORG -s $IBM_CLOUD_CF_SPACE
}

function setup() {
  _out Creating db2 service instance
  
  ibmcloud service create 'dashDB For Transactions' Lite db2-cloud-native-starter 
  
  ibmcloud service key-create db2-cloud-native-starter 'dashDB For Transactions'
  DB2_SERVER_NAME=$(ibmcloud service key-show db2-cloud-native-starter 'dashDB For Transactions' | awk '/hostname/{ print $2 }')
  DB2_SERVER_NAME=${DB2_SERVER_NAME//\"/$''}
  DB2_SERVER_NAME=${DB2_SERVER_NAME//,/$''}
  printf "\nDB2_SERVER_NAME=$DB2_SERVER_NAME" >> $ENV_FILE
  DB2_PORT=$(ibmcloud service key-show db2-cloud-native-starter 'dashDB For Transactions' | awk '/port/{ print $2 }')
  DB2_PORT=${DB2_PORT//\"/$''}
  DB2_PORT=${DB2_PORT//,/$''}
  printf "\nDB2_PORT=$DB2_PORT" >> $ENV_FILE
  DB2_USER=$(ibmcloud service key-show db2-cloud-native-starter 'dashDB For Transactions' | awk '/username/{ print $2 }')
  DB2_USER=${DB2_USER//\"/$''}
  DB2_USER=${DB2_USER//,/$''}
  printf "\nDB2_USER=$DB2_USER" >> $ENV_FILE
  DB2_PASSWORD=$(ibmcloud service key-show db2-cloud-native-starter 'dashDB For Transactions' | awk '/password/{ print $2 }')
  DB2_PASSWORD=${DB2_PASSWORD//\"/$''}
  DB2_PASSWORD=${DB2_PASSWORD//,/$''}
  printf "\nDB2_PASSWORD=$DB2_PASSWORD" >> $ENV_FILE
}

check_tools

if [ ! -f $ENV_FILE ]; then
  _err "Before deploying, copy template.local.env into local.env and fill in environment specific values."
  exit 1
fi
source $ENV_FILE

_out Full install output in $LOG_FILE

ibmcloud_login

setup $@

_out db2 instance has been created
