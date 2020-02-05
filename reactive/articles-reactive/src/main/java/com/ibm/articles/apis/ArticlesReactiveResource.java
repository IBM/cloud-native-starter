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
import javax.json.stream.JsonCollectors;
import javax.ws.rs.*;
import javax.ws.rs.core.MediaType;
import javax.ws.rs.core.Response;
import java.util.concurrent.CompletionStage;

@ApplicationScoped
@Path("/v2/articles") // asynchronous
@Produces(MediaType.APPLICATION_JSON)
@Consumes(MediaType.APPLICATION_JSON)
public class ArticlesReactiveResource {

    @Inject
    ArticleAsJson articleAsJson;

    @Inject
    ArticleService articleService;

    @GET
    @APIResponses(value = {
            @APIResponse(responseCode = "200", description = "Get most recently added articles", content = @Content(mediaType = "application/json", schema = @Schema(type = SchemaType.ARRAY, implementation = Article.class))),
            @APIResponse(responseCode = "204", description = "Input not valid (no valid amount)"),
            @APIResponse(responseCode = "500", description = "Internal service error")})
    @Operation(summary = "Get most recently added articles (reactive)", description = "Get most recently added articles")
    public CompletionStage<Response> getArticlesReactive(@Parameter(description = "The amount of articles", required = true, example = "10", schema = @Schema(type = SchemaType.INTEGER)) @QueryParam("amount") int amount) {
        System.out.println("com.ibm.articles.apis.GetArticlesReactive.getArticlesReactive");

        return articleService.getArticlesReactive(amount)
                .thenApply(articles -> articles.stream()
                        .map(article -> articleAsJson.createJson(article))
                        .collect(JsonCollectors.toJsonArray()))
                .thenApply(jsonArray -> Response.ok(jsonArray).build())
                .exceptionally(throwable -> {
                    if (throwable.getCause().toString().equals(InvalidInputParameter.class.getName()))
                        return Response.status(Response.Status.BAD_REQUEST).build();
                    return Response.status(Response.Status.INTERNAL_SERVER_ERROR).build();
                });
    }

    @GET
    @Path("{id}")
    @APIResponses(value = {
            @APIResponse(responseCode = "204", description = "Article Not Found"),
            @APIResponse(responseCode = "200", description = "Article with requested id", content = @Content(mediaType = "application/json", schema = @Schema(implementation = Article.class))),
            @APIResponse(responseCode = "500", description = "Internal service error")
    })
    @Operation(summary = "Get specific article (reactive)", description = "Get specific article")
    public CompletionStage<Response> getArticleReactive(@Parameter(description = "The unique id of the article", required = true, example = "1551176445313", schema = @Schema(type = SchemaType.STRING)) @PathParam("id") String id) {
        System.out.println("com.ibm.articles.apis.GetArticleReactive.getArticleReactive(" + id + ")");

        return articleService.getArticleReactive(id)
                .thenApply(article -> Response.ok(articleAsJson.createJson(article)).build())
                .exceptionally(throwable -> {
                    if (throwable.getCause().toString().equals(ArticleDoesNotExist.class.getName()))
                        return Response.status(Response.Status.NO_CONTENT).build();
                    return Response.status(Response.Status.INTERNAL_SERVER_ERROR).build();
                });
    }

    @POST
    @APIResponses(value = {
            @APIResponse(responseCode = "204", description = "Input not valid (no title)"),
            @APIResponse(responseCode = "201", description = "Article has been created", content = @Content(mediaType = "application/json", schema = @Schema(implementation = Article.class))),
            @APIResponse(responseCode = "500", description = "Internal service error")
    })
    @Operation(summary = "Create a new article (reactive)", description = "Create a new article")
    public CompletionStage<Response> addArticleReactive(@RequestBody(description = "New article", required = true, content = @Content(schema = @Schema(implementation = Article.class))) Article newArticle) {
        System.out.println("com.ibm.articles.apis.CreateNewArticleReactive.addArticleReactive");

        return articleService.addArticleReactive(newArticle.title, newArticle.url, newArticle.author)
                .thenApply(article -> Response.status(Response.Status.CREATED).entity(articleAsJson.createJson(article)).build())
                .exceptionally(throwable -> {
                    if (throwable.getCause().toString().equals(InvalidArticle.class.getName()))
                        return Response.status(Response.Status.BAD_REQUEST).build();
                    return Response.status(Response.Status.INTERNAL_SERVER_ERROR).build();
                });
    }

}