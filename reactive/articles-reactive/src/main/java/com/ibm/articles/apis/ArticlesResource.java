package com.ibm.articles.apis;

import com.ibm.articles.business.*;
import org.eclipse.microprofile.openapi.annotations.Operation;
import org.eclipse.microprofile.openapi.annotations.enums.SchemaType;
import org.eclipse.microprofile.openapi.annotations.media.Content;
import org.eclipse.microprofile.openapi.annotations.media.Schema;
import org.eclipse.microprofile.openapi.annotations.parameters.Parameter;
import org.eclipse.microprofile.openapi.annotations.parameters.RequestBody;
import org.eclipse.microprofile.openapi.annotations.responses.APIResponse;
import org.eclipse.microprofile.openapi.annotations.responses.APIResponses;

import javax.enterprise.context.ApplicationScoped;
import javax.inject.Inject;
import javax.json.JsonArray;
import javax.json.stream.JsonCollectors;
import javax.ws.rs.*;
import javax.ws.rs.core.MediaType;
import javax.ws.rs.core.Response;

@ApplicationScoped
@Path("/v1/articles/") // synchronous
@Produces(MediaType.APPLICATION_JSON)
@Consumes(MediaType.APPLICATION_JSON)
public class ArticlesResource {

    @Inject
    ArticleAsJson articleAsJson;

    @Inject
    ArticleService articleService;

    @GET
    @APIResponses(value = {
            @APIResponse(responseCode = "200", description = "Get most recently added articles", content = @Content(mediaType = "application/json", schema = @Schema(type = SchemaType.ARRAY, implementation = Article.class))),
            @APIResponse(responseCode = "204", description = "Input not valid (no valid amount)"),
            @APIResponse(responseCode = "500", description = "Internal service error")})
    @Operation(summary = "Get most recently added articles", description = "Get most recently added articles")
    public Response getArticles(
            @Parameter(description = "The amount of articles", required = true, example = "10", schema = @Schema(type = SchemaType.INTEGER)) @QueryParam("amount") int amount) {
        System.out.println("com.ibm.articles.apis.GetArticles.getArticles");

        try {
            JsonArray json = articleService.getArticles(amount).stream()
                    .map(article -> articleAsJson.createJson(article))
                    .collect(JsonCollectors.toJsonArray());
            return Response.ok(json).build();
        } catch (NoDataAccess e) {
            e.printStackTrace();
            return Response.status(Response.Status.INTERNAL_SERVER_ERROR).build();
        } catch (InvalidInputParameter e) {
            return Response.status(Response.Status.NO_CONTENT).build();
        }
    }

    @GET
    @Path("{id}")
    @APIResponses(value = {
            @APIResponse(responseCode = "204", description = "Article Not Found"),
            @APIResponse(responseCode = "200", description = "Article with requested id", content = @Content(mediaType = "application/json", schema = @Schema(implementation = Article.class))),
            @APIResponse(responseCode = "500", description = "Internal service error")
    })
    @Operation(summary = "Get specific article", description = "Get specific article")
    public Response getArticle(@Parameter(description = "The unique id of the article", required = true, example = "1551176445313", schema = @Schema(type = SchemaType.STRING)) @PathParam("id") String id) {
        System.out.println("com.ibm.articles.apis.GetArticle.getArticle(" + id + ")");

        try {
            Article article = articleService.getArticle(id);
            return Response.ok(articleAsJson.createJson(article)).build();
        } catch (ArticleDoesNotExist e) {
            return Response.status(Response.Status.NO_CONTENT).build();
        } catch (NoDataAccess e) {
            e.printStackTrace();
            return Response.status(Response.Status.INTERNAL_SERVER_ERROR).build();
        }
    }

    @POST
    @APIResponses(value = {
            @APIResponse(responseCode = "204", description = "Input not valid (no title)"),
            @APIResponse(responseCode = "201", description = "Article has been created", content = @Content(mediaType = "application/json", schema = @Schema(implementation = Article.class))),
            @APIResponse(responseCode = "500", description = "Internal service error")
    })
    @Operation(summary = "Create a new article", description = "Create a new article")
    public Response addArticle(@RequestBody(description = "New article", required = true, content = @Content(schema = @Schema(implementation = Article.class))) Article newArticle) {
        System.out.println("com.ibm.articles.apis.CreateNewArticle.addArticle");

        String title = newArticle.title;
        String url = newArticle.url;
        String author = newArticle.author;

        Article article;
        try {
            article = articleService.addArticle(title, url, author);

            return Response.status(Response.Status.CREATED).entity(articleAsJson.createJson(article)).build();
        } catch (InvalidArticle e) {
            return Response.status(Response.Status.NO_CONTENT).build();
        } catch (NoDataAccess e) {
            e.printStackTrace();
            return Response.status(Response.Status.INTERNAL_SERVER_ERROR).build();
        }
    }

}