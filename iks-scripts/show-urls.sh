#!/bin/bash

root_folder=$(cd $(dirname $0); cd ..; pwd)

# Check if IKS deployment, set kubectl environment and IKS deployment options in local.env
if [[ -e "iks-scripts/cluster-config.sh" ]]; then source iks-scripts/cluster-config.sh; fi
if [[ -e "local.env" ]]; then source local.env; fi

exec 3>&1

function _out() {
  echo "$(date +'%F %H:%M:%S') $@"
}

function setup() {
  _out Logging into IBM Cloud, please wait
  ibmcloud config --check-version=false
  ibmcloud login --apikey $IBMCLOUD_API_KEY -r $IBM_CLOUD_REGION
  ibmcloud ks region set $IBM_CLOUD_REGION
  clusterip=$(ibmcloud ks workers --cluster $CLUSTER_NAME | awk '/Ready/ {print $2;exit;}')
  ingressport=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.spec.ports[?(@.name=="http2")].nodePort}')
   
  _out ------------------------------------------------------------------------------------
  _out IMPORTANT IMPORTANT IMPORTANT IMPORTANT IMPORTANT IMPORTANT IMPORTANT IMPORTANT 
  _out Set the kube environment correctly for the IBM Kubernetes Service
  _out Executing this command is required every time you start a new shell
  _out Run the command: source iks-scripts/cluster-config.sh
  _out IMPORTANT IMPORTANT IMPORTANT IMPORTANT IMPORTANT IMPORTANT IMPORTANT IMPORTANT 
  _out ------------------------------------------------------------------------------------
  
  _out kiali
  _out Run the command: istioctl dashboard kiali
  #command1="kubectl -n istio-system port-forward $"
  #command2="(kubectl -n istio-system get pod -l app=kiali -o jsonpath='{.items[0].metadata.name}') 20001:20001"
  #_out Run the command: ${command1}${command2}
  #_out Then open http://localhost:20001 with username: admin, password: admin
  _out ------------------------------------------------------------------------------------

  #_out kiali - using Istio virtual service mapping
  #ingress=$(kubectl get gateway --ignore-not-found default-gateway-ingress-http --output 'jsonpath={.spec}')
  #if [ -z "$ingress" ]; then
  #  _out Ingress not available. Run 'scripts/deploy-istio-ingress-v1.sh'
  #else
  #  _out Web app: http://${clusterip}:31380/kiali
  #fi
  #_out ------------------------------------------------------------------------------------

  _out prometheus
  _out Run the command: istioctl dashboard prometheus
  #command1="kubectl -n istio-system port-forward $"
  #command2="(kubectl -n istio-system get pod -l app=prometheus -o jsonpath='{.items[0].metadata.name}') 9090:9090 &"
  #_out Run the command: ${command1}${command2}
  #_out Then open http://localhost:9090/
  _out ------------------------------------------------------------------------------------

  _out jaeger
  _out Run the command: istioctl dashboard jaeger
  #command1="kubectl -n istio-system port-forward $"
  #command2="(kubectl get pod -n istio-system -l app=jaeger -o jsonpath='{.items[0].metadata.name}') 16686:16686 &"
  #_out Run the command: ${command1}${command2}
  #_out Then open http://localhost:16686
  _out ------------------------------------------------------------------------------------

  _out grafana
  _out Run the command: istioctl dashboard grafana
  #command1="kubectl -n istio-system port-forward $"
  #command2="(kubectl -n istio-system get pod -l app=grafana -o jsonpath='{.items[0].metadata.name}') 3000:3000 &"
  #_out Run the command: ${command1}${command2}
  #_out Then open http://localhost:3000/dashboard/db/istio-mesh-dashboard
  _out ------------------------------------------------------------------------------------

  _out articles
  nodeport=$(kubectl get svc articles --ignore-not-found --output 'jsonpath={.spec.ports[*].nodePort}')
  if [ -z "$nodeport" ]; then
    _out articles is not available. Run 'scripts/deploy-articles-java-jee.sh'
  else 
    _out API explorer: http://${clusterip}:${nodeport}/openapi/ui/
    _out Sample API: curl "http://${clusterip}:${nodeport}/articles/v1/getmultiple?amount=10"
  fi
  _out ------------------------------------------------------------------------------------

  _out authors
  nodeport=$(kubectl get svc authors --ignore-not-found --output 'jsonpath={.spec.ports[*].nodePort}')
  if [ -z "$nodeport" ]; then
    _out authors is not available. Run 'scripts/deploy-authors-nodejs.sh'
  else 
    _out Sample API: curl "http://${clusterip}:${nodeport}/api/v1/getauthor?name=Niklas%20Heidloff"
  fi
  _out ------------------------------------------------------------------------------------
  
  _out web-api
  nodeport=$(kubectl get svc web-api --ignore-not-found --output 'jsonpath={.spec.ports[*].nodePort}')
  if [ -z "$nodeport" ]; then
    _out web-api is not available. Run 'scripts/deploy-web-api-java-jee.sh'
  else 
    _out API explorer: http://${clusterip}:${nodeport}/openapi/ui/
    _out Metrics: http://${clusterip}:${nodeport}/metrics/application
    _out Sample API: curl "http://${clusterip}:${ingressport}/web-api/v1/getmultiple"
  fi
  _out ------------------------------------------------------------------------------------
  
  _out web-app
  nodeport=$(kubectl get svc web-app --ignore-not-found --output 'jsonpath={.spec.ports[*].nodePort}')
  if [ -z "$nodeport" ]; then
    _out web-app is not available. Run 'scripts/deploy-web-app-vuejs.sh'
  else 
    ingress=$(kubectl get gateway --ignore-not-found default-gateway-ingress-http --output 'jsonpath={.spec}')
    if [ -z "$ingress" ]; then
      _out Ingress not available. Run 'scripts/deploy-istio-ingress-v1.sh'
    else
      _out Web app: http://${clusterip}:${ingressport}/
    fi
  fi
  _out ------------------------------------------------------------------------------------

}

setup