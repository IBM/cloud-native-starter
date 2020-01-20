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
import com.ibm.articles.business.NoDataAccess;
import org.eclipse.microprofile.openapi.annotations.responses.APIResponse;
import org.eclipse.microprofile.openapi.annotations.media.Content;
import org.eclipse.microprofile.openapi.annotations.media.Schema;
import org.eclipse.microprofile.openapi.annotations.parameters.Parameter;

@RequestScoped
@Path("/v1") // synchronous
public class GetArticle {

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
		    summary = "Get specific article",
		    description = "Get specific article"
	)
	public Response getArticle(@Parameter(
            description = "The unique id of the article",
            required = true,
            example = "1551176445313",
            schema = @Schema(type = SchemaType.STRING))
			@PathParam("id") String id) {
		System.out.println("com.ibm.articles.apis.GetArticle.getArticle");

		Article article;
		try {
			article = articleService.getArticle(id);
			return Response.ok(articleAsJson.createJson(article)).build();
		} catch (ArticleDoesNotExist exception) {
			return Response.status(Response.Status.NO_CONTENT).build();
		} catch (NoDataAccess e) {
			e.printStackTrace();
			return Response.status(Response.Status.INTERNAL_SERVER_ERROR).build();
		}		
	}
}