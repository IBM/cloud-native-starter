package com.ibm.webapi.data;

import java.util.List;
import javax.ws.rs.Consumes;
import javax.ws.rs.GET;
import javax.ws.rs.POST;
import javax.ws.rs.Produces;
import javax.ws.rs.core.MediaType;
import org.eclipse.microprofile.rest.client.annotation.RegisterProvider;
import com.ibm.webapi.business.CoreArticle;
import com.ibm.webapi.business.InvalidArticle;

@RegisterProvider(ExceptionMapperArticles.class)
public interface ArticlesService {

  @GET
  @Produces(MediaType.APPLICATION_JSON)
  public List<CoreArticle> getArticlesFromService();
  
  @POST
  @Consumes(MediaType.APPLICATION_JSON)
  @Produces(MediaType.APPLICATION_JSON)
  public CoreArticle addArticle(CoreArticle article) throws InvalidArticle;
}