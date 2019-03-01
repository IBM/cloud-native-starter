# Authors Service

## Description
This is a Node.js application that allows to read authors information (Twitter handle, Blog URL) from an IBM Cloudant Database.

## Implementation
Node.js with Express, based on the "Node.js Microservice with Express.js" starter kit on IBM Cloud.
The app runs on Minikube or IBM Cloud Kubernetes Service.

## Docker image
`eval $(minikube docker-env)`
`docker build -t authors-service:1.0.0 .`

## Kubernetes

deployment.yaml must contain the CouchDB URL as environment variable 

## Usage

GET http://<inikube-IP:authors-service-svcNodePort/api/v1/getauthor?name=Harald%20Uebele

Result
200 OK
{
  "name": "Harald Uebele",
  "twitter": "@harald_u",
  "blog": "https://haralduebele.blog"
}
