package com.ibm;

import javax.enterprise.context.ApplicationScoped;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

@ApplicationScoped
public class CoreService {

    private final Map<String, Article> articles = new ConcurrentHashMap<>();

    public Article addArticle(String id, String title) {
        System.out.println("CoreService.addArticle");

        Article article = new Article();
        article.title = title;
        article.publicationDate = new java.util.Date();
        articles.put(id, article);

        return article;
    }

    public Article getArticle(String id) {
    	System.out.println("CoreService.getArticle");
    	
        Article article = articles.get(id);

        if (article == null)
            return null;

        return article;
    }

}
