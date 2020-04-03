package com.ibm.cns.articles.boundary;

import com.ibm.cns.articles.entity.Article;
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
import org.eclipse.microprofile.openapi.annotations.info.Info;
import org.eclipse.microprofile.openapi.annotations.info.License;
import org.eclipse.microprofile.openapi.annotations.media.Content;
import org.eclipse.microprofile.openapi.annotations.media.Schema;
import org.eclipse.microprofile.openapi.annotations.parameters.Parameter;
import org.eclipse.microprofile.openapi.annotations.parameters.RequestBody;
import org.eclipse.microprofile.openapi.annotations.responses.APIResponse;
import org.eclipse.microprofile.openapi.annotations.responses.APIResponses;

@RequestScoped
@Path("/")
@OpenAPIDefinition(info = @Info(title = "Articles Service", version = "1.0", description = "Articles Service APIs", contact = @Contact(url = "https://github.com/nheidloff/cloud-native-starter", name = "Niklas Heidloff"), license = @License(name = "License", url = "https://github.com/nheidloff/cloud-native-starter/blob/master/LICENSE")))
public class ArticlesResource {

    @Inject
    ArticlesService coreService;

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

        Article article = coreService.addArticle(newArticle);
        return Response.status(Response.Status.CREATED).entity(article.toJSON()).build();
    }

    @GET
    @Path("/getone")
    @APIResponses(value = {
        @APIResponse(
                responseCode = "204",
                description = "Article Not Found"
        ),
        @APIResponse(
                responseCode = "200",
                description = "Article with requested id",
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
            summary = "Get specific article",
            description = "Get specific article"
    )
    public Response getArticle(@Parameter(
            description = "The unique id of the article",
            required = true,
            example = "1551176445313",
            schema = @Schema(type = SchemaType.STRING))
            @QueryParam("id") String id) {
        System.out.println("com.ibm.articles.apis.GetArticle.getArticle");

        Article article = coreService.getArticle(id);
        return Response.ok(article.toJSON()).build();
    }

    @GET
    @Path("/getmultiple")
    @Produces(MediaType.APPLICATION_JSON)
    @APIResponses(value = {
        @APIResponse(responseCode = "200", description = "Get most recently added articles", content = @Content(mediaType = "application/json", schema = @Schema(type = SchemaType.ARRAY, implementation = Article.class))),
        @APIResponse(responseCode = "204", description = "Input not valid (no amount)"),
        @APIResponse(responseCode = "500", description = "Internal service error")})
    @Operation(summary = "Get most recently added articles", description = "Get most recently added articles")
    public Response getArticles(
            @Parameter(description = "The amount of articles", required = true, example = "10", schema = @Schema(type = SchemaType.INTEGER)) @QueryParam("amount") int amount) {
        System.out.println("com.ibm.articles.apis.GetArticles.getArticles");

        JsonArray jsonArray = coreService.getArticles(amount).stream().map(Article::toJSON).
                collect(JsonCollectors.toJsonArray());
        return Response.ok(jsonArray).build();
    }

}
