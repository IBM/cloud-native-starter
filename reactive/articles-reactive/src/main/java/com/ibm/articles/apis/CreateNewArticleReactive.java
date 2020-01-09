package com.ibm.articles.apis;

import javax.inject.Inject;
import javax.ws.rs.*;
import javax.ws.rs.core.MediaType;
import javax.ws.rs.core.Response;
import org.eclipse.microprofile.openapi.annotations.Operation;
import org.eclipse.microprofile.openapi.annotations.responses.APIResponses;
import com.ibm.articles.business.Article;
import com.ibm.articles.business.InvalidArticle;
import org.eclipse.microprofile.openapi.annotations.responses.APIResponse;
import org.eclipse.microprofile.openapi.annotations.media.Content;
import org.eclipse.microprofile.openapi.annotations.media.Schema;
import org.eclipse.microprofile.openapi.annotations.parameters.RequestBody;
import javax.enterprise.context.ApplicationScoped;
import java.util.concurrent.CompletableFuture;
import java.util.concurrent.CompletionStage;

@ApplicationScoped
@Path("/v2") // asynchronous
public class CreateNewArticleReactive {

	@Inject
	ArticleAsJson articleAsJson;
	
	@Inject 
	com.ibm.articles.business.CoreService coreService;

	@POST
	@Path("/articles")
	@Produces(MediaType.APPLICATION_JSON)
	@Consumes(MediaType.APPLICATION_JSON)
	@APIResponses(value = {
		@APIResponse(
	      responseCode = "204",
	      description = "Input not valid (no title)"
	    ),
	    @APIResponse(
	      responseCode = "201",
	      description = "Article has been created",
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
		    summary = "Create a new article (reactive)",
		    description = "Create a new article"
	)
	public CompletionStage<Response> addArticleReactive(@RequestBody(description = "New article", required = true,
            content = @Content(schema = @Schema(implementation = Article.class))) Article newArticle) {
		System.out.println("com.ibm.articles.apis.CreateNewArticleReactive.addArticleReactive");
		CompletableFuture<Response> future = new CompletableFuture<>();

		String title = newArticle.title;
		String url = newArticle.url;
		String author = newArticle.author;
	
		coreService.addArticleReactive(title, url, author).thenApply(article -> {
			return Response.status(Response.Status.CREATED).entity(articleAsJson.createJson(article)).build();
		}).exceptionally(throwable -> {  
            if (throwable.getCause().toString().equals(InvalidArticle.class.getName().toString())) {
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