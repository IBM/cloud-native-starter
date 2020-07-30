package com.ibm.webapi;

import org.eclipse.microprofile.rest.client.RestClientBuilder;
import javax.annotation.PostConstruct;
import javax.enterprise.context.ApplicationScoped;
import javax.ws.rs.core.UriBuilder;
import java.net.URI;
import java.util.List;

@ApplicationScoped
public class ArticlesDataAccess {

# Comment out to build the image for deploymant on K8s
    private static final String ARTICLES_DNS = "localhost";
# Modified statement for K8s deloyment, service must be called by its name then
#    private static final String ARTICLES_DNS = "articles";
    private static final int ARTICLES_PORT = 8082;

    private String articlesHost = ARTICLES_DNS;
    private int articlesPort = ARTICLES_PORT;

	private ArticlesService articlesService;

    @PostConstruct
    void initialize() {
        URI apiV1 = UriBuilder.fromUri("http://{host}:{port}/articles").build(articlesHost, articlesPort);
        
        articlesService = RestClientBuilder.newBuilder()
                .baseUri(apiV1)
                .register(ExceptionMapperArticles.class)
                .build(ArticlesService.class);
        
    }

    public List<CoreArticle> getArticles(String authorization, int amount) throws NoConnectivity {
        try {
            return articlesService.getArticlesFromService(authorization, amount);
        } catch (Exception e) {
            throw new NoConnectivity(e);
        }
    }

    /*
    public List<CoreArticle> getArticles(int amount) throws NoConnectivity {
        try {
            return articlesService.getArticlesFromService(amount);
        } catch (Exception e) {
            throw new NoConnectivity(e);
        }
    } 
    */
}
