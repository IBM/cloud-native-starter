## Work in Progress

**Install Minikube**

[Instructions](https://kubernetes.io/docs/tasks/tools/install-minikube/).

**Get the code**

```
$ git clone https://github.com/IBM/cloud-native-starter.git
$ cd cloud-native-starter/reactive
$ ROOT_FOLDER=$(pwd)
```

**Install prerequisites**

```
$ cd ${ROOT_FOLDER}
$ scripts/check-prerequisites.sh
```

**Start Minikube and install Kafka**

```
$ cd ${ROOT_FOLDER}
$ scripts/start-minikube.sh
$ scripts/deploy-kafka.sh
```

**Run the sample locally**

```
$ cd ${ROOT_FOLDER}
$ scripts/run-locally-articles-reactive.sh
```

In a separate terminal create a new article. You will see some log statements in the first terminal.

```
$ cd ${ROOT_FOLDER}
$ scripts/show-urls.sh
$ curl -X POST "http://localhost:8080/v1/create" ...
```

**Deploy and run the sample in Minikube**

```
$ cd ${ROOT_FOLDER}
$ scripts/deploy-articles-reactive.sh
```

Create a new article either via the API explorer or curl. You can find log statements in the logs, for example via the Minikube dashboard.

