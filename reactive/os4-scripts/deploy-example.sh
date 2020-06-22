#!/bin/bash

# Infrastructure
KAFKA="./deploy-kafka-oc-only.sh"

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
eval $KAFKA
echo ""
echo "----------------------------------"
echo "---     Example application    ---"
eval $AUTHORS
echo "---         Articles           ---"
eval $ARTICLES
echo "---          Web-API           ---"
eval $WEB_API
echo "---          Web-APP           ---"
eval $WEB_APP
echo ""
echo "----------------------------------"
echo "--- Links to the microservices ---"
eval $SHOW_URLS
cd ~/cloud-native-starter/reactive
echo ""
echo "----------------------------------"
echo="Now deploy the PostgresSQL operator by following the step in the workshop."
