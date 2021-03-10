**--------------------------------------------**
**-------------UNDER CONSTRUCTION-------------**
**--------------------------------------------**

# Install the example with Helm and Operater to OpenShift

# 1. Install Istio on OpenShift

Follow the [setup Istio instructions](setup-istio.md).

# 2. Install the Example application using Helm Charts 

### Step 1:

```sh
oc login --token=TOKEN --server=https://URL
```

### Step 2:

```sh
oc new-project cloud-native-starter
oc project cloud-native-starter
```

### Step 3: Invoke the Helm Charts

```sh
oc project cloud-native-starter
cd helm
helm install keycloak ./keycloak 
helm install web-app ./web-app 
helm install web-api-secure ./web-api-secure
helm install articles-secure ./articles-secure
```

### Step 4: Clean Project

```sh
oc project cloud-native-starter
cd helm
helm uninstall keycloak 
helm uninstall web-app 
helm uninstall web-api-secure 
helm uninstall articles-secure
```


# Additional information

### Helm

### Verify the Helm Chart

```sh
cd ~/cloud-native-starter/security/helm/articles-secure
helm lint
```

### Update only the values of the Helm Chart

```sh
helm upgrade -f ./web-api-secure/values.yaml
```

### Delete the Helm Chart

```sh
helm uninstall web-api-secure
```
---

# Building own image for the Deployment

### Add container images to `Quay` image registry

Using [quay repository](https://quay.io/repository/)

```sh
cd cloud-native-starter/security
export ROOT_PATH=$(PWD)
```

* `web-app`

```sh
cd $ROOT_PATH/web-app
docker login quay.io
docker build -t "quay.io/tsuedbroecker/web-app-secure:v1" -f Dockerfile.os4 .
docker push "quay.io/tsuedbroecker/web-app-secure:v1"
```
* OpenShift and no `tls`

```sh
cd $ROOT_PATH/web-app
docker login quay.io
docker build -t "quay.io/tsuedbroecker/web-app-secure-http:v1" -f Dockerfile.os4 .
docker push "quay.io/tsuedbroecker/web-app-secure-http:v1"
```

* `articles`

```sh
cd $ROOT_PATH/articles-secure
docker login quay.io
docker build -t "quay.io/tsuedbroecker/articles-secure:v1" -f Dockerfile .
docker push "quay.io/tsuedbroecker/articles-secure:v1"
```

* `web-api`

```sh
cd $ROOT_PATH/web-api-secure
docker login quay.io
docker build -t "quay.io/tsuedbroecker/web-api-secure:v1" -f Dockerfile .
docker push "quay.io/tsuedbroecker/web-api-secure:v1"
```