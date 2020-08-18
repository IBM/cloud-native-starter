#!/bin/bash

# Set the needed parameter
USER=admin
PASSWORD=admin
GRANT_TYPE=password
CLIENT_ID=admin-cli
INGRESSURL="YOUR URL"

echo "------------------------------------------------------------------------"
echo "Your INGRESSURL for Keycloak: https://$INGRESSURL"
echo "------------------------------------------------------------------------"
echo ""

# Get the bearer token from Keycloak
echo "------------------------------------------------------------------------"
echo "Get the bearer token from Keycloak"
echo "------------------------------------------------------------------------"
echo ""
access_token=$( curl -d "client_id=$CLIENT_ID" -d "username=$USER" -d "password=$PASSWORD" -d "grant_type=$GRANT_TYPE" "https://$INGRESSURL/auth/realms/master/protocol/openid-connect/token" | sed -n 's|.*"access_token":"\([^"]*\)".*|\1|p')

# Create the realm in Keycloak
echo "------------------------------------------------------------------------"
echo "Create the realm in Keycloak"
echo "------------------------------------------------------------------------"
echo ""

result=$(curl -d @./quarkus-realm.json -H "Content-Type: application/json" -H "Authorization: bearer $access_token" "https://$INGRESSURL/auth/admin/realms")

if [ "$result" = "" ]; then
  echo "------------------------------------------------------------------------"
  echo "The realm is created."
  echo "Open following link in your browser:"
  echo "https://$INGRESSURL/auth/admin/master/console/#/realms/quarkus"
  echo "------------------------------------------------------------------------"
else
  echo "------------------------------------------------------------------------"
  echo "It seems there is a problem with the realm creation: $result"
  echo "------------------------------------------------------------------------"
fi
