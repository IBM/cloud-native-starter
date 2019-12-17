## Work in Progress

**1. Install Minikube**

[Instructions](https://kubernetes.io/docs/tasks/tools/install-minikube/).

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
$ scripts/show-urls.sh
```

Create a new article either via the API explorer or curl. Open the stream endpoint in a browser. See the output of 'show-urls.sh' for the URLs.

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


