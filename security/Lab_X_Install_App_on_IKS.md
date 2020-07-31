

1. In directory IKS, modifify configmap.yaml and edit QUARKUS_OIDC_AUTH_SERVER_URL
   Must end in /auth/realms/quarkus, enclosed in ""

2. In directory    articles-secure/deployment

   kubectl apply -f articles.yaml

3.    