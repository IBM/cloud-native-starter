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
import org.eclipse.microprofile.openapi.annotations.OpenAPIDefinition;
import org.eclipse.microprofile.openapi.annotations.Operation;
import org.eclipse.microprofile.openapi.annotations.enums.SchemaType;
import org.eclipse.microprofile.openapi.annotations.info.Contact;
import org.eclipse.microprofile.openapi.annotations.info.License;
import org.eclipse.microprofile.openapi.annotations.responses.APIResponses;
import com.ibm.webapi.business.Article;
import com.ibm.webapi.business.NoDataAccess;
import com.ibm.webapi.business.Service;
import org.eclipse.microprofile.openapi.annotations.info.Info;
import org.eclipse.microprofile.openapi.annotations.responses.APIResponse;
import org.eclipse.microprofile.openapi.annotations.media.Content;
import org.eclipse.microprofile.openapi.annotations.media.Schema;

@RequestScoped
@Path("/v1")
@OpenAPIDefinition(info = @Info(title = "Articles Service", version = "1.0", description = "Articles Service APIs", contact = @Contact(url = "https://github.com/nheidloff/cloud-native-starter", name = "Niklas Heidloff"), license = @License(name = "License", url = "https://github.com/nheidloff/cloud-native-starter/blob/master/LICENSE")))
public class GetArticles {

	@Inject
	ArticleAsJson articleAsJson;

	@GET
	@Path("/getmultiple")
	@Produces(MediaType.APPLICATION_JSON)
	@APIResponses(value = {
			@APIResponse(responseCode = "200", description = "Get most recently added articles", content = @Content(mediaType = "application/json", schema = @Schema(type = SchemaType.ARRAY, implementation = Article.class))),			
			@APIResponse(responseCode = "500", description = "Internal service error") })
	@Operation(summary = "Get most recently added articles", description = "Get most recently added articles")
	public Response getArticles() {
		System.out.println("com.ibm.web-api.apis.GetArticles.addArticle");
		JsonArray jsonArray;
		try {
			List<Article> articles = Service.getService().getArticles();
			Stream<Article> streamArticles = articles.stream();
			Stream<JsonObject> streamJsonObjects = streamArticles.map(article -> {
				JsonObject output = articleAsJson.createJson(article);
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
