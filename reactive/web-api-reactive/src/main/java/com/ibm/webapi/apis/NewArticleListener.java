package com.ibm.webapi.apis;

import org.eclipse.microprofile.reactive.messaging.Incoming;
import javax.enterprise.context.ApplicationScoped;
import io.smallrye.reactive.messaging.annotations.Broadcast;
import org.eclipse.microprofile.reactive.messaging.Outgoing;

@ApplicationScoped
public class NewArticleListener {

    @Incoming("new-article-created")
    @Outgoing("stream-new-article")
    @Broadcast
    public String process(String articleId) {
        System.out.println("Kafka message received: new-article-created - " + articleId);
        return articleId;
    }
    
}
