package com.ibm.webapi.data;

import com.ibm.webapi.business.CoreArticle;
import org.eclipse.microprofile.rest.client.annotation.RegisterProvider;

import javax.ws.rs.GET;
import javax.ws.rs.Produces;
import javax.ws.rs.QueryParam;
import javax.ws.rs.core.MediaType;
import java.util.List;
import java.util.concurrent.CompletionStage;

@RegisterProvider(ExceptionMapperArticles.class)
public interface ArticlesServiceReactive {

    @GET
    @Produces(MediaType.APPLICATION_JSON)
    CompletionStage<List<CoreArticle>> getArticlesFromService(@QueryParam("amount") int amount);

}