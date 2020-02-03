package com.ibm.webapi.data;

import com.ibm.webapi.business.Author;
import com.ibm.webapi.business.NonexistentAuthor;
import io.vertx.axle.core.Vertx;
import io.vertx.axle.core.buffer.Buffer;
import io.vertx.axle.ext.web.client.HttpResponse;
import io.vertx.axle.ext.web.client.WebClient;
import io.vertx.ext.web.client.WebClientOptions;
import org.eclipse.microprofile.config.inject.ConfigProperty;
import org.eclipse.microprofile.rest.client.RestClientBuilder;

import javax.annotation.PostConstruct;
import javax.enterprise.context.ApplicationScoped;
import javax.inject.Inject;
import javax.ws.rs.core.UriBuilder;
import java.net.URI;
import java.util.concurrent.CompletionStage;

@ApplicationScoped
public class AuthorsDataAccess {

    private static final int MAXIMAL_DURATION = 5000;
    private static final String AUTHORS_DNS = "authors";
    private static final int AUTHORS_PORT = 3000;

    private String authorsHost = AUTHORS_DNS;
    private int authorsPort = AUTHORS_PORT;

    @ConfigProperty(name = "cloud-native-starter.local")
    String localMode;

    @ConfigProperty(name = "cloud-native-starter.minikube.ip")
    String minikubeIp;

    @ConfigProperty(name = "cloud-native-starter.authors.port", defaultValue = "3000")
    int authorsLocalPort;

    @Inject
    Vertx vertx;

    private WebClient reactiveClient;
    private AuthorsService authorsService;

    @PostConstruct
    void initialize() {
        if (localMode.equalsIgnoreCase("true")) {
            authorsHost = minikubeIp;
            authorsPort = authorsLocalPort;
        }

        URI authorsUri = UriBuilder.fromUri("http://{host}:{port}/api/v1/getauthor").build(authorsHost, authorsPort);
        authorsService = RestClientBuilder.newBuilder()
                .baseUri(authorsUri)
                .register(ExceptionMapperAuthors.class)
                .build(AuthorsService.class);

        WebClientOptions options = new WebClientOptions()
                .setDefaultHost(authorsHost)
                .setDefaultPort(authorsPort)
                .setSsl(false);
        reactiveClient = WebClient.create(vertx, options);
    }

    public Author getAuthor(String name) throws NoConnectivity, NonexistentAuthor {
        try {
            System.out.println("fetching author: " + name);

            return authorsService.getAuthor(name);
        } catch (NonexistentAuthor e) {
            e.printStackTrace();
            throw new NonexistentAuthor(e);
        } catch (Exception e) {
            throw new NoConnectivity(e);
        }
    }

    public CompletionStage<Author> getAuthorReactive(String name) {
        return reactiveClient.get("/api/v1/getauthor").addQueryParam("name", name)
                .timeout(MAXIMAL_DURATION)
                .send()
                .thenApply(this::readAuthor);
    }

    private Author readAuthor(HttpResponse<Buffer> resp) {
        if (resp.statusCode() == 200)
            return convertJsonToAuthor(resp.bodyAsJsonObject());

        if (resp.statusCode() == 204)
            throw new NonexistentAuthor();
        throw new NoConnectivity();
    }

    private Author convertJsonToAuthor(io.vertx.core.json.JsonObject jsonObject) {
        Author author = new Author();
        author.blog = jsonObject.getString("blog", "");
        author.name = jsonObject.getString("name", "");
        author.twitter = jsonObject.getString("twitter", "");
        return author;
    }

}