package com.ibm.webapi.apis;

import com.ibm.webapi.business.Article;
import com.ibm.webapi.business.CoreArticle;
import com.ibm.webapi.business.InvalidArticle;
import com.ibm.webapi.business.Service;
import org.eclipse.microprofile.openapi.annotations.OpenAPIDefinition;
import org.eclipse.microprofile.openapi.annotations.Operation;
import org.eclipse.microprofile.openapi.annotations.enums.SchemaType;
import org.eclipse.microprofile.openapi.annotations.info.Contact;
import org.eclipse.microprofile.openapi.annotations.info.Info;
import org.eclipse.microprofile.openapi.annotations.info.License;
import org.eclipse.microprofile.openapi.annotations.media.Content;
import org.eclipse.microprofile.openapi.annotations.media.Schema;
import org.eclipse.microprofile.openapi.annotations.parameters.RequestBody;
import org.eclipse.microprofile.openapi.annotations.responses.APIResponse;
import org.eclipse.microprofile.openapi.annotations.responses.APIResponses;

import javax.enterprise.context.RequestScoped;
import javax.inject.Inject;
import javax.json.JsonArray;
import javax.json.JsonObject;
import javax.json.stream.JsonCollectors;
import javax.ws.rs.*;
import javax.ws.rs.core.MediaType;
import javax.ws.rs.core.Response;

@Path("/v1/articles")
@RequestScoped
@Produces(MediaType.APPLICATION_JSON)
@Consumes(MediaType.APPLICATION_JSON)
@OpenAPIDefinition(info = @Info(title = "Web-API Service", version = "1.0", description = "Web-API Service APIs",
        contact = @Contact(url = "https://github.com/nheidloff/cloud-native-starter", name = "Niklas Heidloff"),
        license = @License(name = "License", url = "https://github.com/nheidloff/cloud-native-starter/blob/master/LICENSE")))
public class ArticlesResource {

    @Inject
    Service service;

    @Inject
    ArticleAsJson articleAsJson;

    @GET
    @Produces(MediaType.APPLICATION_JSON)
    @APIResponses(value = {
            @APIResponse(responseCode = "200", description = "Get most recently added articles", content = @Content(mediaType = "application/json", schema = @Schema(type = SchemaType.ARRAY, implementation = Article.class))),
            @APIResponse(responseCode = "500", description = "Internal service error")})
    @Operation(summary = "Get most recently added articles", description = "Get most recently added articles")
    public Response getArticles() {
        System.out.println("com.ibm.web-api.apis.GetArticles.getArticles");

        Runtime rt = Runtime.getRuntime();
        System.out.println(String.format("Memory - Used: %s, Total: %s", (rt.totalMemory() - rt.freeMemory()) / 1000000, rt.totalMemory() / 1000000));
        System.out.println(String.format("Memory - Used: %s, Total: %s", rt.totalMemory() - rt.freeMemory(), rt.totalMemory()));

        try {
            JsonArray json = service.getArticles().stream()
                    .map(article -> articleAsJson.createJsonArticle(article))
                    .collect(JsonCollectors.toJsonArray());
            return Response.ok(json).build();
        } catch (Exception e) {
            e.printStackTrace();
            return Response.status(Response.Status.INTERNAL_SERVER_ERROR).build();
        }
    }

    @POST
    @APIResponses(value = {
            @APIResponse(responseCode = "204", description = "Input not valid (no title)"),
            @APIResponse(responseCode = "201", description = "Article has been created", content = @Content(mediaType = "application/json", schema = @Schema(implementation = CoreArticle.class))),
            @APIResponse(responseCode = "500", description = "Internal service error")})
    @Operation(summary = "Create a new article", description = "Create a new article")
    public Response addArticle(@RequestBody(description = "New article", required = true, content = @Content(schema = @Schema(implementation = CoreArticle.class)))
                                       CoreArticle newArticle) {
        System.out.println("com.ibm.web-api.apis.CreateNewArticle.addArticle");

        String title = newArticle.title;
        String url = newArticle.url;
        String author = newArticle.author;

        try {
            CoreArticle article = service.addArticle(title, url, author);
            JsonObject json = articleAsJson.createJsonCoreArticle(article);

            return Response.status(Response.Status.CREATED)
                    .entity(json)
                    .build();

        } catch (InvalidArticle e) {
            return Response.status(Response.Status.NO_CONTENT).build();
        } catch (Exception e) {
            e.printStackTrace();
            return Response.status(Response.Status.INTERNAL_SERVER_ERROR).build();
        }
    }

}