## Scripts in /ibm-scripts

### create-app-id.sh

Creates an instance of the AppID service on IBM Cloud and performs the necessary setup of the instance. Parameters required for the deployment are stored in local.env.

### create-cloudant.sh

The script will

* create a Cloudant instance in the Cloud region set in local.env (us-south is default)
* create the "authors" database 
* create a view (authors-nodejs/authorview.json)
* populate the database with our sample data (authors-nodejs/authordata.json)
* set the correct values in scripts/deploy-authors-nodejs.cfg which is used by the deployment script for the authors service.