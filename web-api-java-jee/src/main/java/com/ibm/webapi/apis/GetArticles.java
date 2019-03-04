package com.ibm.webapi.apis;

import java.util.List;
import java.util.stream.Stream;
import javax.enterprise.context.RequestScoped;
import javax.inject.Inject;
import javax.json.JsonArray;
import javax.json.JsonObject;
import javax.json.stream.JsonCollectors;
import javax.ws.rs.*;
import javax.ws.rs.core.MediaType;
import javax.ws.rs.core.Response;

import org.eclipse.microprofile.metrics.annotation.Counted;
import org.eclipse.microprofile.metrics.annotation.Metered;
import org.eclipse.microprofile.metrics.annotation.Timed;
import org.eclipse.microprofile.openapi.annotations.OpenAPIDefinition;
import org.eclipse.microprofile.openapi.annotations.Operation;
import org.eclipse.microprofile.openapi.annotations.enums.SchemaType;
import org.eclipse.microprofile.openapi.annotations.info.Contact;
import org.eclipse.microprofile.openapi.annotations.info.License;
import org.eclipse.microprofile.openapi.annotations.responses.APIResponses;

import com.ibm.webapi.business.Article;
import com.ibm.webapi.business.CoreArticle;
import com.ibm.webapi.business.NoDataAccess;
import com.ibm.webapi.business.Service;
import org.eclipse.microprofile.openapi.annotations.info.Info;
import org.eclipse.microprofile.openapi.annotations.responses.APIResponse;
import org.eclipse.microprofile.openapi.annotations.media.Content;
import org.eclipse.microprofile.openapi.annotations.media.Schema;

@RequestScoped
@Path("/v1")
@OpenAPIDefinition(info = @Info(title = "Web-API Service", version = "1.0", description = "Web-API Service APIs", contact = @Contact(url = "https://github.com/nheidloff/cloud-native-starter", name = "Niklas Heidloff"), license = @License(name = "License", url = "https://github.com/nheidloff/cloud-native-starter/blob/master/LICENSE")))
public class GetArticles {

	@Inject
	com.ibm.webapi.business.Service service;
	
	@Inject
	ArticleAsJson articleAsJson;

	@Timed(name = "getArticlesTimed",
	        absolute = true,
	        displayName = "web-api /getmultiple timer",
	        description = "Time taken by com.ibm.webapi.apis.GetArticles.getArticles")
	@Counted(name = "getArticlesCounted",
	        absolute = true,
	        displayName = "web-api /getmultiple count",
	        description = "Number of times com.ibm.webapi.apis.GetArticles.getArticles has been invoked",
	        monotonic = true)
	@Metered(name = "getArticlesMetered",
	        displayName = "web-api /getmultiple frequency",
	        description = "Rate the throughput of com.ibm.webapi.apis.GetArticles.getArticles")
	@GET
	@Path("/getmultiple")
	@Produces(MediaType.APPLICATION_JSON)
	@APIResponses(value = {
			@APIResponse(responseCode = "200", description = "Get most recently added articles", content = @Content(mediaType = "application/json", schema = @Schema(type = SchemaType.ARRAY, implementation = Article.class))),			
			@APIResponse(responseCode = "500", description = "Internal service error") })
	@Operation(summary = "Get most recently added articles", description = "Get most recently added articles")
	public Response getArticles() {
		System.out.println("com.ibm.web-api.apis.GetArticles.getArticles");
		JsonArray jsonArray;
		try {
			List<Article> articles = service.getArticles();
			Stream<Article> streamArticles = articles.stream();
			Stream<JsonObject> streamJsonObjects = streamArticles.map(article -> {
				JsonObject output = articleAsJson.createJsonArticle(article);
				return output;
			});
			jsonArray = streamJsonObjects.collect(JsonCollectors.toJsonArray());
			return Response.ok(jsonArray).build();
		} catch (NoDataAccess e) {
			e.printStackTrace();
			return Response.status(Response.Status.INTERNAL_SERVER_ERROR).build();
		} catch (Exception e) {
			e.printStackTrace();
			return Response.status(Response.Status.INTERNAL_SERVER_ERROR).build();
		} 
	}
}
