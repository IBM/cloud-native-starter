package com.ibm.webapi.data;

import java.util.List;
import java.util.concurrent.CompletionStage;
import javax.ws.rs.GET;
import javax.ws.rs.Produces;
import javax.ws.rs.core.MediaType;
import org.eclipse.microprofile.rest.client.annotation.RegisterProvider;
import com.ibm.webapi.business.CoreArticle;

@RegisterProvider(ExceptionMapperArticles.class)
public interface ArticlesServiceReactive {

  @GET
  @Produces(MediaType.APPLICATION_JSON)
  public CompletionStage<List<CoreArticle>> getArticlesFromService();
}