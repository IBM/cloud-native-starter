#!/bin/bash

root_folder=$(cd $(dirname $0); pwd)

readonly LOG_FILE="${root_folder}/create-kafka.log"
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
    git --version &> /dev/null || MISSING_TOOLS="${MISSING_TOOLS} git"
    which sed &> /dev/null || MISSING_TOOLS="${MISSING_TOOLS} sed"
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
  # EventStream (Kafka) lite is only available in Dallas (us-south)
  ibmcloud login --apikey $IBMCLOUD_API_KEY -r us-south
  # Get default resource group name (can be 'default' or 'Default')
  RG=$(ibmcloud resource groups --default | grep -i ^default | awk '{print $1}')
  ibmcloud target -g $RG
}

function setup() {
  cd ${root_folder}

  _out Creating EventStream \(Kafka, MessageHub\) service instance
  ibmcloud resource service-instance-create messagehub-cloudnativestarter messagehub lite us-south

  _out Creating EventStream \(Kafka, MessageHub\) credentials
  ibmcloud resource service-key-create messagehub-cloudnativestarter-creds Manager --instance-name messagehub-cloudnativestarter
  
  # Get credentials of service key
  cred=$(ibmcloud resource service-key messagehub-cloudnativestarter-creds)

  # Extract list of brokers, is enclosed in '[' and ']', and replace ' ' with ','
  one=${cred#*[}
  two=${one%]*}
  brokers=$(sed 's/ /,/g' <<<$two)

  # Extract Kafka password, preceeded by 'password: ', succeeded by ' user:'
  one=${cred#*password: }
  password=${one% user:*} 
  
  printf "\n## IBM Cloud Event Streams / MessageHub / Kafka broker" >> $ENV_FILE
  printf "\nBROKERS=$brokers" >> $ENV_FILE
  printf "\nKAFKA_PASSWORD=$password" >> $ENV_FILE
  printf "\n## End IBM Cloud Event Streams / MessageHub / Kafka broker" >> $ENV_FILE
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
