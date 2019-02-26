package com.ibm;

import javax.enterprise.context.ApplicationScoped;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;
import java.util.Collection;

@ApplicationScoped
public class ArticlesCoreService {

    private final Map<String, Article> articles = new ConcurrentHashMap<>();

    public Article addArticle(String title, String url, String author) throws InvalidArticle {
        if (title == null) throw new InvalidArticle();
        
        long id = new java.util.Date().getTime();
        String idAsString = String.valueOf(id);
        
        if (url == null) url = "Unknown";
        if (author == null) author = "Unknown";

        Article article = new Article();
        article.title = title;
        article.id = idAsString;
        article.url = url;
        article.author = author;
        articles.put(idAsString, article);

        return article;
    }

    public Article getArticle(String id) throws ArticleDoesNotExist { 	
        Article article = articles.get(id);
        if (article == null) {
        	throw new ArticleDoesNotExist();
        }

        return article;
    }

    public Collection<Article> getArticles() {  	        
        return articles.values();
    }
}
