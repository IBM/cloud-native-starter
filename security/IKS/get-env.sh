#!/bin/bash

# Get clustername 

MYCLUSTER=$(ibmcloud ks cluster ls -s | awk '/classic/ { print $1 }')
echo "Cluster name: $MYCLUSTER"
echo "MYCLUSTER=$MYCLUSTER" > local.env

# Get Cluster External IP
CLUSTERIP=$(ibmcloud ks worker ls --cluster $MYCLUSTER -s | awk '/encrypted/ { print $2 }')
echo "Cluster IP: $CLUSTERIP"
echo "CLUSTERIP=$CLUSTERIP" >> local.env

# Get kubeconfig
ibmcloud ks cluster config --cluster $MYCLUSTER -s 
# ibmcloud ks cluster config --cluster $MYCLUSTER --export -s >> local.env

echo "INGRESSURL=" >> local.env
echo "alias kc=kubectl" >> local.env 

echo "-------------------------------------------------"
echo "Execute 'source local.env' to set the environment"
echo ""
