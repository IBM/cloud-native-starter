package com.ibm.articles.apis;

import javax.enterprise.context.RequestScoped;
import javax.inject.Inject;
import javax.ws.rs.*;
import javax.ws.rs.core.Response;
import org.eclipse.microprofile.openapi.annotations.Operation;
import org.eclipse.microprofile.openapi.annotations.enums.SchemaType;
import org.eclipse.microprofile.openapi.annotations.responses.APIResponses;
import com.ibm.articles.business.Article;
import com.ibm.articles.business.ArticleDoesNotExist;
import com.ibm.articles.business.NoDataAccess;
import org.eclipse.microprofile.openapi.annotations.responses.APIResponse;
import javax.ws.rs.QueryParam;
import org.eclipse.microprofile.openapi.annotations.media.Content;
import org.eclipse.microprofile.openapi.annotations.media.Schema;
import org.eclipse.microprofile.openapi.annotations.parameters.Parameter;

@RequestScoped
@Path("/v1")
public class GetArticle {

	@Inject
	ArticleAsJson articleAsJson;
	
	@Inject 
	com.ibm.articles.business.CoreService coreService;

	@GET
	@Path("/articles/{id}")
	@APIResponses(value = {
		@APIResponse(
	      responseCode = "404",
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
			article = coreService.getArticle(id);
			return Response.ok(articleAsJson.createJson(article)).build();
		} catch (ArticleDoesNotExist exception) {
			return Response.status(Response.Status.NOT_FOUND).build();
		} catch (NoDataAccess e) {
			e.printStackTrace();
			return Response.status(Response.Status.INTERNAL_SERVER_ERROR).build();
		}		
	}
}