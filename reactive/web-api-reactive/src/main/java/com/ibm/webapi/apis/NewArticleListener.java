package com.ibm.webapi.apis;

import org.eclipse.microprofile.reactive.messaging.Incoming;
import javax.enterprise.context.ApplicationScoped;
import io.smallrye.reactive.messaging.annotations.Broadcast;
import org.eclipse.microprofile.reactive.messaging.Incoming;
import org.eclipse.microprofile.reactive.messaging.Outgoing;

import javax.enterprise.context.ApplicationScoped;


@ApplicationScoped
public class NewArticleListener {

    private static final double CONVERSION_RATE = 0.88;

    @Incoming("new-article-created")
    //@Outgoing("my-data-stream")                         
    //@Broadcast
    // when these annotations are enabled, the Kafka messages don't arrive anymore
    public String process(final String priceInUsd) {
        System.out.println("Kafka record received: new-article-created");
        return "adsf";
    }

}
