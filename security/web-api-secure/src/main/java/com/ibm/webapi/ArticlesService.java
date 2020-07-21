package com.ibm.webapi;

import org.eclipse.microprofile.rest.client.annotation.RegisterClientHeaders;
import org.eclipse.microprofile.rest.client.annotation.RegisterProvider;
import org.eclipse.microprofile.rest.client.inject.RegisterRestClient;
import javax.ws.rs.*;
import javax.ws.rs.core.MediaType;
import java.util.List;

@RegisterClientHeaders
@RegisterRestClient
@RegisterProvider(ExceptionMapperArticles.class)
public interface ArticlesService {

    @GET
    @Produces(MediaType.APPLICATION_JSON)
    List<CoreArticle> getArticlesFromService(@HeaderParam("Authorization") String authorization, @QueryParam("amount") int amount);
    //List<CoreArticle> getArticlesFromService(@QueryParam("amount") int amount);
    // The authorization header needs to be passed in manually unfortuntely
    // https://stackoverflow.com/questions/62691824/how-can-the-authorization-header-be-propagated-in-quarkus-apps-with-the-micropro
}