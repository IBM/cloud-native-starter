## Building and deploy the Containers

****** **UNDER CONSTRUCTION** ******

In this Lab we build and deploy the containers with microservices to Kubernetes.

Along this way we inspect the **Dockerfiles** for the container images and we take a look into the configured **yaml files** to create the **deployment** and setup the right **ISTIO configuration** for the microservices.

The following diagram shows a high level overview of steps which will be automated later with bash scripts.

![cns-container-deployment-01](images/cns-container-deployment-01.png)

1. Uploading container definition
2. Building and storing of theproduction container image inside the IBM Cloud Registry
3. Deploying the containers into the Kuberentes Cluster

## Container images

Before we will execute to bash scripts to build and upload the container images, we will take a look into the Dockerfile to build these container images.

### Java container images

The articles and the authors microservices are written in Java and they run on OpenLiberty.

#### Articles container image definition

Now we take a look into the [Dockerfile](../articles-java-jee/Dockerfile.nojava) to create the articles service. The inside the Dockerfile we use multiple stages to build the  container image. 
The reason for the two stages we have the objective to be independed on local environment settings, when we create the container. With this concept we don't have to ensure that Java and Maven (or wrong versions) installed.

* Build environment container

Here we create our **build environment container** based on the maven 3.5 image from the [dockerhub](https://hub.docker.com/_/maven/).

```
FROM maven:3.5-jdk-8 as BUILD
COPY src /usr/src/app/src
COPY pom.xml /usr/src/app
```

Let's build the **articles.war** inside the container image, using the maven command **mvn -f pom.xml clean package** .

```
RUN mvn -f /usr/src/app/pom.xml clean package
```

* Production container

Here we create the **production container** based on the **openliberty** with **microProfile2**.
Then **zipkintracer** will be installed.

```
FROM openliberty/open-liberty:microProfile2-java8-openj9
ADD liberty-opentracing-zipkintracer-1.2-sample.zip /
RUN unzip liberty-opentracing-zipkintracer-1.2-sample.zip -d /opt/ol/wlp/usr/ \
 && rm liberty-opentracing-zipkintracer-1.2-sample.zip
COPY liberty/server.xml /config/
```

Now it is time to copy the build result **articles.war** form our **build environment container** into the correct place inside the **production container**.

```
COPY --from=BUILD /usr/src/app/target/articles.war /config/dropins/
```
#### Web-api container image definition

The web-api [Dockerfile](../web-apo-java-jee/Dockerfile.nojava) to create the web-api service, works in the same way as for **articles container**. Inside the Dockerfile we use the same multiple stages to build the container image as in the for the **articles container**. 

### Node.JS container images

The **web-app** and the **authors** services are written in Node.JS.

#### Web-app container image definition

The web-app [Dockerfile](../web-app-vuejs/Dockerfile) to create the  web-app application, works in the same way as for **articles container**. Inside the Dockerfile we use the same multiple stages to build the container image as in the for the **articles container**.

Here is **build environment container** based on the alpine 8 image from the [dockerhub](https://hub.docker.com/_/alpine).

```
FROM node:8-alpine as BUILD
 
COPY src /usr/src/app/src
COPY public /usr/src/app/public
COPY package.json /usr/src/app/
COPY babel.config.js /usr/src/app/

WORKDIR /usr/src/app/
RUN yarn install
RUN yarn build
```

The **production container** is based on [nginx](https://hub.docker.com/_/nginx).

```
FROM nginx:latest
COPY nginx.conf /etc/nginx/conf.d/default.conf
COPY --from=BUILD /usr/src/app/dist /usr/share/nginx/html
```
#### Authors container image definition

The authors [Dockerfile](../authors/Dockerfile) to create the web-api service, does directly create the production image and is based on the alpine 8 image from the [dockerhub](https://hub.docker.com/_/alpine).

```
FROM node:8-alpine

# Create app directory
WORKDIR /usr/src/app

# Install app dependencies
COPY package*.json ./
RUN npm install

# Bundle app source
COPY . .

# Server listens on
EXPOSE 3000

CMD ["npm", "start"]
```

## Configurations for the deployment to Kubernetes

## Deploy the container to the Kubernetes Cluster

* Articles

Invoke the following commands to set up the Java based microservice 'articles':

```
$ cd $PROJECT_HOME
$ scripts/check-prerequisites.sh
$ scripts/delete-all.sh
$ scripts/deploy-articles-java-jee.sh
$ scripts/show-urls.sh
```

Invoke the curl command which is displayed as output of 'scripts/show-urls.sh' to get ten articles.

Check out the article [Dockerizing Java MicroProfile Applications](http://heidloff.net/article/dockerizing-container-java-microprofile) for more details.


