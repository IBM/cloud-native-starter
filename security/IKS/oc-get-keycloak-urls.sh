#!/bin/bash
KEYCLOAK_URL=https://$(oc get route keycloak --template='{{ .spec.host }}')/auth &&
echo "" &&
echo "Keycloak:                   $KEYCLOAK_URL" &&
echo "Keycloak Admin Console:     $KEYCLOAK_URL/admin" &&
echo "Keycloak Account Console:   $KEYCLOAK_URL/realms/myrealm/account" &&
echo "Keycloak [auth-server-url]: $KEYCLOAK_URL/realms/quarkus"
