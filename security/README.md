in progress .....
===================


1. Create OpenShift cluster, e.g. on the IBM Cloud:
https://cloud.ibm.com/kubernetes/catalog/create?platformType=openshift

2. oc login in terminal

3. Install the Keycloak operator:
git clone https://github.com/keycloak/keycloak-operator.git
oc apply -f deploy/examples/keycloak/keycloak.yaml

or via UI:
https://www.keycloak.org/getting-started/getting-started-operator-openshift

4. Create Keycloak cluster:
oc create -f https://raw.githubusercontent.com/keycloak/keycloak-quickstarts/latest/operator-examples/mykeycloak.yaml
oc get keycloak/mykeycloak -o jsonpath='{.status.ready}'

5. Get the admin password and Keycloak URL
oc get secret credential-example-keycloak -o go-template='{{range $k,$v := .data}}{{printf "%s: " $k}}{{if not $v}}{{$v}}{{else}}{{$v | base64decode}}{{end}}{{"\n"}}{{end}}'

KEYCLOAK_URL=https://$(oc get route keycloak --template='{{ .spec.host }}')/auth &&
echo "" &&
echo "Keycloak:                 $KEYCLOAK_URL" &&
echo "Keycloak Admin Console:   $KEYCLOAK_URL/admin" &&
echo "Keycloak Account Console: $KEYCLOAK_URL/realms/myrealm/account" 

5. Import realm
file: quarkus-real.json

6. define keycloak url in application.properties of articles-secure

7. define keycloak url in application.properties of web-api-secure

8. define keycloak url in main.js in the web-app folder

9. Run first terminal (runs on 8080):

```
$ cd web-app
$ yarn install
$ yarn serve
```

10. Run second terminal (runs on 8081):

```
$ cd web-api-secure
$ mvn clean package quarkus:dev
```

11. Run third terminal (runs on 8082):

```
$ cd articles-secure
$ mvn clean package quarkus:dev
```

12. Open web ui
http://localhost:8080

Test user: alice, alice
