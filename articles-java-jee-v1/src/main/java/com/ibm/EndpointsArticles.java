package com.ibm;

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
import org.eclipse.microprofile.openapi.annotations.info.Info;
import org.eclipse.microprofile.openapi.annotations.responses.APIResponse;
import javax.ws.rs.QueryParam;
import org.eclipse.microprofile.openapi.annotations.media.Content;
import org.eclipse.microprofile.openapi.annotations.media.Schema;
import org.eclipse.microprofile.openapi.annotations.parameters.Parameter;

@RequestScoped
@Path("/v1")
@OpenAPIDefinition(
		info = @Info(title = "Articles Service", version = "1.0", description = "Articles Service APIs", 
		contact = @Contact(url = "https://github.com/nheidloff/cloud-native-starter", name = "Niklas Heidloff"), 
		license = @License(name = "License", url = "https://github.com/nheidloff/cloud-native-starter/blob/master/LICENSE")))
public class EndpointsArticles {

	@Inject
	ArticlesCoreService coreService;

	@GET
	@Path("/get")
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
			@QueryParam("id") String id) {
		System.out.println("EndpointsArticles.getArticle");

		Article article;
		try {
			article = coreService.getArticle(id);
		} catch (ArticleDoesNotExist exception) {
			return Response.status(Response.Status.NOT_FOUND).build();
		}

		return Response.ok(buildResponse(article)).build();
	}

	@GET
	@Path("/all")
	@Produces(MediaType.APPLICATION_JSON)
	@APIResponses(value = {
		    @APIResponse(
		      responseCode = "200",
		      description = "All articles",
		      content = @Content(
		        mediaType = "application/json",
		        schema = @Schema(implementation = Article[].class)
		      )
		    )
	})
	@Operation(
		    summary = "Get all articles",
		    description = "Get all articles"
	)
	public JsonArray getArticles() {
		System.out.println("EndpointsArticles.getArticles");

		return coreService.getArticles().stream().map(this::buildResponse).collect(JsonCollectors.toJsonArray());
	}

	@POST
	@Path("/create")
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
		    )
	})
	@Operation(
		    summary = "Create a new article",
		    description = "Create a new article"
	)
	public Response addArticle(@Parameter(
            description = "The new article",
            required = true,
            example = "{\"title\":\"Title\"}",
            schema = @Schema(implementation = Article.class))
			JsonObject jsonObject) {
		System.out.println("EndpointsArticles.addArticle");

		String title = jsonObject.getString("title", null);
		String url = jsonObject.getString("url", null);
		String author = jsonObject.getString("author", null);

		Article article;
		try {
			article = coreService.addArticle(title, url, author);

			return Response.status(Response.Status.CREATED).entity(buildResponse(article)).build();
		} catch (InvalidArticle excpetion) {
			return Response.status(Response.Status.NO_CONTENT).build();
		}
	}

	private JsonObject buildResponse(Article article) {
		return Json.createObjectBuilder().add("id", article.id).add("title", article.title).add("url", article.url)
				.add("author", article.author).build();
	}
}
