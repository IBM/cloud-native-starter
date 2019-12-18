## Work in Progress

**1. Install Minikube**

See the [instructions](https://kubernetes.io/docs/tasks/tools/install-minikube/).

**2. Get the code**

```
$ git clone https://github.com/IBM/cloud-native-starter.git
$ cd cloud-native-starter/reactive
$ ROOT_FOLDER=$(pwd)
```

**3. Install prerequisites**

```
$ cd ${ROOT_FOLDER}
$ scripts/check-prerequisites.sh
```

**4. Start Minikube and install Kafka**

```
$ cd ${ROOT_FOLDER}
$ scripts/start-minikube.sh
$ scripts/deploy-kafka.sh
```

**5. Deploy and run the sample in Minikube**

```
$ cd ${ROOT_FOLDER}
$ scripts/deploy-articles-reactive.sh
$ scripts/deploy-web-api-reactive.sh
$ scripts/deploy-web-app-reactive.sh
$ scripts/show-urls.sh
```

Create a new article either via the API explorer or curl. Open either the web application or only the stream endpoint in a browser. See the output of 'show-urls.sh' for the URLs.

**Optional: Run the sample locally**

You can run single services locally, but there are some restrictions:

* Kafka always run in Minikube
* Only one of the services can be run locally at the same time since they all use the same port
* When running the articles or the web-api service locally, the web application doesn't work
* When running the web-api service locally, the messaging works, but not the REST invocations

Here is an example how to run the web-api service locally:

*First terminal*

```
$ cd ${ROOT_FOLDER}
$ scripts/deploy-articles-reactive.sh
$ scripts/run-locally-web-api-reactive.sh
```

*Browser*

Open the stream endpoint in a browser.

*Second terminal*

```
$ cd ${ROOT_FOLDER}
$ scripts/show-urls.sh
$ curl -X POST "http://localhost:8080/v1/create" ...
```