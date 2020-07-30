#!/bin/bash

tkn=$(curl -sk --data "username=alice&password=alice&grant_type=password&client_id=frontend" https://$INGRESSURL/auth/realms/quarkus/protocol/openid-connect/token   | jq ".access_token" | sed 's|"||g')

export TOKEN=$tkn
echo $TOKEN
