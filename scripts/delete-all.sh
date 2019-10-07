#!/bin/bash

root_folder=$(cd $(dirname $0); cd ..; pwd)

exec 3>&1

function _out() {
  echo "$(date +'%F %H:%M:%S') $@"
}

function setup() {

  cd ${root_folder}

  scripts/delete-articles-java-jee-quarkus.sh

  scripts/delete-articles-java-jee.sh

  scripts/delete-authors-nodejs.sh

  scripts/delete-authentication-nodejs.sh

  scripts/delete-web-api-java-jee.sh
  
  scripts/delete-web-app-vuejs.sh

  scripts/delete-istio-ingress.sh

  # Make sure original prometheus configuration is being restored, only req'd when Metrics demo has been run 
  if [ -f ${root_folder}/istio/prometheus-config-org.yaml ]; then
    kubectl replace --force -f ${root_folder}/istio/prometheus-config-org.yaml
    pod=$(kubectl get pods -n istio-system | grep prometheus | awk ' {print $1} ')
    kubectl delete pod $pod -n istio-system
  fi

}

setup
