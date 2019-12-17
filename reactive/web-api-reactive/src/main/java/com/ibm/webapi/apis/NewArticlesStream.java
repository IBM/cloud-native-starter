package com.ibm.webapi.apis;

import javax.inject.Inject;
import javax.ws.rs.core.MediaType;
import org.reactivestreams.Publisher;
import io.smallrye.reactive.messaging.annotations.Channel;
import javax.ws.rs.GET;
import javax.ws.rs.Path;
import javax.ws.rs.Produces;
import org.jboss.resteasy.annotations.SseElementType;

@Path("/v1")
public class NewArticlesStream { 

    @Inject
    @Channel("my-data-stream") Publisher<String> newArticles;

	@GET
    @Path("/stream")
    @Produces(MediaType.SERVER_SENT_EVENTS) 
    @SseElementType("text/plain") 
    public Publisher<String> stream() { 
        return newArticles;
    }
}
