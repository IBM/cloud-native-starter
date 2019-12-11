## Demo: Authentication and Authorization

In order to authenticate users, you need an OpenID identity provider. 

You can use [IBM App ID](https://console.bluemix.net/catalog/services/appid) or you can use an OpenID identity provider of your choice.

>Before running the scripts below, make sure you can [access the IBM Cloud](SetupIBMCloudAccess.md) and you did setup the local [Minikube environment](SetupLocalEnvironment.md).


**Create new App ID service instance**

Run the following command to create these artifacts:

* App ID service instance 'app-id-cloud-native'
* App ID Cloud Foundry alias 'app-id-cloud-native'
* App ID credentials
* App ID test user 'user@demo.email, verysecret'
* App ID test admin 'admin@demo.email, verysecret'
* App ID redirect URL

```
$ ibm-scripts/create-app-id.sh
```


**Reuse an existing App ID service instance**

The IBM Cloud lite plan only allows one App ID instance in your organization. If you have an App ID instance, you can use it rather than creating a new one. 

In this case paste the App ID credentials in [authentication-nodejs/.env](../authentication-nodejs/.env). Check out [authentication-nodejs/.env.template](../authentication-nodejs/.env.template) for an example. Additionally paste APPID_ISSUER and APPID_JWKS_URI in [local.env](local.env). See [template.local.env](template.local.env) for an example.


**Use another OpenID identify provider**

You can use any OpenID identity provider. In this case paste the endpoint URLs in [authentication-nodejs/.env](../authentication-nodejs/.env). Check out [authentication-nodejs/.env.template](../authentication-nodejs/.env.template) for an example. Additionally paste APPID_ISSUER and APPID_JWKS_URI in [local.env](local.env). See [template.local.env](template.local.env) for an example.


**Set up the Demo**

Invoke the following commands to set up the demo. 

```
$ cd $PROJECT_HOME
$ scripts/check-prerequisites.sh
$ scripts/delete-all.sh
$ scripts/deploy-articles-java-jee.sh
$ scripts/deploy-web-api-java-jee.sh
$ scripts/deploy-authors-nodejs.sh
$ scripts/deploy-authentication-nodejs.sh
$ scripts/deploy-web-app-vuejs-authentication.sh
$ scripts/deploy-istio-ingress-v1.sh
$ scripts/show-urls.sh
```

Open the web application with the URL that is displayed as output of 'scripts/show-urls.sh'. When you click 'Login', use the credentials of the demo user.

After the login, the Vue.js application stores the id_token if the Vuex state.

<kbd><img src="../images/login.jpeg" /></kbd>

Check out the [animated gif](../images/login.gif) to see the authentication flow.

<kbd><img src="../images/login.gif" /></kbd>


### Authorization via Istio

Invocations of the endpoint 'create' of the 'web-api' service have been [protected](https://github.com/IBM/cloud-native-starter/blob/master/istio/protect-web-api.yaml.template) via Istio. Only authenticated users can invoke this endpoint by passing in the bearer token in the HTTP header.

When you invoke the endpoint without bearer token, you get an exception.

<kbd><img src="../images/endpoint-protection-istio-1.png" /></kbd>

When you log in from the web application, the token is stored in Vuex. After this 'Create Article' can be invoked from the dropdown.

<kbd><img src="../images/endpoint-protection-istio-2.png" /></kbd>

This screenshot shows the page to enter information about a new article:

<kbd><img src="../images/endpoint-protection-istio-3.png" /></kbd>

When the REST API is invoked, the bearer is added:

<kbd><img src="../images/endpoint-protection-istio-4.png" /></kbd>

Watch the [animated gif](../images/endpoint-protection-istio.gif) to see the flow in action.


### Authorization via MicroProfile

In order to protect functionality on a more fine-grained level, authorization can be handled in the business logic of microservices.

From the web application's dropdown 'Manage Application' can be invoked which triggers the endpoint '[manage](../web-api-java-jee/src/main/java/com/ibm/webapi/apis/Manage.java)' of the 'web-api' microservice.

Only the user 'admin@demo.email' is allowed to invoke this endpoint.

<kbd><img src="../images/authorization-microprofile-admin.png" /></kbd>

For the user 'user@demo.email' an error is thrown.

<kbd><img src="../images/authorization-microprofile-user.png" /></kbd>

Watch the [animated gif](../images/authorization-microprofile.gif) to see the flow in action.

---

### Additional information

For the authentication is it useful to understand [JSON Web Tokens](https://jwt.io/) and [OpenID](https://openid.net/what-is-openid/). 

The additional information does contain a _simplified view_ of the authentication implementation and _the configuration for services and of the environment_.

#### Simplified view of the authentication

Here you can see a higher and simplified view, how the authentication was implemented with: 

* JSON Web Token (JWT)
* IBM App ID
* Authenication Microservice (Node.js)
* Istio
* MicroProfile

##### 1. Get the JSON Web Token (JWT)

The following gifs shows a simplified walkthrough, how to get the JSON Web Token from [IBM App ID](https://console.bluemix.net/catalog/services/appid) service. Some of the relevant code is shown and marked with yellow in the gif.

* Request JWT using the Authentication Microservice with   IBM App ID Service. The gif shows a simplified sequence.

<kbd><img src="../images/authentication-appid-01.gif" /></kbd>

* The IBM App ID Service creates a login dialog for the user authentication and validates the login. The gif shows a simplified sequence.

<kbd><img src="../images/authentication-appid-02.gif" /></kbd>

* The IBM App ID Service provides the JWT and than the Authentication Microservice extracts the user information. The gif shows a simplified sequence.

<kbd><img src="../images/authentication-appid-04.gif" /></kbd>

##### 2. Using JSON Web Token (JWT) with Istio

We use the given JWT incombination with [Istio Policy](https://istio.io/docs/concepts/security/#origin-authentication) to secure the access to endpoint to create a article in our Microservices based application. In our case IBM App ID provides the needed OpenID information for Istio. 
The gif shows a simplified sequence and some of the relevant code, which is marked in yellow inside the gif.

<kbd><img src="../images/authentication-appid-05.gif" /></kbd>

##### 2. Using JSON Web Token (JWT) and MicroProfile

Inside the _Web-API_ Microservice the JWT will be used to verify the _admin user_, to do that [MicroProfile JWT-AUTH](https://microprofile.io/project/eclipse/microprofile-jwt-auth) is used. The gif shows a simplified sequence and some of the relevant code is shown, which is marked in yellow inside the gif.

<kbd><img src="../images/authentication-appid-07.gif" /></kbd>


#### Configuration for services and the environment 

##### 1. APP ID

Here is more detailed information about the IBM App ID configuration.

###### a. Identity Providers

We did enable following Identity Providers:

* Cloud Directory
* Facebook
* Google
* Anonymous (Associate custom attributes with your users as they interact with your app, before they sign-in.)

<kbd><img src="../images/appid-identity-providers.png" /></kbd>

###### b. Cloud Directory

Here we did configure two user in our Cloud Directory:

* user 'user@demo.email, verysecret'
* admin 'admin@demo.email, verysecret'

<kbd><img src="../images/appid-users.png" /></kbd>

###### c. Service credential 

We created one service credential.

<kbd><img src="../images/appid-service-credential.png" /></kbd>

##### 2. Environment configuration

The setup `ibm-scripts/create-app-id.sh` script will add following entries into you `local.env` file.

```sh
APPID_ISSUER=https://us-south.appid.cloud.ibm.com/oauth/v4/a21df9e8-...977
APPID_OPENID_CONFIG=https://us-south.appid.cloud.ibm.com/oauth/v4/a21df9e8-...977/.well-known/openid-configuration
APPID_AUTHORIZATION_ENDPOINT=https://us-south.appid.cloud.ibm.com/oauth/v4/a21df9e8-....977/authorization
APPID_TOKEN_ENDPOINT=https://us-south.appid.cloud.ibm.com/oauth/v4/a21df9e8-....977/token
APPID_USERINFO_ENDPOINT=https://us-south.appid.cloud.ibm.com/oauth/v4/a21df9e8-....977/userinfo
APPID_JWKS_URI=https://us-south.appid.cloud.ibm.com/oauth/v4/a21df9e8-....977/publickeys
APPID_CLIENTID=9cc6a03e-....-1bc4268b111e
APPID_SECRET=NzUyYWRjZDUtMjBiYS...I5ZTk4ODM3
APPID_MGMTURL=https://us-south.appid.cloud.ibm.com/management/v4/a21df9e8-....977
```
