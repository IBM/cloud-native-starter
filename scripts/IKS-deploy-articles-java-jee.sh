#!/bin/bash

root_folder=$(cd $(dirname $0); cd ..; pwd)

# Check if IKS deployment, set kubectl environment and IKS deployment options in local.env
if [[ -e "iks-scripts/cluster-config.sh" ]]; then source iks-scripts/cluster-config.sh; IKS=true; fi
if [[ -e "local.env" ]]; then source local.env; fi

exec 3>&1

function _out() {
  echo "$(date +'%F %H:%M:%S') $@"
}

function setup() {
  _out Deploying articles-java-jee
  
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
  
  if [ ! $IKS ]; then
    eval $(minikube docker-env) 
    docker build -f Dockerfile.nojava -t articles:1 .
  else
    ibmcloud cr build -f Dockerfile.nojava --tag $REGISTRY/$REGISTRY_NAMESPACE/articles:1 .
  fi  

  kubectl apply -f deployment/IKS-kubernetes.yaml
  kubectl apply -f deployment/istio.yaml

  if [ ! $IKS ]; then
    minikubeip=$(minikube ip)
    nodeport=$(kubectl get svc articles --output 'jsonpath={.spec.ports[*].nodePort}')
    _out Minikube IP: ${minikubeip}
    _out NodePort: ${nodeport}
  fi
  _out Done deploying articles-java-jee
  _out Wait until the pod has been started: "kubectl get pod --watch | grep articles"
  _out Open the OpenAPI explorer: http://${minikubeip}:${nodeport}/openapi/ui/
}

setup