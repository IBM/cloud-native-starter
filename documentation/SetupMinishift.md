##Running the Cloud Native Starter on OKD (OpenShift)

For this environment we will use Minishift. Similar to Minikube it runs Kubernetes as a single node cluster in a VM, for example Virtualbox. Minishift uses the Origin Community Distribution of Kubernetes (OKD, okd.io) which is the basis for Red Hats OpenShift.

To use Minishift, you must be able to reserve at least 4 CPUs (or to be exact 4 CPU threads on an Intel CPU) and 8 GB of RAM. Minishift and specifically Istio on Minishift will not work with less resources, you would be wasting your time! 

### 1. Get Minishift

Like `minikube`, `minishift` first of all is a CLI. Instructions for download and installation can be found [here](
https://docs.okd.io/latest/minishift/getting-started/installing.html).

Download the version that corresponds to your OS, unpack it, then add `minishift` to your PATH. To test if it works, run

```
$ minishift version
```

### 2. Create a Minishift cluster 

These instructions are mainly based on Kamesh Sampath's blog ["3 steps to your Istio Installation on Kubernetes"](https://medium.com/@kamesh_sampath/3-steps-to-your-istio-installation-on-openshift-58e3617828b0).

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

Pinning OpenShift version to be 3.10.0 (required by Minishift Istio Addon):

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

Start the profile:

```
$ minishift start
```

Setup will take somewhere between 10 and 20 minutes. 

After the setup is complete and Minishift is started, you are logged in as user `developer` in the command line.

### 3. oc

`oc` is the OpenShift CLI, it is required to interact with the OpenShift (OKD) cluster. The Minishift cluster setup we just performed placed a copy of `oc`into the directory `~/.minishift/cache/oc/v3.10.0/xxx`. Either add this directory to your PATH or copy `oc`into a directory in your PATH.

Check if it works with

```
$ oc version
```

### 4. OpenShift Dashboard or Console

To access the graphical dashboard or console run:

```
$ minishift console
```

Login as user 'developer' with password 'developer'.

'developer' has no admin rights and profile 'system:admin' cannot login to the dashboard. To gain full access to the dashboard go back to the command line and run these commands:

```
$ oc login -u system:admin
$ oc adm policy add-cluster-role-to-user cluster-admin admin
$ oc login -u admin -p admin
```

Now logout from the dashboard and re-login as user 'admin' with password 'admin'.

### 5. Install Istio

We are installating Istio as a Minishift add-on. It uses a Kubernetes Operator and is based on [Maistra](https://maistra.io/). It results in an older Istio version (1.0.2) but is well integrated into Minishift.

Installation is quite simple:

```
$ git clone https://github.com/minishift/minishift-addons
$ minishift addon install ./minishift-addons/add-ons/istio
$ minishift addon enable istio
$ minishift addon apply istio 
```

Installation will take some time, check the status of the Istio pods with:

```
$ watch oc get pods -n istio-system
```
If installation finished successful it should look like this:

![Istio is installed](../images/minishift-istio.png)

There were a couple of instructions displayed at the end of the cluster setup. Ignore the instructions for admin-user and anyuid, we have enabled those when we created the Minishift cluster.

But **enter these commands** ([Background](https://maistra.io/docs/getting_started/application-requirements/)):

```
$ oc adm policy add-scc-to-user anyuid -z default -n myproject
$ oc adm policy add-scc-to-user privileged -z default -n myproject
```

Should you decide to create the Cloud Native Starter in its own OpenShift project, you have to issue these commands for that project, too!

Now open the OpenShift dashboard (`minishift console`), login as admin/admin, open the 'istio-system' project (you may need to click on "View All" to see it), then search for application "Kiali".

Click on the route for Kiali, it looks like 'https://kiali-istio-system.192.168.99.100.nip.io'. This will open the Kiali console. Log into Kiali with user 'admin' and password 'admin'.

**One more step to do.** Our Cloud Native Starter demo does not currently use mTLS but the Maistra based Istio we just installed uses mTLS per default. As long as we haven't updated our sample for mTLS, any application of Istio DestinationRules to your Istio configuration will result in 503 Upstream Errors. To disable mTLS on the "myproject" project (or the myproject namespace to be precise), create a no-mtls.yaml file with the following content:

```
apiVersion: "authentication.istio.io/v1alpha1"
kind: "Policy"
metadata:
  name: "default"
  namespace: "myproject"
spec:
  peers:
    - mtls:
        mode: PERMISSIVE
```

AFAIK, the name must be "default".

Apply the policy with 

```
$ oc apply -f no-mtls.yaml
```


(The following has yet to be tested:)
#### Configuring an Application to Utilize Automatic Sidecar Injection
https://maistra.io/docs/getting_started/application-requirements/

