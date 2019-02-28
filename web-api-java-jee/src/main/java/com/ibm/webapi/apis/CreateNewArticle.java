package com.ibm.webapi.apis;

import javax.enterprise.context.RequestScoped;
import javax.inject.Inject;
import javax.ws.rs.*;
import javax.ws.rs.core.MediaType;
import javax.ws.rs.core.Response;
import org.eclipse.microprofile.openapi.annotations.Operation;
import org.eclipse.microprofile.openapi.annotations.responses.APIResponses;
import com.ibm.webapi.business.CoreArticle;
import com.ibm.webapi.business.InvalidArticle;
import com.ibm.webapi.business.NoDataAccess;
import com.ibm.webapi.business.Service;
import org.eclipse.microprofile.openapi.annotations.responses.APIResponse;
import org.eclipse.microprofile.openapi.annotations.media.Content;
import org.eclipse.microprofile.openapi.annotations.media.Schema;
import org.eclipse.microprofile.openapi.annotations.parameters.RequestBody;

@RequestScoped
@Path("/v1")
public class CreateNewArticle {

	@Inject
	ArticleAsJson articleAsJson;

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
	        schema = @Schema(implementation = CoreArticle.class)
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
            content = @Content(schema = @Schema(implementation = CoreArticle.class))) CoreArticle newArticle) {
		System.out.println("com.ibm.web-api.apis.CreateNewArticle.addArticle");

		String title = newArticle.title;
		String url = newArticle.url;
		String author = newArticle.author;

		CoreArticle article;
		try {
			article = Service.getService().addArticle(title, url, author);

			return Response.status(Response.Status.CREATED).entity(articleAsJson.createJsonCoreArticle(article)).build();
		} catch (InvalidArticle excpetion) {
			return Response.status(Response.Status.NO_CONTENT).build();
		} catch (NoDataAccess e) {
			e.printStackTrace();
			return Response.status(Response.Status.INTERNAL_SERVER_ERROR).build();
		} catch (Exception e) {
			e.printStackTrace();
			return Response.status(Response.Status.INTERNAL_SERVER_ERROR).build();
		} 
	}
}