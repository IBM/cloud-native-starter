# Authors Service

## Description
This is a Node.js application that allows to read authors information (Twitter handle, Blog URL) from an IBM Cloudant Database or from a local "in-memory" database. With the local database everything can run in Minikube without relying on external services.

## Implementation
Node.js with Express, based on the "Node.js Microservice with Express.js" starter kit on IBM Cloud.
The app runs on Minikube or IBM Cloud Kubernetes Service.

The local "in-memory" database uses json-query, the data set is in cloud-native-starter/authors-nodejs/public/authors.json.

## Deployment

* Go to the cloud-native-starter/scripts directory.
* Edit _deploy-authors-nodejs.cfg_ if necessary:
  * If you want to use Cloudant on IBM Cloud, change DB to "cloud", enter the CLOUDANTURL ###############
* Make sure Minikube is started
* Run deploy-authors-nodejs.sh

## Usage

GET http://<minikube-IP:authors-svcNodePort/api/v1/getauthor?name=Harald%20Uebele

Result
200 OK
{
  "name": "Harald Uebele",
  "twitter": "@harald_u",
  "blog": "https://haralduebele.blog"
}
