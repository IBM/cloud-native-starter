#!/bin/bash

root_folder=$(cd $(dirname $0); cd ..; pwd)

# Check if IKS deployment, set kubectl environment and IKS deployment options in local.env
if [[ -e "iks-scripts/cluster-config.sh" ]]; then source iks-scripts/cluster-config.sh; fi
if [[ -e "local.env" ]]; then source local.env; fi

# Login to IBM Cloud Image Registry
ibmcloud ks region set $IBM_CLOUD_REGION
ibmcloud cr region-set $IBM_CLOUD_REGION
ibmcloud cr login

exec 3>&1

function _out() {
  echo "$(date +'%F %H:%M:%S') $@"
}

function setup() {
  _out Deploying articles-java-jee
  
  cd ${root_folder}/articles-java-jee
  kubectl delete -f deployment/kubernetes.yaml --ignore-not-found
  kubectl delete -f deployment/istio.yaml --ignore-not-found

  file="${root_folder}/articles-java-jee/liberty-opentracing-zipkintracer-1.3-sample.zip"
  if [ -f "$file" ]
  then
	  echo "$file found"
  else
	  curl -L -o $file https://github.com/WASdev/sample.opentracing.zipkintracer/releases/download/1.3/liberty-opentracing-zipkintracer-1.3-sample.zip
  fi
  unzip -o liberty-opentracing-zipkintracer-1.3-sample.zip -d liberty-opentracing-zipkintracer/
  
  # docker build replacement for ICR
  ibmcloud cr build -f Dockerfile.nojava --tag $REGISTRY/$REGISTRY_NAMESPACE/articles:1 .

  # Add ICR tags to K8s deployment.yaml  
  sed "s+articles:1+$REGISTRY/$REGISTRY_NAMESPACE/articles:1+g" deployment/kubernetes.yaml > deployment/IKS-kubernetes.yaml
  kubectl apply -f deployment/IKS-kubernetes.yaml
  kubectl apply -f deployment/istio.yaml

  
  clusterip=$(ibmcloud ks workers --cluster $CLUSTER_NAME | awk '/Ready/ {print $2;exit;}')
  nodeport=$(kubectl get svc articles --output 'jsonpath={.spec.ports[*].nodePort}')
  _out Cluster IP: ${clusterip}
  _out NodePort: ${nodeport}
  _out Done deploying articles-java-jee
  _out Wait until the pod has been started. Check with these commands: 
  _out "source iks-scripts/cluster-config.sh"  -- this is only needed once  
  _out "kubectl get pod --watch | grep articles"
  _out Open the OpenAPI explorer: http://${clusterip}:${nodeport}/openapi/ui/
}

setup
