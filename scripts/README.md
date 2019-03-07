### Deploy Authors API

* Edit _deploy-authors-nodejs.cfg_ if necessary:
  * If you want to use Cloudant on IBM Cloud, change DB to "cloud", enter the CLOUDANTURL ###############
* Make sure Minikube is started
* Run deploy-authors-nodejs.sh

If you run the script for the first time in your environment you may see errors when the script tries to delete a previous deployment. This is normal!

Get the API URL with `get-url-authors-nodejs.sh`

Display logs with `display-logs-authors-nodejs.sh`

Delete the service with `delete-authors-nodejs.sh`