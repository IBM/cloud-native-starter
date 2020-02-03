package com.ibm.webapi.data;

import com.ibm.webapi.business.CoreArticle;
import com.ibm.webapi.business.InvalidArticle;
import org.eclipse.microprofile.config.inject.ConfigProperty;
import org.eclipse.microprofile.rest.client.RestClientBuilder;

import javax.annotation.PostConstruct;
import javax.enterprise.context.ApplicationScoped;
import javax.ws.rs.core.UriBuilder;
import java.net.URI;
import java.util.List;
import java.util.concurrent.CompletionStage;
import java.util.concurrent.TimeUnit;

@ApplicationScoped
public class ArticlesDataAccess {

    private static final int MAXIMAL_DURATION = 5000;
    private static final String ARTICLES_DNS = "articles-reactive";
    private static final int ARTICLES_PORT = 8080;

    private String articlesHost = ARTICLES_DNS;
    private int articlesPort = ARTICLES_PORT;

    private ArticlesService articlesService;
    private ArticlesServiceReactive articlesServiceReactive;

    @ConfigProperty(name = "cloud-native-starter.local")
    String localMode;

    @ConfigProperty(name = "cloud-native-starter.minikube.ip")
    String minikubeIp;

    @ConfigProperty(name = "cloud-native-starter.articles.port", defaultValue = "8080")
    int articlesLocalPort;

    @PostConstruct
    void initialize() {
        if (localMode.equalsIgnoreCase("true")) {
            articlesHost = minikubeIp;
            articlesPort = articlesLocalPort;
        }

        URI apiV1 = UriBuilder.fromUri("http://{host}:{port}/v1/articles").build(articlesHost, articlesPort);
        articlesService = RestClientBuilder.newBuilder()
                .baseUri(apiV1)
                .register(ExceptionMapperArticles.class)
                .build(ArticlesService.class);

        URI apiV2 = UriBuilder.fromUri("http://{host}:{port}/v2/articles").build(articlesHost, articlesPort);
        articlesServiceReactive = RestClientBuilder.newBuilder()
                .baseUri(apiV2)
                .register(ExceptionMapperArticles.class)
                .build(ArticlesServiceReactive.class);
    }

    public List<CoreArticle> getArticles(int amount) throws NoConnectivity {
        try {
            return articlesService.getArticlesFromService(amount);
        } catch (Exception e) {
            throw new NoConnectivity(e);
        }
    }

    public CompletionStage<List<CoreArticle>> getArticlesReactive(int amount) {
        return articlesServiceReactive.getArticlesFromService(amount)
                .toCompletableFuture()
                .orTimeout(MAXIMAL_DURATION, TimeUnit.MILLISECONDS);
    }

    public CoreArticle addArticle(CoreArticle article) throws NoConnectivity, InvalidArticle {
        try {
            return articlesService.addArticle(article);
        } catch (InvalidArticle e) {
            e.printStackTrace();
            throw new InvalidArticle(e);
        } catch (Exception e) {
            throw new NoConnectivity(e);
        }
    }

}
