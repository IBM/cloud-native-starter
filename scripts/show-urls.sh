#!/bin/bash

root_folder=$(cd $(dirname $0); cd ..; pwd)

exec 3>&1

function _out() {
  echo "$(date +'%F %H:%M:%S') $@"
}

function setup() {

  minikubeip=$(minikube ip)

  _out ------------------------------------------------------------------------------------
  nodeport=$(kubectl get svc -n istio-system kiali --output 'jsonpath={.spec.ports[*].nodePort}')
  _out kiali
  _out Web app:      https://${minikubeip}:${nodeport}/kiali
  nodeport=$(kubectl get svc articles --output 'jsonpath={.spec.ports[*].nodePort}')
  _out ------------------------------------------------------------------------------------

  _out prometheus
  command1="kubectl -n istio-system port-forward $"
  command2="(kubectl -n istio-system get pod -l app=prometheus -o jsonpath='{.items[0].metadata.name}') 9090:9090 &"
  _out Run the command: ${command1}${command2}
  _out Then open http://localhost:9090/
  _out ------------------------------------------------------------------------------------

  _out jaeger
  command1="kubectl -n istio-system port-forward $"
  command2="(kubectl get pod -n istio-system -l app=jaeger -o jsonpath='{.items[0].metadata.name}') 16686:16686 &"
  _out Run the command: ${command1}${command2}
  _out Then open http://localhost:16686
  _out ------------------------------------------------------------------------------------

  _out grafana
  command1="kubectl -n istio-system port-forward $"
  command2="(kubectl -n istio-system get pod -l app=grafana -o jsonpath='{.items[0].metadata.name}') 3000:3000 &"
  _out Run the command: ${command1}${command2}
  _out Then open http://localhost:3000/dashboard/db/istio-mesh-dashboard
  _out ------------------------------------------------------------------------------------

  _out articles
  _out API explorer: http://${minikubeip}:${nodeport}/openapi/ui/
  _out Sample API: curl http://${minikubeip}:${nodeport}/articles/v1/getmultiple?amount=10
  _out ------------------------------------------------------------------------------------
  nodeport=$(kubectl get svc authors --output 'jsonpath={.spec.ports[*].nodePort}')
  
  _out authors
  _out Sample API: curl http://${minikubeip}:${nodeport}/api/v1/getauthor?name=Niklas%20Heidloff
  _out ------------------------------------------------------------------------------------
  nodeport=$(kubectl get svc web-api --output 'jsonpath={.spec.ports[*].nodePort}')
  
  _out web-api
  _out API explorer: http://${minikubeip}:31380/openapi/ui/
  _out Metrics: http://${minikubeip}:${nodeport}/metrics/application
  _out Sample API: curl http://${minikubeip}:31380/web-api/v1/getmultiple
  _out ------------------------------------------------------------------------------------
  
  _out web-app
  _out Web app: http://${minikubeip}:31380/
  _out ------------------------------------------------------------------------------------

}

setup