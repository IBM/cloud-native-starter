package com.ibm.webapi;

import com.ibm.webapi.CoreArticle;
import com.ibm.webapi.InvalidArticle;
import org.eclipse.microprofile.rest.client.annotation.RegisterProvider;

import javax.ws.rs.*;
import javax.ws.rs.core.MediaType;
import java.util.List;

@RegisterProvider(ExceptionMapperArticles.class)
public interface ArticlesService {

    @GET
    @Produces(MediaType.APPLICATION_JSON)
    List<CoreArticle> getArticlesFromService(@QueryParam("amount") int amount);

    @POST
    @Consumes(MediaType.APPLICATION_JSON)
    @Produces(MediaType.APPLICATION_JSON)
    CoreArticle addArticle(CoreArticle article) throws InvalidArticle;

}