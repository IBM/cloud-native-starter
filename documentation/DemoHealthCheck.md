## Demo: Health Check

When running cloud-native applications in the orchestration framework Kubernetes and the service mesh Istio, microservices need to report whether they are ready and live. Kubernetes needs to know this to restart containers if necessary. Istio needs to know this information to define where to route requests to.

With the Kubernetes livenessProbe it is determined whether, as the name indicates, the pod is live. Pods that are live might not be ready though, for example when they just started and still need to load data. That's why there is a second readinessProbe.

Here is the [Java code](../articles-java-jee/src/main/java/com/ibm/articles/apis/HealthEndpoint.java) which returns for the 'articles' service that the microservice is ready. 

```
import org.eclipse.microprofile.health.Health;
import org.eclipse.microprofile.health.HealthCheck;
import org.eclipse.microprofile.health.HealthCheckResponse;
import javax.enterprise.context.ApplicationScoped;

@Health
@ApplicationScoped
public class HealthEndpoint implements HealthCheck {

    @Override
    public HealthCheckResponse call() {
        return HealthCheckResponse.named("articles").withData("articles", "ok").up().build();
    }
}
```

In the Kubernetes [yaml file](../articles-java-jee/deployment/kubernetes.yaml) the URLs of the livenessProbe and the readinessProbe are defined.

```
kind: Deployment
apiVersion: apps/v1beta1
metadata:
  name: articles
spec:
  replicas: 1
  template:
    metadata:
      labels:
        app: articles
        version: v1
    spec:
      containers:
      - name: articles
        image: articles:1
        ports:
        - containerPort: 8080
        livenessProbe:
          exec:
            command: ["sh", "-c", "curl -s http://localhost:8080/"]
          initialDelaySeconds: 20
        readinessProbe:
          exec:
            command: ["sh", "-c", "curl -s http://localhost:8080/health | grep -q articles"]
          initialDelaySeconds: 40
      restartPolicy: Always
```

Invoke the following commands to set up the demo. Skip the commands you've already executed.

```
$ cd $PROJECT_HOME
$ scripts/check-prerequisites.sh
$ scripts/delete-all.sh
$ scripts/deploy-articles-java-jee.sh
$ kubectl get pods --watch
$ minikube dashboard
```

Check in the Minikube Dashboard whether the 'articles' pod is running.

Check out the article [Implementing Health Checks with MicroProfile and Istio](http://heidloff.net/article/implementing-health-checks-microprofile-istio/) for more details.