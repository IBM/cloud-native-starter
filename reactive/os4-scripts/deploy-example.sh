#!/bin/bash
STATUS="Running"
root_folder=$(cd $(dirname $0); cd ..; pwd)

function checkKafka {
  oc project kafka
  echo ""
  echo "-------------------------------"
  echo "Check: strimzi-cluster-operator"
  echo ""
  while :
  do
    STATUS_CHECK=$(oc get pods | grep '^strimzi-cluster-operator' | awk '/^strimzi-cluster-operator/ {print $3}')
    if [ "$STATUS" = "$STATUS_CHECK" ]; then
        echo "$(date +'%F %H:%M:%S') Status: strimzi-cluster-operator is Ready"
        echo ""
        break
    else
        echo "$(date +'%F %H:%M:%S') Status: strimzi-cluster-operator($STATUS_CHECK)"
    fi
    sleep 5
  done
  echo ""
  echo "----------------------------"
  echo "Check my-cluster-zookeeper-*"
  echo ""
  while :
  do
    STATUS_CHECK=$(oc get pods | grep '^my-cluster-zookeeper-0' | awk '/^my-cluster-zookeeper-0/ {print $3}')
    if [ "$STATUS" = "$STATUS_CHECK" ]; then
        echo "$(date +'%F %H:%M:%S') Status: my-cluster-zookeeper-0 is Ready"
        echo ""
        break
    else
        echo "$(date +'%F %H:%M:%S') Status:  my-cluster-zookeeper-0($STATUS_CHECK)"
    fi
    sleep 5
  done
  while :
  do
    STATUS_CHECK=$(oc get pods | grep '^my-cluster-zookeeper-1' | awk '/^my-cluster-zookeeper-1/ {print $3}')
    if [ "$STATUS" = "$STATUS_CHECK" ]; then
        echo "$(date +'%F %H:%M:%S') Status: my-cluster-zookeeper-1 is Ready"
        echo ""
        break
    else
        echo "$(date +'%F %H:%M:%S') Status: my-cluster-zookeeper-1($STATUS_CHECK)"
    fi
    sleep 5
  done
  while :
  do
    STATUS_CHECK=$(oc get pods | grep '^my-cluster-zookeeper-2' | awk '/^my-cluster-zookeeper-2/ {print $3}')
    if [ "$STATUS" = "$STATUS_CHECK" ]; then
        echo "$(date +'%F %H:%M:%S') Status: my-cluster-zookeeper-2 is Ready"
        echo ""
        break
    else
        echo "$(date +'%F %H:%M:%S') Status: my-cluster-zookeeper-2($STATUS_CHECK)"
    fi
    sleep 5
  done
  echo "----------------------------"
  echo "Check: my-cluster-kafka_x   "
  echo ""
  while :
  do
    STATUS_CHECK=$(oc get pods | grep '^my-cluster-kafka-0' | awk '/^my-cluster-kafka-0/ {print $3}')
    if [ "$STATUS" = "$STATUS_CHECK" ]; then
        echo "$(date +'%F %H:%M:%S') Status: my-cluster-kafka-0 is Ready"
        echo ""
        break
    else
        echo "$(date +'%F %H:%M:%S') Status: my-cluster-kafka-0($STATUS_CHECK)"
    fi
    sleep 5
  done
  while :
  do
    STATUS_CHECK=$(oc get pods | grep '^my-cluster-kafka-1' | awk '/^my-cluster-kafka-1/ {print $3}')
    if [ "$STATUS" = "$STATUS_CHECK" ]; then
        echo "$(date +'%F %H:%M:%S') Status: my-cluster-kafka-1 is Ready"
        echo ""
        break
    else
        echo "$(date +'%F %H:%M:%S') Status: my-cluster-kafka-1($STATUS_CHECK)"
    fi
    sleep 5
  done
  while :
  do
    STATUS_CHECK=$(oc get pods | grep '^my-cluster-kafka-2' | awk '/^my-cluster-kafka-2/ {print $3}')
    if [ "$STATUS" = "$STATUS_CHECK" ]; then
        echo "$(date +'%F %H:%M:%S') Status: my-cluster-kafka-2 is Ready"
        echo ""
        break
    else
        echo "$(date +'%F %H:%M:%S') Status: my-cluster-kafka-2($STATUS_CHECK)"
    fi
    sleep 5
  done
  echo ""
  echo "---------------------------------"
  echo "Check: my-cluster-entity-operator"
  echo ""
  while :
  do
    STATUS_CHECK=$(oc get pods | grep '^my-cluster-entity-operator' | awk '/^my-cluster-entity-operator/ {print $3}')
    if [ "$STATUS" = "$STATUS_CHECK" ]; then
        echo "$(date +'%F %H:%M:%S') Status: my-cluster-entity-operator is Ready"
        echo ""
        break
    else
        echo "$(date +'%F %H:%M:%S') Status: my-cluster-entity-operator($STATUS_CHECK)"
    fi
    sleep 5
  done
}

function checkPostgres {
  oc project postgres
  echo ""
  echo "---------------------------------"
  echo "Check: database-articles (postgres)"
  echo ""
  while :
  do
    STATUS_CHECK=$(oc get pods | grep '^database-articles' | awk '/^database-articles/ {print $3}')
    if [ "$STATUS" = "$STATUS_CHECK" ]; then
        echo "$(date +'%F %H:%M:%S') Status: database-articles is Ready"
        echo ""
        break
    else
        echo "$(date +'%F %H:%M:%S') Status: database-articles($STATUS_CHECK)"
    fi
    sleep 5
  done
}

function checkMicroservices {
  oc project cloud-native-starter
  echo ""
  echo "----------------------------"
  echo "Check: authors              "
  echo ""
  while :
  do
    STATUS_CHECK=$(oc get pods | grep '^authors-' | awk '/^authors-/ {print $3}')
    if [ "$STATUS" = "$STATUS_CHECK" ]; then
        MICROSERVICE=$(oc get pods | grep '^authors-')
        echo "$MICROSERVICE"
        echo "$(date +'%F %H:%M:%S') Status: authors is Ready"
        echo ""
        break
    else
        MICROSERVICE=$(oc get pods | grep '^authors-')
        echo "$MICROSERVICE"
        echo "$(date +'%F %H:%M:%S') Status: authors($STATUS_CHECK)"
    fi
    sleep 5
  done
  echo "----------------------------"
  echo "Check: articles-reactive    "
  echo ""
  while :
  do
    STATUS_CHECK=$(oc get pods | grep '^articles-reactive-' | awk '/^articles-reactive-/ {print $3}')
    if [ "$STATUS" = "$STATUS_CHECK" ]; then
        MICROSERVICE=$(oc get pods | grep '^articles-reactive-')
        echo "$MICROSERVICE"
        echo "$(date +'%F %H:%M:%S') Status: articles-reactive is Ready"
        echo ""
        break
    else
        MICROSERVICE=$(oc get pods | grep '^articles-reactive-')
        echo "$MICROSERVICE"
        echo "$(date +'%F %H:%M:%S') Status: articles-reactive($STATUS_CHECK)"
    fi
    sleep 5
  done
  echo "----------------------------"
  echo "Check: web-api-reactive-    "
  echo ""
  while :
  do
    STATUS_CHECK=$(oc get pods | grep '^web-api-reactive-' | awk '/^web-api-reactive-/ {print $3}')
    if [ "$STATUS" = "$STATUS_CHECK" ]; then
        MICROSERVICE=$(oc get pods | grep '^web-api-reactive-')
        echo "$MICROSERVICE"
        echo "$(date +'%F %H:%M:%S') Status: web-api-reactive- is Ready"
        echo ""
        break
    else
        MICROSERVICE=$(oc get pods | grep '^web-api-reactive-')
        echo "$MICROSERVICE"
        echo "$(date +'%F %H:%M:%S') Status: web-api-reactive-($STATUS_CHECK)"
    fi
    sleep 5
  done
  echo "----------------------------"
  echo "Check: web-app-reactive     "
  echo ""
  while :
  do
    STATUS_CHECK=$(oc get pods | grep '^web-app-reactive-' | awk '/^web-app-reactive-/ {print $3}')
    if [ "$STATUS" = "$STATUS_CHECK" ]; then
        echo "$(date +'%F %H:%M:%S') Status: web-app-reactive- is Ready"
        echo ""
        break
    else
        MICROSERVICE=$(oc get pods | grep '^web-app-reactive-')
        echo "$MICROSERVICE"
        echo "$(date +'%F %H:%M:%S') Status: web-app-reactive-($STATUS_CHECK)"
    fi
    sleep 5
  done
}

function deployExampleApplication {
    echo ""
    echo "----------------------------------"
    echo "---     Example application    ---"
    oc new-project cloud-native-starter
    echo "---          Authors           ---"
    eval $AUTHORS
    echo "---         Articles           ---"
    eval $ARTICLES
    echo "---          Web-API           ---"
    eval $WEB_API
    echo "---          Web-APP           ---"
    eval $WEB_APP
    echo ""
}

# Infrastructure
KAFKA="./deploy-kafka-oc-only.sh"
POSTGRES="./deploy-postgres-via-oc.sh"

# Example application
AUTHORS="./deploy-authors-via-oc.sh"
ARTICLES="./deploy-articles-reactive-postgres-via-oc.sh"
WEB_API="./deploy-web-api-reactive-via-oc.sh"
WEB_APP="./deploy-web-app-reactive-via-oc.sh"

# Provide the links to the microservices
SHOW_URLS="./show-urls.sh"

# Execution of existing bash scripts
cd ~/cloud-native-starter/reactive/os4-scripts/
echo "----------------------------------"
echo "---       Infrastructure       ---"
echo ""
eval $KAFKA
echo ""
checkKafka
echo ""
eval $POSTGRES
echo ""
checkPostgres
echo "----------------------------------"
echo "---    Deploy microservices    ---"
echo ""
deployExampleApplication
echo ""
checkMicroservices
echo ""
echo "----------------------------------"
echo "--- Links to the microservices ---"
echo ""
eval $SHOW_URLS
cd ~/cloud-native-starter/reactive
echo ""
echo "----------------------------------"