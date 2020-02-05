package com.ibm.webapi.data;

import com.ibm.webapi.business.Author;
import com.ibm.webapi.business.NonexistentAuthor;
import org.eclipse.microprofile.rest.client.annotation.RegisterProvider;

import javax.ws.rs.GET;
import javax.ws.rs.Produces;
import javax.ws.rs.QueryParam;
import javax.ws.rs.core.MediaType;

@RegisterProvider(ExceptionMapperAuthors.class)
public interface AuthorsService {

    @GET
    @Produces(MediaType.APPLICATION_JSON)
    Author getAuthor(@QueryParam("name") String authorName) throws NonexistentAuthor;

}