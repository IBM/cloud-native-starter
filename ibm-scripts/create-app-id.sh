#!/bin/bash

root_folder=$(cd $(dirname $0); pwd)

readonly LOG_FILE="${root_folder}/create-app-id.log"
readonly ENV_FILE="${root_folder}/../local.env"
readonly ENV_NODEJS_FILE="${root_folder}/../authentication-nodejs/.env"
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
    curl --version &> /dev/null || MISSING_TOOLS="${MISSING_TOOLS} curl"
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
  # Get default resource group name (can be 'default' or 'Default')
  RG=$(ibmcloud resource groups --default | grep -i ^default | awk '{print $1}')
  ibmcloud target -g $RG
}

function setup() {
  _out Creating App ID service instance
  ibmcloud resource service-instance-create app-id-cloud-native-starter appid lite $IBM_CLOUD_REGION
  ibmcloud resource service-alias-delete app-id-cloud-native-starter -f
  ibmcloud resource service-alias-create app-id-cloud-native-starter --instance-name app-id-cloud-native-starter

  _out Creating App ID credentials
  ibmcloud resource service-key-create app-id-cloud-native-starter-credentials Reader --instance-name app-id-cloud-native-starter
  ibmcloud resource service-key app-id-cloud-native-starter-credentials

  rm $ENV_NODEJS_FILE
  touch $ENV_NODEJS_FILE

  APPID_ISSUER=$(ibmcloud resource service-key app-id-cloud-native-starter-credentials | awk '/oauthServerUrl/{ print $2 }')
  _out APPID_ISSUER: $APPID_ISSUER
  printf "\nAPPID_ISSUER=$APPID_ISSUER" >> $ENV_FILE
  printf "APPID_ISSUER=$APPID_ISSUER" >> $ENV_NODEJS_FILE

  APPID_OPENID_CONFIG=$APPID_ISSUER/.well-known/openid-configuration
  _out APPID_OPENID_CONFIG: $APPID_OPENID_CONFIG
  printf "\nAPPID_OPENID_CONFIG=$APPID_OPENID_CONFIG" >> $ENV_FILE
  printf "\nAPPID_OPENID_CONFIG=$APPID_OPENID_CONFIG" >> $ENV_NODEJS_FILE

  APPID_AUTHORIZATION_ENDPOINT=$APPID_ISSUER/authorization
  _out APPID_AUTHORIZATION_ENDPOINT: $APPID_AUTHORIZATION_ENDPOINT
  printf "\nAPPID_AUTHORIZATION_ENDPOINT=$APPID_AUTHORIZATION_ENDPOINT" >> $ENV_FILE
  printf "\nAPPID_AUTHORIZATION_ENDPOINT=$APPID_AUTHORIZATION_ENDPOINT" >> $ENV_NODEJS_FILE

  APPID_TOKEN_ENDPOINT=$APPID_ISSUER/token
  _out APPID_TOKEN_ENDPOINT: $APPID_TOKEN_ENDPOINT
  printf "\nAPPID_TOKEN_ENDPOINT=$APPID_TOKEN_ENDPOINT" >> $ENV_FILE
  printf "\nAPPID_TOKEN_ENDPOINT=$APPID_TOKEN_ENDPOINT" >> $ENV_NODEJS_FILE

  APPID_USERINFO_ENDPOINT=$APPID_ISSUER/userinfo
  _out APPID_USERINFO_ENDPOINT: $APPID_USERINFO_ENDPOINT
  printf "\nAPPID_USERINFO_ENDPOINT=$APPID_USERINFO_ENDPOINT" >> $ENV_FILE
  printf "\nAPPID_USERINFO_ENDPOINT=$APPID_USERINFO_ENDPOINT" >> $ENV_NODEJS_FILE

  APPID_JWKS_URI=$APPID_ISSUER/publickeys
  _out APPID_JWKS_URI: $APPID_JWKS_URI
  printf "\nAPPID_JWKS_URI=$APPID_JWKS_URI" >> $ENV_FILE
  printf "\nAPPID_JWKS_URI=$APPID_JWKS_URI" >> $ENV_NODEJS_FILE

  APPID_CLIENTID=$(ibmcloud resource service-key app-id-cloud-native-starter-credentials | awk '/clientId/{ print $2 }')
  _out APPID_CLIENTID: $APPID_CLIENTID
  printf "\nAPPID_CLIENTID=$APPID_CLIENTID" >> $ENV_FILE
  printf "\nAPPID_CLIENTID=$APPID_CLIENTID" >> $ENV_NODEJS_FILE

  APPID_SECRET=$(ibmcloud resource service-key app-id-cloud-native-starter-credentials | awk '/secret/{ print $2 }')
  _out APPID_SECRET: $APPID_SECRET
  printf "\nAPPID_SECRET=$APPID_SECRET" >> $ENV_FILE
  printf "\nAPPID_SECRET=$APPID_SECRET" >> $ENV_NODEJS_FILE

  APPID_MGMTURL=$(ibmcloud resource service-key app-id-cloud-native-starter-credentials | awk '/managementUrl/{ print $2 }')
  _out APPID_MGMTURL: $APPID_MGMTURL
  printf "\nAPPID_MGMTURL=$APPID_MGMTURL" >> $ENV_FILE
  printf "\nAPPID_MGMTURL=$APPID_MGMTURL" >> $ENV_NODEJS_FILE

  minikubeip=$(minikube ip)
  ingressport=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.spec.ports[?(@.name=="http2")].nodePort}')
  REDIRECT_URL_CALLBACK=http://$minikubeip:$ingressport/callback
  printf "\nREDIRECT_URL_CALLBACK=$REDIRECT_URL_CALLBACK" >> $ENV_NODEJS_FILE
  REDIRECT_URL_WEB_APP=http://$minikubeip:$ingressport/loginwithtoken
  printf "\nREDIRECT_URL_WEB_APP=$REDIRECT_URL_WEB_APP" >> $ENV_NODEJS_FILE
  
  DEMO_EMAIL=user@demo.email
  DEMO_PASSWORD=verysecret
  _out Creating cloud directory test user: $DEMO_EMAIL, $DEMO_PASSWORD
  IBMCLOUD_BEARER_TOKEN=$(ibmcloud iam oauth-tokens | awk '/IAM/{ print $3" "$4 }')
  curl -s -X POST \
    --header 'Content-Type: application/json' \
    --header 'Accept: application/json' \
    --header "Authorization: $IBMCLOUD_BEARER_TOKEN" \
    -d '{"emails": [
            {"value": "'$DEMO_EMAIL'","primary": true}
          ],
         "userName": "'$DEMO_EMAIL'",
         "password": "'$DEMO_PASSWORD'"
        }' \
    "${APPID_MGMTURL}/cloud_directory/Users"

  DEMO_EMAIL=admin@demo.email
  DEMO_PASSWORD=verysecret
  _out Creating cloud directory test admin: $DEMO_EMAIL, $DEMO_PASSWORD
  IBMCLOUD_BEARER_TOKEN=$(ibmcloud iam oauth-tokens | awk '/IAM/{ print $3" "$4 }')
  curl -s -X POST \
    --header 'Content-Type: application/json' \
    --header 'Accept: application/json' \
    --header "Authorization: $IBMCLOUD_BEARER_TOKEN" \
    -d '{"emails": [
            {"value": "'$DEMO_EMAIL'","primary": true}
          ],
         "userName": "'$DEMO_EMAIL'",
         "password": "'$DEMO_PASSWORD'"
        }' \
    "${APPID_MGMTURL}/cloud_directory/Users"

  _out Creating redirect URL in App ID
  IBMCLOUD_BEARER_TOKEN=$(ibmcloud iam oauth-tokens | awk '/IAM/{ print $3" "$4 }')
  curl -s -X PUT \
    --header 'Content-Type: application/json' \
    --header 'Accept: application/json' \
    --header "Authorization: $IBMCLOUD_BEARER_TOKEN" \
    -d '{"redirectUris": [
            "'$REDIRECT_URL_CALLBACK'", "http://localhost:3000/callback"]
        }' \
    "${APPID_MGMTURL}/config/redirect_uris"

  _out Writing issuer into policy
  cd ${root_folder}/../istio
  rm "protect-web-api.yaml"
  cp "protect-web-api.yaml.template" "protect-web-api.yaml"
  sed "s+APPID_ISSUER+$APPID_ISSUER+g" protect-web-api.yaml.template > protect-web-api.yaml.1
  sed "s+APPID_JWKS_URI+$APPID_JWKS_URI+g" protect-web-api.yaml.1 > protect-web-api.yaml
  rm protect-web-api.yaml.1
}


# Main script starts here
check_tools

# Load configuration variables
if [ ! -f $ENV_FILE ]; then
  _err "Before deploying, copy template.local.env into local.env and fill in environment specific values."
  exit 1
fi
source $ENV_FILE
export TF_VAR_ibm_bx_api_key=$IBMCLOUD_API_KEY
export TF_VAR_ibm_cf_org=$IBMCLOUD_ORG
export TF_VAR_ibm_cf_space=$IBMCLOUD_SPACE
export IBMCLOUD_API_KEY IBM_CLOUD_REGION
export TF_VAR_appid_plan=${IBMCLOUD_APPID_PLAN:-"lite"}
export TF_VAR_cloudant_plan=${IBMCLOUD_CLOUDANT_PLAN:-"Lite"}

_out Full install output in $LOG_FILE
ibmcloud_login
setup $@
#esac