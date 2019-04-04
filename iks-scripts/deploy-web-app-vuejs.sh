#!/bin/bash

root_folder=$(cd $(dirname $0); cd ..; pwd)

# Check if IKS deployment, set kubectl environment and IKS deployment options in local.env
if [[ -e "iks-scripts/cluster-config.sh" ]]; then source iks-scripts/cluster-config.sh; fi
if [[ -e "local.env" ]]; then source local.env; fi

# Login to IBM Cloud Image Registry
ibmcloud ks region-set $IBM_CLOUD_REGION
ibmcloud cr login

function _out() {
  echo "$(date +'%F %H:%M:%S') $@"
}

function configureVUEminikubeIP(){
  cd ${root_folder}/web-app-vuejs/src/components
  
  _out configureVUEIP
  clusterip=$(ibmcloud ks workers --cluster $CLUSTER_NAME | awk '/Ready/ {print $2;exit;}')

  _out _copy App.vue template definition
  rm "Home.vue"
  cp "Home-template.vue" "Home.vue"
  sed "s/MINIKUBE_IP/$clusterip/g" Home-template.vue > Home.vue
  
  cd ${root_folder}/web-app-vuejs
}

function setup() {
  _out Deploying web-app-vuejs
  
  cd ${root_folder}/web-app-vuejs
  kubectl delete -f deployment/kubernetes.yaml --ignore-not-found
  kubectl delete -f deployment/istio.yaml --ignore-not-found
  
  configureVUEminikubeIP

  # docker build replacement for ICR
  ibmcloud cr build -f Dockerfile --tag $REGISTRY/$REGISTRY_NAMESPACE/web-app:1 .

  # Add ICR tags to K8s deployment.yaml  
  sed "s+web-app:1+$REGISTRY/$REGISTRY_NAMESPACE/web-app:1+g" deployment/kubernetes.yaml > deployment/IKS-kubernetes.yaml
  kubectl apply -f deployment/IKS-kubernetes.yaml
  kubectl apply -f deployment/istio.yaml

  clusterip=$(ibmcloud ks workers --cluster $CLUSTER_NAME | awk '/Ready/ {print $2;exit;}')
  nodeport=$(kubectl get svc web-app --output 'jsonpath={.spec.ports[*].nodePort}')
  _out Cluster IP: ${clusterip}
  _out NodePort: ${nodeport}
  
  _out Done deploying web-app-vuejs
  _out Wait until the pod has been startedCheck with these commands: 
  _out "source iks-scripts/cluster-config.sh"  -- this is only needed once  
  _out "kubectl get pod --watch | grep web-app"
  _out Open the app: http://${clusterip}:${nodeport}/
}

#exection starts from here

#setupLog
setup