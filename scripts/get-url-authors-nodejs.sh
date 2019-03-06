#!/bin/bash

root_folder=$(cd $(dirname $0); cd ..; pwd)

exec 3>&1

function _out() {
  echo "$(date +'%F %H:%M:%S') $@"
}

function setup() {
  
  ip=$(minikube ip)
  port=$(kubectl get svc authors-service -o jsonpath='{.spec.ports[0].nodePort}')

  url='http://'$ip:$port'/api/v1/getauthor?name='
  echo $url
    
}

_out Authors API URL is: 
setup