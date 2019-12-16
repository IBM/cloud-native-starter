package com.ibm.articles.apis;

import org.eclipse.microprofile.reactive.messaging.Incoming;
import javax.enterprise.context.ApplicationScoped;

@ApplicationScoped
public class NewArticleListener {

    @Incoming("new-article-created")
    public void process(String articleId) {
        System.out.println("Kafka record received: new-article-created");
        System.out.println(articleId);
    }
}
