#!/bin/bash

export ISTIOINGRESSIP=$(kubectl get svc -n istio-system | grep istio-ingressgateway | awk '{print $3}')
export STATUS=""

function deleteNLBIPs(){
  array=("001" "002" "003")
  for i in "${array[@]}"
  do 
    echo ""
    echo "------------------------------------------------------------------------"
    echo "Check $i"
    while :
    do
        FIND=$i
        HOSTNAME=$(ibmcloud ks nlb-dns ls --cluster $MYCLUSTER | grep $FIND | awk '{print $1}')
        echo "hostname: $HOSTNAME"
        if [ "$STATUS" = "$HOSTNAME" ]; then
            echo "$(date +'%F %H:%M:%S') Status: $FIND is not avaiable"
            echo "------------------------------------------------------------------------"
            break
        else
            ibmcloud ks nlb-dns rm classic --cluster $MYCLUSTER --ip $ISTIOINGRESSIP --nlb-host $HOSTNAME
            echo "$(date +'%F %H:%M:%S') Status: $FIND($HOSTNAME) deleted"
            echo "------------------------------------------------------------------------"
            break
        fi
        sleep 5
    done
  done
}

ibmcloud ks nlb-dns ls --cluster $MYCLUSTER
deleteNLBIPs


