package com.ibm.webapi.data;

import java.util.List;

import javax.json.JsonObject;
import javax.ws.rs.GET;
import javax.ws.rs.POST;
import javax.ws.rs.Produces;
import javax.ws.rs.core.MediaType;
import org.eclipse.microprofile.rest.client.annotation.RegisterProvider;
import com.ibm.webapi.business.Article;
import com.ibm.webapi.business.InvalidArticle;

@RegisterProvider(ExceptionMapper.class)
public interface ArticlesService {

  @GET
  @Produces(MediaType.APPLICATION_JSON)
  public List getArticlesFromService();
  
  @POST
  @Produces(MediaType.APPLICATION_JSON)
  public Article addArticle(Article article) throws InvalidArticle;
}