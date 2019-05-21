# Authors Service

## Description
This is a Node.js application that allows to read authors information (Twitter handle, Blog URL) from an IBM Cloudant Database or from a local "in-memory" database. With the local database everything can run in Minikube without relying on external services.

## Implementation
Node.js with Express, based on the "Node.js Microservice with Express.js" starter kit on IBM Cloud.
We tested the deployment on Minikube or IBM Kubernetes Service.

The local "in-memory" database uses json-query, the data set is in authors-nodejs/authordata.json.

A Cloudant instance can be created with ibm-scripts/create-cloudant.sh. It will 

* create a Cloudant instance in the Cloud region set in local.env (us-south is default)
* create the "authors" database 
* create a view (authors-nodejs/authorview.json)
* populate the database with our sample data (authors-nodejs/authordata.json)
* set the correct values in scripts/deploy-authors-nodejs.cfg which is used by the deployment script for the authors service.

## Deployment

For Minikube execute `scripts/deploy-authors-nodejs.sh`

For IBM Kubernetes Service (IKS) execute `iks-scripts/deploy-authors-nodejs.sh`

