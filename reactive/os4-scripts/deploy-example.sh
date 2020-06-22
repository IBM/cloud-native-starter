#!/bin/bash

# Infrastructure
KAFKA="deploy-kafka-oc-only.sh"

# Example application
AUTHORS="deploy-authors-via-oc.sh"
ARTICLES="deploy-articles-reactive-postgres-via-oc.sh"
WEB_API="deploy-web-api-reactive-via-oc.sh"
WEB_APP="deploy-web-app-reactive-via-oc.sh"

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
