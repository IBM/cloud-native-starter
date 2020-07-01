package com.ibm.webapi;

import com.ibm.webapi.CoreArticle;
import com.ibm.webapi.InvalidArticle;
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
    //private static final String ARTICLES_DNS = "articles-secure";
    private static final String ARTICLES_DNS = "localhost";
    private static final int ARTICLES_PORT = 8082;

    private String articlesHost = ARTICLES_DNS;
    private int articlesPort = ARTICLES_PORT;

    private ArticlesService articlesService;

    //@ConfigProperty(name = "cloud-native-starter.local")
    //boolean localMode;

    //@ConfigProperty(name = "cloud-native-starter.minikube.ip")
    //String minikubeIp;

    //@ConfigProperty(name = "cloud-native-starter.articles.port", defaultValue = "8080")
    //int articlesLocalPort;

    @PostConstruct
    void initialize() {
      /*  if (localMode) {
            articlesHost = minikubeIp;
            articlesPort = articlesLocalPort;
        }
*/
        URI apiV1 = UriBuilder.fromUri("http://{host}:{port}/articles").build(articlesHost, articlesPort);
        articlesService = RestClientBuilder.newBuilder()
                .baseUri(apiV1)
                .register(ExceptionMapperArticles.class)
                .build(ArticlesService.class);

        
    }

    public List<CoreArticle> getArticles(int amount) throws NoConnectivity {
        try {
            return articlesService.getArticlesFromService(amount);
        } catch (Exception e) {
            throw new NoConnectivity(e);
        }
    }

   

}
