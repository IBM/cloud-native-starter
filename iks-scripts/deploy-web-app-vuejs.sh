#!/bin/bash 

root_folder=$(cd $(dirname $0); cd ..; pwd)

CFG_FILE=${root_folder}/local.env
# Check if config file exists
if [ ! -f $CFG_FILE ]; then
     _out Config file local.env is missing! Check our instructions!
     exit 1
fi  
source $CFG_FILE

# Login to IBM Cloud Image Registry
ibmcloud cr region-set $IBM_CLOUD_REGION
ibmcloud cr login

function _out() {
  echo "$(date +'%F %H:%M:%S') $@"
}

function configureVUEminikubeIP(){
  cd ${root_folder}/web-app-vuejs/src
  
  _out configure API endpoint in web-app
  clusterip=$(ibmcloud ks workers --cluster $CLUSTER_NAME | awk '/Ready/ {print $2;exit;}')
  ingressport=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.spec.ports[?(@.name=="http2")].nodePort}')

  rm "store.js"
  # cp "store.js.template" "store.js"
  sed -e "s/endpoint-api-ip/$clusterip/g" -e "s/ingress-np/${ingressport}/g" store.js.template > store.js
  
  cd ${root_folder}/web-app-vuejs
}

function setup() {
  _out Deploying web-app-vuejs
  
  cd ${root_folder}/web-app-vuejs
  kubectl delete -f deployment/kubernetes.yaml --ignore-not-found
  kubectl delete -f deployment/istio.yaml --ignore-not-found
  
  configureVUEminikubeIP

  # docker build for ICR
  docker build -f Dockerfile --tag $REGISTRY/$REGISTRY_NAMESPACE/web-app:1 .
  docker push $REGISTRY/$REGISTRY_NAMESPACE/web-app:1
  
  # Add ICR tags to K8s deployment.yaml  
  sed "s+web-app:1+$REGISTRY/$REGISTRY_NAMESPACE/web-app:1+g" deployment/kubernetes.yaml > deployment/IKS-kubernetes.yaml
  kubectl apply -f deployment/IKS-kubernetes.yaml
  kubectl apply -f deployment/istio.yaml

  cd ${root_folder}/web-app-vuejs/src
  cp "store.js.template" "store.js"

  clusterip=$(ibmcloud ks workers --cluster $CLUSTER_NAME | awk '/Ready/ {print $2;exit;}')
  nodeport=$(kubectl get svc web-app --output 'jsonpath={.spec.ports[*].nodePort}')
  _out Cluster IP: ${clusterip}
  _out NodePort: ${nodeport}
  
  _out Done deploying web-app-vuejs
  _out Wait until the pod has been startedCheck with these commands: 
  _out "kubectl get pod --watch | grep web-app"
 # _out Open the app: http://${clusterip}:${nodeport}/ 
}

#exection starts from here

#setupLog
setup