package com.ibm.webapi.apis;

import com.ibm.webapi.business.Article;
import com.ibm.webapi.business.NoDataAccess;
import com.ibm.webapi.business.Service;
import org.eclipse.microprofile.openapi.annotations.Operation;
import org.eclipse.microprofile.openapi.annotations.enums.SchemaType;
import org.eclipse.microprofile.openapi.annotations.media.Content;
import org.eclipse.microprofile.openapi.annotations.media.Schema;
import org.eclipse.microprofile.openapi.annotations.responses.APIResponse;
import org.eclipse.microprofile.openapi.annotations.responses.APIResponses;

import javax.enterprise.context.ApplicationScoped;
import javax.inject.Inject;
import javax.json.JsonArray;
import javax.json.stream.JsonCollectors;
import javax.ws.rs.GET;
import javax.ws.rs.Path;
import javax.ws.rs.Produces;
import javax.ws.rs.core.MediaType;
import javax.ws.rs.core.Response;
import java.util.concurrent.CompletionStage;

@Path("/v2/articles")
@ApplicationScoped
@Produces(MediaType.APPLICATION_JSON)
public class ArticlesReactiveResource {

    @Inject
    Service service;

    @Inject
    ArticleAsJson articleAsJson;

    @GET
    @APIResponses(value = {
            @APIResponse(responseCode = "200", description = "Get most recently added articles", content = @Content(mediaType = "application/json", schema = @Schema(type = SchemaType.ARRAY, implementation = Article.class))),
            @APIResponse(responseCode = "500", description = "Internal service error")})
    @Operation(summary = "Get most recently added articles (reactive)", description = "Get most recently added articles")
    public CompletionStage<Response> getArticles() {
        System.out.println("com.ibm.web-api.apis.GetArticlesReactive.getArticlesReactive");

        Runtime rt = Runtime.getRuntime();
        System.out.println(String.format("Memory - Used: %s, Total: %s", (rt.totalMemory() - rt.freeMemory()) / 1000000, rt.totalMemory() / 1000000));

        return service.getArticlesReactive()
                .thenApply(articles -> {

                    JsonArray json = articles.stream()
                            .map(article -> articleAsJson.createJsonArticle(article))
                            .collect(JsonCollectors.toJsonArray());

                    return Response.ok(json).build();
                })
                .exceptionally(throwable -> {
                    if (throwable.getCause() instanceof NoDataAccess)
                        return Response.status(Response.Status.INTERNAL_SERVER_ERROR).build();
                    return Response.status(Response.Status.INTERNAL_SERVER_ERROR).build();
                });
    }

}
