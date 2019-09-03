# Hands-on Part of Workshop

This page summarizes the steps of the workshop.

## Step 1

[Get an IBM Cloud account](https://ibm.biz/Bd2JHx) and enter promocode

## Step 2

[Install ibmcloud CLI](https://cloud.ibm.com/docs/cli/reference/bluemix_cli?topic=cloud-cli-install-ibmcloud-cli#shell_install)

```
$ ibmcloud plugin install container-service
$ ibmcloud plugin install container-registry
```

## Step 3

Get an API key

```
$ ibmcloud login -a https://cloud.ibm.com -r us-south -g default
$ ibmcloud iam api-key-create cloud-native-starter-key \
  -d "This is the cloud-native-starter key to access the IBM Platform" \
  --file cloud-native-starter-key.json
$ cat cloud-native-starter-key.json
```

## Step 4 

Create local.env

```
$ cp template.local.env local.env
```

* Paste the API key
* Change the row 'REGISTRY_NAMESPACE=cloud-native-yourname'

## Step 5

Create cluster

```
$ git clone https://github.com/IBM/cloud-native-starter.git
$ cd cloud-native-starter
$ ./iks-scripts/create-iks-cluster.sh
```



