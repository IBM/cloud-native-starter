## Demo: Cloudant (Persistence in NoSQL DB)

The authors service retrieves the author information from a [JSON file](../authors-nodejs/authordata.json) in memory per default. This is set in the [local.env](../local.env) file with the variable:

```
AUTHORS_DB=local    
```

As an alternative a NoSQL database can be used for data persistence. This sample shows how to use the 'Cloudant' database service on IBM Cloud which is based on Apache CouchDB.

Before running the scripts below, make sure you can [access the IBM Cloud](SetupIBMCloudAccess.md). 

**Create a new Cloudant service instance**

Run the following command to create a new Cloudant service instance:


```
$ ibm-scripts/create-cloudant.sh
```

This command will modify the [local.env](../local.env) file and set the variables:

```
AUTHORS_DB=cloud
CLOUDANT_URL=https://XXX:YYY@ZZZ.cloudantnosqldb.appdomain.cloud
```

**Open the Cloudant Dashboard and modify a database entry**

The script preloads the Cloudant database with the entries from the JSON file that is used as local database. To notice a difference when using the Cloudant database we modify a database entry.

* Login to the [IBM Cloud](https://cloud.ibm.com) dashboard
* On the dashboard, in the "Resource Summary", select "Services"
* The Resource list is displayed, with the "Services" area opened

<kbd><img src="../images/cloudant-demo-1.png" /></kbd>

* Click on the name "cloudant-cloud-native-starter", this opens the details page
* Click on the "Launch Cloudant Dashboard" button in the upper right
* This opens the Databases view of your Cloudant instance:
* Click on "authors"
* Then open "authorview" and "views", click on "data_by_name":

<kbd><img src="../images/cloudant-demo-2.png" /></kbd>

* These are the 4 authors that are preloaded in the authors database.
* Click on one the first entry, "Harald Uebele"

<kbd><img src="../images/cloudant-demo-3.png" /></kbd>

* Change the Twitter handle from all lower case to all upper case ("@HARALD_U")
* Then click on "Save Changes"

**Setup the demo**

Invoke the following commands to set up the demo: 

```
$ cd $PROJECT_HOME
$ scripts/check-prerequisites.sh
$ scripts/delete-all.sh
$ scripts/deploy-authors-nodejs.sh
$ scripts/show-urls.sh
```
**Run the demo**

The show-urls.sh script shows the URL for the authors service:

<kbd><img src="../images/cloudant-demo-4.png" /></kbd>

Execute the following command:

```
$ curl http://192.168.99.100:30680/api/v1/getauthor?name=Harald%20Uebele
```

In the result you can see that the Twitter handle is all upper case, the data was retrieved from Cloudant:

<kbd><img src="../images/cloudant-demo-5.png" /></kbd>



