### Deploy Authors API

* Copy _deploy-authors-nodejs.cfg.template_ as _deploy-authors-nodejs.cfg_ and edit:
  * If you want to use a local in-memory database, change DB to "local", leave CLOUDANTURL empty
  * If you want to use Cloudant on IBM Cloud, change DB to "cloud", enter the CLOUDANTURL ###############
* Make sure Minikube is started
* Run deploy-authors-nodejs.sh

If you run the script for the first time in your environment you may see errors when the script tries to delete a previous deployment. This is normal!

Get the API URL with `get-url-authors-nodejs.sh`

Display logs with `display-logs-authors-nodejs.sh`