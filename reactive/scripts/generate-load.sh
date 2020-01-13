#!/bin/bash

root_folder=$(cd $(dirname $0); cd ..; pwd)

exec 3>&1

function _out() {
  echo "$(date +'%F %H:%M:%S') $@"
}

function setup() {
  _out Generation load

  for i in {1..5000}
  do
    echo "Times /v2/articles invoked: $i"
    curl -X GET "http://192.168.64.37:32645/v1/articles" -H "accept: application/json"
  done
  
  
  
}

setup

