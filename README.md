# Cloud Native Starter for Java and Node.js

This project contains sample code that shows how to build cloud-native applications with Java and Node.js and deploy them to Kubernetes and Istio.

The project showcases the following functionality:

* Chained invocations
* Traffic management (A/B, canary)
* Polyglot Java and JavaScript microservices
* Circuit breaker and fallbacks
* Distributed logging
* Metrics
* Authentication and authorization
* APIs incl. documentation
* Configuration
* Deployments (helm, yaml)

### Work in Progress

Stay tuned for more ...


### Local Environment Setup

Follow these [instructions](LocalEnvironment.md) to set up the local environment.


### Deployment

Deploy and redeploy:

```
$ scripts/check-prerequisites.sh
$ scripts/deploy-articles-java-jee.sh
$ scripts/deploy-web-api-java-jee.sh
```


### Run the Demo

After installing the web-api, you get an URL like http://192.168.99.100:31695/openapi/ui/ in the terminal that you can use to open the OpenAPI explorer.