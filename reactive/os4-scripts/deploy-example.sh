#!/bin/bash

# Infrastructure
KAFKA="sh ~/cloud-native-starter/reactive/os4-scripts/deploy-kafka-oc-only.sh"

# Example application
AUTHORS="sh ~/cloud-native-starter/reactive/os4-scripts/deploy-authors-via-oc.sh"
ARTICLES="sh ~/cloud-native-starter/reactive/os4-scripts/deploy-articles-reactive-postgres-via-oc.sh"
WEB_API="sh ~/cloud-native-starter/reactive/os4-scripts/deploy-web-api-reactive-via-oc.sh"
WEB_APP="sh ~/cloud-native-starter/reactive/os4-scripts/deploy-web-app-reactive-via-oc.sh"

# Execution of existing bash scripts
echo="*** Infrostructure ***"
OUTPUT=$("$KAFKA")
echo="*** Example application ***"
echo $OUTPUT
OUTPUT=$("$AUTHORS")
echo $OUTPUT
OUTPUT=$("$ARTICLES")
echo $OUTPUT
OUTPUT=$("$WEB_API")
echo $OUTPUT
OUTPUT=$("$WEB_APP")
echo $OUTPUT
echo="*** Follow the steps to deploy the PostgresSQL container as written in the workshop material.  ***"
