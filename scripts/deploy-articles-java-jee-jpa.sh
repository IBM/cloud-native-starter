#!/bin/bash

root_folder=$(cd $(dirname $0); cd ..; pwd)

exec 3>&1

function _out() {
  echo "$(date +'%F %H:%M:%S') $@"
}

function setup() {
  _out Deploying articles-java-jee with JPA
  
  cd ${root_folder}/articles-java-jee
  kubectl delete -f deployment/kubernetes.yaml --ignore-not-found
  kubectl delete -f deployment/istio.yaml --ignore-not-found

  file="${root_folder}/articles-java-jee/liberty-opentracing-zipkintracer-1.2-sample.zip"
  if [ -f "$file" ]
  then
	  echo "$file found"
  else
	  curl -L -o $file https://github.com/WASdev/sample.opentracing.zipkintracer/releases/download/1.2/liberty-opentracing-zipkintracer-1.2-sample.zip
  fi

  cd ${root_folder}/articles-java-jee/deployment
  cp "kubernetes.yaml" "kubernetes.yaml.org"
  rm "kubernetes.yaml"
  sed "s/USE_IN_MEMORY_STORE/USE_SQL_STORE/g" kubernetes.yaml.org > kubernetes.yaml
  
  cd ${root_folder}
  source local.env
  cd ${root_folder}/articles-java-jee/liberty
  cp "server.xml" "server.xml.org"
  rm "server.xml"
  sed "s/DB2-SERVER/$DB2_SERVER_NAME/g" server.xml.org > server1.xml
  sed "s/DB2-USER/$DB2_USER/g" server1.xml > server2.xml
  sed "s/DB2-PASSWORD/$DB2_PASSWORD/g" server2.xml > server.xml
  rm "server1.xml"
  rm "server2.xml"

  cd ${root_folder}/articles-java-jee/
  eval $(minikube docker-env) 
  docker build -f Dockerfile.nojava -t articles:1 .

  cd ${root_folder}/articles-java-jee
  kubectl apply -f deployment/kubernetes.yaml
  kubectl apply -f deployment/istio.yaml

  cd ${root_folder}/articles-java-jee/deployment
  rm "kubernetes.yaml"
  cp "kubernetes.yaml.org" "kubernetes.yaml"
  rm "kubernetes.yaml.org"

  cd ${root_folder}/articles-java-jee/liberty
  rm "server.xml"
  cp "server.xml.org" "server.xml"
  rm "server.xml.org"

  minikubeip=$(minikube ip)
  nodeport=$(kubectl get svc articles --output 'jsonpath={.spec.ports[*].nodePort}')
  _out Minikube IP: ${minikubeip}
  _out NodePort: ${nodeport}
  
  _out Done deploying articles-java-jee with JPA
  _out Wait until the pod has been started: "kubectl get pod --watch | grep articles"
  _out Open the OpenAPI explorer: http://${minikubeip}:${nodeport}/openapi/ui/
}

setup