package com.ibm.articles.apis;

import javax.enterprise.context.RequestScoped;
import javax.inject.Inject;
import javax.json.Json;
import javax.json.JsonArray;
import javax.json.JsonObject;
import javax.json.stream.JsonCollectors;
import javax.ws.rs.*;
import javax.ws.rs.core.MediaType;
import javax.ws.rs.core.Response;
import org.eclipse.microprofile.openapi.annotations.OpenAPIDefinition;
import org.eclipse.microprofile.openapi.annotations.Operation;
import org.eclipse.microprofile.openapi.annotations.enums.SchemaType;
import org.eclipse.microprofile.openapi.annotations.info.Contact;
import org.eclipse.microprofile.openapi.annotations.info.License;
import org.eclipse.microprofile.openapi.annotations.responses.APIResponses;
import javax.inject.Inject;
import com.ibm.articles.business.Article;
import com.ibm.articles.business.InvalidArticle;
import com.ibm.articles.business.NoDataAccess;
import com.ibm.articles.data.JPADataAccess;
import com.ibm.articles.business.CoreService;

import org.eclipse.microprofile.openapi.annotations.info.Info;
import org.eclipse.microprofile.openapi.annotations.responses.APIResponse;
import javax.ws.rs.QueryParam;
import org.eclipse.microprofile.openapi.annotations.media.Content;
import org.eclipse.microprofile.openapi.annotations.media.Schema;
import org.eclipse.microprofile.openapi.annotations.parameters.Parameter;
import org.eclipse.microprofile.openapi.annotations.parameters.RequestBody;
import javax.enterprise.context.ApplicationScoped;

@ApplicationScoped
@Path("/v1")
public class CreateNewArticle {

	@Inject
	ArticleAsJson articleAsJson;
	
	@Inject 
	com.ibm.articles.business.CoreService coreService;

	//@Inject
  //private JPADataAccess dataAccess;

	@POST
	@Path("/create")
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
		    summary = "Create a new article",
		    description = "Create a new article"
	)
	public Response addArticle(@RequestBody(description = "New article", required = true,
            content = @Content(schema = @Schema(implementation = Article.class))) Article newArticle) {
		System.out.println("com.ibm.articles.apis.CreateNewArticle.addArticle");

		String title = newArticle.title;
		String url = newArticle.url;
		String author = newArticle.author;

		Article article;
		try {
			article = coreService.addArticle(title, url, author);

			return Response.status(Response.Status.CREATED).entity(articleAsJson.createJson(article)).build();
		} catch (InvalidArticle excpetion) {
			return Response.status(Response.Status.NO_CONTENT).build();
		} catch (NoDataAccess e) {
			e.printStackTrace();
			return Response.status(Response.Status.INTERNAL_SERVER_ERROR).build();
		}
	}
}