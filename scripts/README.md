### Deploy Authors API

Create a copy of file _deploy-authors-nodejs.cfg.template_ and name it _deploy-authors-nodejs.cfg_
Enter the complete Cloudant URL (can be found under Credentials for the Cloudant Service in the IBM Cloud Console)
Dont forget to enclose the URL in " "

Deploy with `deploy-authors-nodejs.sh`
__Note__: Minikube must be started and ready!

If you run it for the first time in your environment you will see errors when the script tries to delete a previous deployment. This is normal!

Get the API URL with `get-url-authors-nodejs.sh`

Display logs with `display-logs-authors-nodejs.sh`