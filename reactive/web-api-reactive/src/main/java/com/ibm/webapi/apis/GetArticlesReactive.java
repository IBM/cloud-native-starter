package com.ibm.webapi.apis;

import javax.inject.Inject;
import javax.json.JsonArray;
import javax.json.stream.JsonCollectors;
import javax.ws.rs.core.MediaType;
import javax.ws.rs.core.Response;
import org.eclipse.microprofile.openapi.annotations.Operation;
import org.eclipse.microprofile.openapi.annotations.enums.SchemaType;
import org.eclipse.microprofile.openapi.annotations.responses.APIResponses;
import com.ibm.webapi.business.Article;
import org.eclipse.microprofile.openapi.annotations.responses.APIResponse;
import org.eclipse.microprofile.openapi.annotations.media.Content;
import org.eclipse.microprofile.openapi.annotations.media.Schema;
import javax.ws.rs.Path;
import javax.ws.rs.GET;
import javax.ws.rs.Produces;
import java.util.concurrent.CompletableFuture;
import java.util.concurrent.CompletionStage;
import javax.enterprise.context.ApplicationScoped;

@ApplicationScoped
@Path("/v2")
public class GetArticlesReactive {

	@Inject
	com.ibm.webapi.business.Service service;
	
	@Inject
	ArticleAsJson articleAsJson;

	@GET
	@Path("/articles")
	@Produces(MediaType.APPLICATION_JSON)
	@APIResponses(value = {
			@APIResponse(responseCode = "200", description = "Get most recently added articles", content = @Content(mediaType = "application/json", schema = @Schema(type = SchemaType.ARRAY, implementation = Article.class))),			
			@APIResponse(responseCode = "500", description = "Internal service error") })
	@Operation(summary = "Get most recently added articles (reactive)", description = "Get most recently added articles")
	public CompletionStage<Response> getArticles() {
		System.out.println("com.ibm.web-api.apis.GetArticlesReactive.getArticlesReactive");
		CompletableFuture<Response> future = new CompletableFuture<>();

		service.getArticlesReactive().thenApplyAsync(articles -> {
            JsonArray jsonArray = articles.stream()
                .map(article -> articleAsJson.createJsonArticle(article))
                .collect(JsonCollectors.toJsonArray());            
            return jsonArray;
        }).thenApplyAsync(jsonArray -> {            
            return Response.ok(jsonArray).build();
        }).exceptionally(throwable -> {  
            return Response.status(Response.Status.INTERNAL_SERVER_ERROR).build();
        }).whenComplete((response, throwable) -> {
            future.complete(response);          
        });

        return future;
	}
}
