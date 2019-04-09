## Demo: Configuration

In order to demonstrate [MicroProfile Config](https://microprofile.io/project/eclipse/microprofile-config), the 'articles' service uses an environment variable to define whether or not to create ten articles the first time it is invoked.

Invoke the following commands to set up the demo. Skip the commands you've already executed.

```
$ cd $PROJECT_HOME
$ scripts/check-prerequisites.sh
$ scripts/delete-all.sh
$ scripts/deploy-articles-java-jee.sh
$ scripts/show-urls.sh
```

Invoke the curl command is displayed as output of 'scripts/show-urls.sh' to get ten articles.

Check out the article [Configuring Microservices with MicroProfile and Kubernetes](http://heidloff.net/article/configuring-java-microservices-microprofile-kubernetes/) for more details.


