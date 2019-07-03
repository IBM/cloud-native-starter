## Setup Minishift manually


These are the instructions that the script `minishift-scripts/setup-minishift.sh` performs. Use them if you want to setup Minishift manually.

Create a profile called "istio":

```
$ minishift profile set istio
```

Use Virtualbox (see other [choices](https://docs.okd.io/latest/minishift/getting-started/setting-up-virtualization-environment.html))

```
$ minishift config set vm-driver virtualbox
```

Give the profile at least 8GB of memory, this is the minimum, the more the better:

```
$ minishift config set memory 8GB 
```

Give the profile at least 4 CPUs:

```
$ minishift config set cpus 4
```

Adding container image caching to allow faster profile setup:

```
$ minishift config set image-caching true 
```

Pinning OpenShift version to be 3.10.0:

```
$ minishift config set openshift-version v3.10.0
``` 

Add a user with cluster-admin role:

```
$ minishift addon enable admin-user
```

Allows to run containers with uid 0 on Openshift:

```
$ minishift addon enable anyuid
```

Enable Admissions Webhooks (required for Istio Sidecar injection, see [here](https://istio.io/docs/setup/kubernetes/platform-setup/openshift/)):

```
$ minishift addon enable admissions-webhook
```

Start the profile:

```
$ minishift start
```

Setup will take somewhere between 10 and 20 minutes. 

After the setup is complete and Minishift is started, you are logged in as user `developer` in the command line.