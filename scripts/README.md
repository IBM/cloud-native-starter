### Deploy Authors API

Create a copy of file deploy-authors-nodejs.cfg.template and name it deploy-authors-nodejs.cfg
Enter the complete Cloudant URL (can be found under Credentials for the Cloudant Service in the IBM Cloud Console)
Dont forget to enclose the URL in " "

Then run the script deploy-authors-nodejs.sh
Note: Minikube must be started and ready!

If you run it for the first time in your environment you will see errors when the script tries to delete a previous deployment. This is normal!