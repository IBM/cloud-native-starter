package com.ibm;

import javax.inject.Inject;
import javax.json.Json;
import javax.json.JsonObject;
import javax.ws.rs.*;
import javax.ws.rs.core.Response;

@Path("/articles/{id}")
public class EndpointsArticles {

    @Inject
    CoreService coreService;

    @PathParam("id")
    String id;

    @GET
    public Response getArticle() {
        Article article = coreService.getArticle(id);

        if (article == null)
            return Response.status(Response.Status.NOT_FOUND).build();

        return Response.ok(buildResponse(article)).build();
    }

    @PUT
    public Response addArticle(JsonObject jsonObject) {
        String title = jsonObject.getString("title", null);

        if (title == null)
            throw new BadRequestException();

        Article brew = coreService.addArticle(id, title);

        return Response.status(Response.Status.CREATED)
                .entity(buildResponse(brew))
                .build();
    }

    private JsonObject buildResponse(Article article) {
        return Json.createObjectBuilder()
                .add("title", article.title)
                .add("publicationDate", article.publicationDate.toString())
                .build();
    }

}
