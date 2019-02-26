package com.ibm.articles.apis;

import javax.enterprise.context.RequestScoped;
import javax.inject.Inject;
import javax.json.JsonArray;
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
import com.ibm.articles.business.Article;
import com.ibm.articles.business.NoDataAccess;
import com.ibm.articles.business.Service;
import org.eclipse.microprofile.openapi.annotations.info.Info;
import org.eclipse.microprofile.openapi.annotations.responses.APIResponse;
import org.eclipse.microprofile.openapi.annotations.media.Content;
import org.eclipse.microprofile.openapi.annotations.media.Schema;

@RequestScoped
@Path("/v1")
@OpenAPIDefinition(
		info = @Info(title = "Articles Service", version = "1.0", description = "Articles Service APIs", 
		contact = @Contact(url = "https://github.com/nheidloff/cloud-native-starter", name = "Niklas Heidloff"), 
		license = @License(name = "License", url = "https://github.com/nheidloff/cloud-native-starter/blob/master/LICENSE")))
public class GetArticles {

	@Inject
	Service coreService;
	
	@Inject
	ArticleAsJson articleAsJson;

	@GET
	@Path("/all")
	@Produces(MediaType.APPLICATION_JSON)
	@APIResponses(value = {
	    @APIResponse(
	      responseCode = "200",
	      description = "All articles",
	      content = @Content(
	        mediaType = "application/json",
	        schema = @Schema(type = SchemaType.ARRAY, implementation = Article.class)
	      )
	    ),
	    @APIResponse(
  	      responseCode = "500",
  	      description = "Internal service error"  	      
  	    )
	})
	@Operation(
		    summary = "Get all articles",
		    description = "Get all articles"
	)
	public Response getArticles() {
		System.out.println("EndpointsArticles.getArticles");

		JsonArray jsonArray;
		try {
			jsonArray = coreService.getArticles().stream().map(article -> articleAsJson.createJson(article)).collect(JsonCollectors.toJsonArray());
			return Response.ok(jsonArray).build();
		} catch (NoDataAccess e) {			
			e.printStackTrace();
			return Response.status(Response.Status.INTERNAL_SERVER_ERROR).build();
		}
	}
}
