package com.ibm.articles.apis;

import javax.inject.Inject;
import javax.ws.rs.QueryParam;
import javax.ws.rs.Path;
import javax.ws.rs.GET;
import javax.ws.rs.Produces;
import javax.ws.rs.core.MediaType;
import javax.ws.rs.core.Response;
import java.util.concurrent.CompletableFuture;
import java.util.concurrent.CompletionStage;
import javax.enterprise.context.ApplicationScoped;
import javax.json.JsonArray;
import javax.json.stream.JsonCollectors;

import com.ibm.articles.business.ArticleService;
import org.eclipse.microprofile.openapi.annotations.Operation;
import org.eclipse.microprofile.openapi.annotations.enums.SchemaType;
import org.eclipse.microprofile.openapi.annotations.responses.APIResponses;
import com.ibm.articles.business.Article;
import com.ibm.articles.business.InvalidInputParameter;
import org.eclipse.microprofile.openapi.annotations.responses.APIResponse;
import org.eclipse.microprofile.openapi.annotations.media.Content;
import org.eclipse.microprofile.openapi.annotations.media.Schema;
import org.eclipse.microprofile.openapi.annotations.parameters.Parameter;

@ApplicationScoped
@Path("/v2") // asynchronous
public class GetArticlesReactive {

	@Inject
	ArticleAsJson articleAsJson;
	
	@Inject
    ArticleService articleService;

	@GET
	@Path("/articles")
    @Produces(MediaType.APPLICATION_JSON)
	@APIResponses(value = {
			@APIResponse(responseCode = "200", description = "Get most recently added articles", content = @Content(mediaType = "application/json", schema = @Schema(type = SchemaType.ARRAY, implementation = Article.class))),
			@APIResponse(responseCode = "204", description = "Input not valid (no valid amount)"),
			@APIResponse(responseCode = "500", description = "Internal service error") })
	@Operation(summary = "Get most recently added articles (reactive)", description = "Get most recently added articles")	
    public CompletionStage<Response> getArticlesReactive(
            @Parameter(description = "The amount of articles", required = true, example = "10", schema = @Schema(type = SchemaType.INTEGER)) 
            @QueryParam("amount") int amount) {
        System.out.println("com.ibm.articles.apis.GetArticlesReactive.getArticlesReactive");
        CompletableFuture<Response> future = new CompletableFuture<>();

        articleService.getArticlesReactive(amount).thenApply(articles -> {
            JsonArray jsonArray = articles.stream()
                .map(article -> articleAsJson.createJson(article))
                .collect(JsonCollectors.toJsonArray());            
            return jsonArray;
        }).thenApply(jsonArray -> {            
            return Response.ok(jsonArray).build();
        }).exceptionally(throwable -> {  
            if (throwable.getCause().toString().equals(InvalidInputParameter.class.getName().toString())) {
                return Response.status(Response.Status.NO_CONTENT).build();
            }
            else {            
                return Response.status(Response.Status.INTERNAL_SERVER_ERROR).build();
            }
        }).whenComplete((response, throwable) -> {
            future.complete(response);          
        });

        return future;
    }

}
