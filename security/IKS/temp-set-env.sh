#!/bin/bash
# --------------------------------------------------
# When you know your cluster you can use that script
# --------------------------------------------------

CLUSTER_ID=YOUR_CLUSTER_ID
MYCLUSTER_NAME=YOUR_CLUSTER_NAME

# Logon
ibmcloud login -a cloud.ibm.com -r us-south -g default -sso
# ibmcloud login -a cloud.ibm.com -r us-south -g default
ibmcloud ks cluster config --cluster $CLUSTER_ID

# Clone GitHub project
git clone https://github.com/IBM/cloud-native-starter.git
cd cloud-native-starter/security
ROOT_FOLDER=$(pwd)

# Export needed environment variables
cd $ROOT_FOLDER/IKS
export MYCLUSTER=$MYCLUSTER_NAME

# Create DNS subdomain
# INGRESS_IP_ADDRESS=$(kubectl get svc -n istio-system | grep istio-ingressgateway | awk '/^istio-ingressgateway/ {print $4}')
# ibmcloud ks nlb-dns create classic --cluster $MYCLUSTER --ip $INGRESS_IP_ADDRESS

ingress_url=$(ibmcloud ks nlb-dns ls --cluster $MYCLUSTER | grep 0001 | awk '{print $1}')
export INGRESSURL=$ingress_url
ingress_secret=$(ibmcloud ks nlb-dns ls --cluster $MYCLUSTER | grep 0001 | awk '{print $5}')
export INGRESSSECRET=$ingress_secret
export QUARKUS_OIDC_AUTH_SERVER_URL="https://$INGRESSURL/auth/realms/quarkus"