package com.ibm.articles.apis;

import javax.inject.Inject;
import javax.ws.rs.QueryParam;
import javax.ws.rs.Path;
import javax.ws.rs.GET;
import javax.ws.rs.Produces;
import javax.ws.rs.core.MediaType;
import io.vertx.axle.core.Vertx;
import java.util.concurrent.CompletableFuture;
import java.util.concurrent.CompletionStage;
import javax.enterprise.context.ApplicationScoped;
import javax.json.JsonArray;
import javax.json.stream.JsonCollectors;

@ApplicationScoped
@Path("/v2")
public class GetArticlesReactive {

	@Inject
	ArticleAsJson articleAsJson;
	
	@Inject 
	com.ibm.articles.business.CoreService coreService;

	@Inject
    Vertx vertx;

	@GET
	@Path("/articles")
	@Produces(MediaType.APPLICATION_JSON)
    public CompletionStage<JsonArray> getArticlesReactive(@QueryParam("amount") int amount) {
        CompletableFuture<JsonArray> future = new CompletableFuture<>();

        coreService.getArticlesReactive(amount).thenApplyAsync(articles -> {
            JsonArray jsonArray = articles.stream()
                .map(article -> articleAsJson.createJson(article))
                .collect(JsonCollectors.toJsonArray());            
            return jsonArray;
        }).whenComplete((jsonArray, th) -> {
            future.complete(jsonArray);          
        });

        return future;
    }

}
