# Workshop - Write your first Microservice in Java


**Run final version with Docker**

```
$ cd authors-java-jee/finish
$ mvn package
$ docker build -t authors .
$ docker run -i --rm -p 3000:3000 authors
$ open http://localhost:3000/openapi/ui/
```

**Run final version with Minikube**

```
$ cd authors-java-jee/finish
$ mvn package
$ eval $(minikube docker-env)
$ docker build -t authors:1 .
$ kubectl apply -f deployment/kubernetes-deployment.yaml
$ kubectl apply -f deployment/kubernetes-service.yaml
$ minikubeip=$(minikube ip)
$ nodeport=$(kubectl get svc authors --ignore-not-found --output 'jsonpath={.spec.ports[*].nodePort}')
$ open http://${minikubeip}:${nodeport}/openapi/ui/
```

**Final test in Minikube**

First delete all services:

```
$ cd cloud-native-starter
$ scripts/delete-all.sh
```

Next deploy the Java based authors service as documented above.

Next deploy the articles and web-api services:

```
$ scripts/deploy-articles-java-jee.sh
$ scripts/deploy-web-api-java-jee.sh
$ scripts/show-urls.sh
```

Invoke /getmultiple, for example 'http://192.168.99.100:31380/web-api/v1/getmultiple'.


**Tasks (Ideas)**

1) Build and run in Docker
2) Change path from '/api/v1/mypath' to '/api/v1/getauthor'
3) Add OpenAPI documentation for /getauthor
4) Add /health endpoint
5) Build image in Minikube
6) Deploy deployment and service via Minikube
7) Replace Node.js based authors service with Java version (see above)
