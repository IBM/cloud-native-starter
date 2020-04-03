#!/bin/bash

root_folder=$(cd $(dirname $0); cd ..; pwd)

exec 3>&1

function _out() {
  echo "$(date +'%F %H:%M:%S') $@"
}

function setup() {
  cd ${root_folder}/articles-reactive
  file="${root_folder}/articles-reactive/run-java.sh"
  if [ -f "$file" ]
  then
	  echo "$file found locally"
  else
	  curl -L -o $file https://raw.githubusercontent.com/fabric8io-images/java/0c7107ef65c95ca62b5f14416bef3fd34a528d47/images/alpine/openjdk11/jre/run-java.sh
  fi
}

setup