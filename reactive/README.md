## Work in Progress

**Install Minikube**

[Instructions](https://kubernetes.io/docs/tasks/tools/install-minikube/).

**1. Get the code**

```
$ git clone https://github.com/IBM/cloud-native-starter.git
$ cd cloud-native-starter/reactive
$ ROOT_FOLDER=$(pwd)
```

**2. Install prerequisites**

```
$ cd ${ROOT_FOLDER}
$ scripts/check-prerequisites.sh
```

**3. Start Minikube and install Kafka**

```
$ cd ${ROOT_FOLDER}
$ scripts/start-minikube.sh
$ scripts/deploy-kafka.sh
```

**4. Deploy and run the sample in Minikube**

```
$ cd ${ROOT_FOLDER}
$ scripts/deploy-articles-reactive.sh
$ scripts/deploy-web-api-reactive.sh
```

Create a new article either via the API explorer or curl. Open the stream endpoint in a browser.

**Optional: Run the sample locally**

First terminal: 

```
$ cd ${ROOT_FOLDER}
$ scripts/run-locally-articles-reactive.sh
```

Second terminal: 

```
$ cd ${ROOT_FOLDER}
$ scripts/run-locally-web-api-reactive.sh
```

Third terminal: Create a new article. 

```
$ cd ${ROOT_FOLDER}
$ scripts/show-urls.sh
$ curl -X POST "http://localhost:8080/v1/create" ...
```

Browser: Open the stream endpoint in a browser.


