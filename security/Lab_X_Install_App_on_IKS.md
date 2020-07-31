# Installation of the app on the IKS cluster

You have compiled all three pieces of our sample app, articles-secure, web-api-secure, and web-app, when you ran and tested locally.

In this exercise we will use precompiled container images that we uploaded to Docker Hub.

1. We cannot set the OIDC provider (keycloak) in application.properties without recompiling the code. So for this example, we specify the Quarkus OIDC property as environment variable during deployment. The environment variable is read from a config map. In directory IKS, modifify configmap.yaml and edit QUARKUS_OIDC_AUTH_SERVER_URL with your keycloak URL. It must end in /auth/realms/quarkus, enclosed in "".

Now deploy the 3 services:

2. In directory  articles-secure/deployment

   kubectl apply -f articles.yaml

3. In directory  web-api-secure/deployment

   kubectl apply -f web-api.yaml

4. In directory  web-app/deployment   

   kubectl apply -f web-app.yaml

Adjust the Redirect URL in Keycloak:   

5. Login to Keycloak as admin, Clients: frontend
    Valid Redirect URIs: e.g.  https://harald-uebele-fra05-162e406f043e20da9b0ef0731954a894-0001.eu-de.containers.appdomain.cloud/*

Test:    

In the browser open the app with e.g.   https://harald-uebele-fra05-162e406f043e20da9b0ef0731954a894-0001.eu-de.containers.appdomain.cloud  

Login in with user: alice, password: alice

# TLS

**Question 1:** Why can we access our application with TLS (https://...) ?

**Answer:** We prepared this in Exercise 1, Step 3. 
1. We let IBM Cloud create a DNS entry and Let's Encrypt certificate
2. We added this certificate to the Istio Ingress
3. We added the DNS name (host) to the Istio Ingress Gateway definition
4. We added it also to the VirtualService definition that configures the Gateway and here is our secret, look at IKS/istio-ingress-tls.yaml:

   The Gateway definition specifies HTTPS only and points to the location of the TLS certificates.

   The VirtualService definition specifies 3 rules:
   - If call the DNS entry / Ingress URL with '/auth' it will direct to keycloak.
   - With '/articles' it will direct to the web-api
   - Without an path it directs to the web-app itself.

**Question 2:** We use https in the browser but everything behind the Istio Ingress is http only, unencrypted?

**Answer:** That is the beauty of Istio! Yes, we make our requests via http which is most obvious with the web-app that is called on port 80. 

But Istio injects an Envy proxy into every pod in the default namespace automatically. We defined this in Exercise 1. (?????WIRKLICH?????)

There is also an Envoy proxy in the Istio Ingress pod. Communication between the Envoys is always encrypted, Istio uses mTLS. And all our requests flow through the proxies so even if the communication between e.g. web-api and articles is using http, the communication between the web-api pod and the articles pod is secure.

**Question 3:** Is this safe?

**Answer:** No, at least not not totally. By default, after installation, Istio uses mTLS in PERMISSIVE mode. This allows to test and gradually secure your microservices mesh. 

Continue with the next section to see how to change that.

# STRICT mTLS 

Da muss noch Text rein von hier [https://github.com/Harald-U/istio-handson/blob/master/workshop/exercise6.md#mutual-authentication-with-transport-layer-security-mtls](https://github.com/Harald-U/istio-handson/blob/master/workshop/exercise6.md#mutual-authentication-with-transport-layer-security-mtls)

Beispiel:
INGRESSURL=harald-uebele-fra05-162e406f043e20da9b0ef0731954a894-0001.eu-de.containers.appdomain.cloud

curl -sk --data "username=alice&password=alice&grant_type=password&client_id=frontend" https://$INGRESSURL/auth/realms/quarkus/protocol/openid-connect/token | jq ".access_token"

Copy the token with out ""!!!

TOKEN=[copied token]

kubectl get svc --> Nodeport von web-api
NODEPORT=31109

K8s Node external IP (ic ks worker ls), public IP
WORKERIP=149.81.149.2

curl -i http://$WORKERIP:$NODEPORT/articles -H "Authorization: Bearer $TOKEN"

==> Works, over http, no TLS!

Set mTLS to strict in default namespace and for services

kubectl apply -f IKS/mtls.yaml

--> Creates PeerAuthentication policy for default, and DestinationRules for web-api and articles

Create new token, paste it in TOKEN=

curl -i http://$WORKERIP:$NODEPORT/articles -H "Authorization: Bearer $TOKEN"
Result:
curl: (56) Recv failure: Connection reset by peer

As you can see, you can no longer access the service, even if you know its NodePort and the external IP of a K8s worker node. 

Now everything is secure but there is another level of security that we can apply. Read on.

# Control access to a service

Istio supports Role Based Access Control (RBAC) for HTTP services in the service mesh. Let's leverage this to configure access between Web-API and Articles services. This effectively prevents man-in-the-middle attacks from entities that have access to your cluster. 

!!! Mach ich nach meinem Urlaub, ist im Wesentlichen das hier [https://github.com/Harald-U/istio-handson/blob/master/workshop/exercise6.md#control-access-to-the-articles-service](https://github.com/Harald-U/istio-handson/blob/master/workshop/exercise6.md#control-access-to-the-articles-service)







