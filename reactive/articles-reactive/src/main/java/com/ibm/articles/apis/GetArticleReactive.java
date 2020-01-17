package com.ibm.articles.apis;

import javax.enterprise.context.RequestScoped;
import javax.inject.Inject;
import javax.ws.rs.PathParam;
import javax.ws.rs.Path;
import javax.ws.rs.GET;
import javax.ws.rs.core.Response;

import com.ibm.articles.business.ArticleService;
import org.eclipse.microprofile.openapi.annotations.Operation;
import org.eclipse.microprofile.openapi.annotations.enums.SchemaType;
import org.eclipse.microprofile.openapi.annotations.responses.APIResponses;
import com.ibm.articles.business.Article;
import com.ibm.articles.business.ArticleDoesNotExist;
import org.eclipse.microprofile.openapi.annotations.responses.APIResponse;
import org.eclipse.microprofile.openapi.annotations.media.Content;
import org.eclipse.microprofile.openapi.annotations.media.Schema;
import org.eclipse.microprofile.openapi.annotations.parameters.Parameter;
import java.util.concurrent.CompletableFuture;
import java.util.concurrent.CompletionStage;

@RequestScoped
@Path("/v2") // asynchronous
public class GetArticleReactive {

	@Inject
	ArticleAsJson articleAsJson;
	
	@Inject
    ArticleService articleService;

	@GET
	@Path("/articles/{id}")
	@APIResponses(value = {
		@APIResponse(
	      responseCode = "204",
	      description = "Article Not Found"
	    ),
	    @APIResponse(
	      responseCode = "200",
	      description = "Article with requested id",
	      content = @Content(
	        mediaType = "application/json",
	        schema = @Schema(implementation = Article.class)
	      )
	    ),
	    @APIResponse(
	      responseCode = "500",
	      description = "Internal service error"  	      
	    )
	})
	@Operation(
		    summary = "Get specific article (reactive)",
		    description = "Get specific article"
	)
	public CompletionStage<Response> getArticleReactive(@Parameter(
            description = "The unique id of the article",
            required = true,
            example = "1551176445313",
            schema = @Schema(type = SchemaType.STRING))
			@PathParam("id") String id) {
		System.out.println("com.ibm.articles.apis.GetArticleReactive.getArticleReactive");
		CompletableFuture<Response> future = new CompletableFuture<>();

		articleService.getArticleReactive(id).thenApply(article -> {
			return Response.ok(articleAsJson.createJson(article)).build();
		}).exceptionally(throwable -> {  
            if (throwable.getCause().toString().equals(ArticleDoesNotExist.class.getName().toString())) {
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