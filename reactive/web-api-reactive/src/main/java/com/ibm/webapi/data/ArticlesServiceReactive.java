package com.ibm.webapi.data;

import java.util.List;
import java.util.concurrent.CompletionStage;
import javax.ws.rs.Consumes;
import javax.ws.rs.GET;
import javax.ws.rs.POST;
import javax.ws.rs.Produces;
import javax.ws.rs.core.MediaType;
import org.eclipse.microprofile.rest.client.annotation.RegisterProvider;
import org.eclipse.microprofile.rest.client.inject.RegisterRestClient;
import com.ibm.webapi.business.CoreArticle;
import com.ibm.webapi.business.InvalidArticle;

@RegisterRestClient(baseUri = "http://job-service:9080")
@RegisterProvider(ExceptionMapperArticles.class)
public interface ArticlesServiceReactive {

  @GET
  @Produces(MediaType.APPLICATION_JSON)
  public CompletionStage<List<CoreArticle>> getArticlesFromService();
  
  @POST
  @Consumes(MediaType.APPLICATION_JSON)
  @Produces(MediaType.APPLICATION_JSON)
  public CompletionStage<CoreArticle> addArticle(CoreArticle article) throws InvalidArticle;
}