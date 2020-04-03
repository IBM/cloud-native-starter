package com.ibm.webapi.data;

import javax.ws.rs.GET;
import javax.ws.rs.Produces;
import javax.ws.rs.core.MediaType;
import org.eclipse.microprofile.rest.client.annotation.RegisterProvider;
import com.ibm.webapi.business.Author;
import com.ibm.webapi.business.NonexistentAuthor;

@RegisterProvider(ExceptionMapperArticles.class)
public interface AuthorsService {

  @GET
  @Produces(MediaType.APPLICATION_JSON)
  public Author getAuthor(String name) throws NonexistentAuthor;
  
}