package com.ibm.webapi.apis;

import org.eclipse.microprofile.reactive.messaging.Incoming;
import javax.enterprise.context.ApplicationScoped;
import io.smallrye.reactive.messaging.annotations.Broadcast;
import org.eclipse.microprofile.reactive.messaging.Outgoing;
import io.smallrye.reactive.messaging.annotations.Channel;
import io.smallrye.reactive.messaging.annotations.Emitter;
import javax.inject.Inject;

@ApplicationScoped
public class NewArticleListener {

    @Inject
    @Channel("workaround-channel") Emitter<String> emitter;

    @Incoming("workaround-channel")
    @Outgoing("my-data-stream")
    @Broadcast
    public String processWorkaround(String articleId) {
        System.out.println("Channel message received: workaround-channel - " + articleId);
        return articleId;
    }

    @Incoming("new-article-created")
    public void process(String articleId) {
        System.out.println("Kafka message received: new-article-created - " + articleId);
        emitter.send(articleId);
    }

    @Incoming("my-data-stream")
    public void processAnotherWorkaround(String articleId) {
    }

}
