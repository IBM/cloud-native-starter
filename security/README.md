## Authentication and Authorization

This part of the project demonstrates how to do authentication and authorization in Quarkus applications and web applications. [Keycloak](https://www.keycloak.org/) is used as OpenID Connect provider.

### Scenario



### Setup

At this point the code is run locally which means you need a JVM and Maven. For the web application you also need yarn.

#### Step 1: Create an OpenShift cluster, e.g. on the IBM Cloud

https://cloud.ibm.com/kubernetes/catalog/create?platformType=openshift

#### Step 2: Login in a Terminal

Get the login command from the OpenShift Web Console, e.g.

```
$ oc login --token=OnMwHZ4FLgZnWdcxxxxxxxxxxxxxxx --server=https://c107-e.us-south.containers.cloud.ibm.com:30058
```

#### Step 3: Install the Keycloak Operator

Follow these steps to install the operator via the OpenShift Web Console: [documentation](
https://www.keycloak.org/getting-started/getting-started-operator-openshift
).

#### Step 4: Create a Keycloak Cluster

You can create the Keycloak cluster either in the OpenShift Web Console or programmatically:

```
$ oc create -f keycloak.yaml
$ oc get keycloak/mykeycloak -o jsonpath='{.status.ready}'
```

#### Step 5: Get the admin password and Keycloak URL

```
$ oc get secret credential-example-keycloak -o go-template='{{range $k,$v := .data}}{{printf "%s: " $k}}{{if not $v}}{{$v}}{{else}}{{$v | base64decode}}{{end}}{{"\n"}}{{end}}'
$ KEYCLOAK_URL=https://$(oc get route keycloak --template='{{ .spec.host }}')/auth &&
echo "" &&
echo "Keycloak:                 $KEYCLOAK_URL" &&
echo "Keycloak Admin Console:   $KEYCLOAK_URL/admin" &&
echo "Keycloak Account Console: $KEYCLOAK_URL/realms/myrealm/account" 
```

#### Step 6: Import Realm in Keycloak

Open the Keycloak console and log in as admin. Then import [quarkus-realm.json](quarkus-realm.json).

#### Step 7: Clone the Repo

```
$ git clone https://github.com/IBM/cloud-native-starter.git
$ cd security
```

#### Step 8: Configure articles-secure

Define Keycloak URL in [application.properties](articles-secure/src/main/resources/application.properties).

#### Step 9: Configure web-api-secure

Define Keycloak URL in [application.properties](web-api-secure/src/main/resources/application.properties).

#### Step 10: Configure web-app

Define Keycloak URL in [main.js](web-app/src/main.js).

#### Step 11: Run web-app

Run first terminal (on port 8080):

```
$ cd web-app
$ yarn install
$ yarn serve
```

#### Step 12: Run web-api

Run second terminal (on port 8081):

```
$ cd web-api-secure
$ mvn clean package quarkus:dev
```

#### Step 13: Run articles-secure

Run third terminal (on port 8082):

```
$ cd articles-secure
$ mvn clean package quarkus:dev
```

#### Step 14: Open Web App

http://localhost:8080

Log in with the test user: alice, alice