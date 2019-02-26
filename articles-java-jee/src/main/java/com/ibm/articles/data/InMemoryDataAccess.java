package com.ibm.articles.data;

import com.ibm.articles.business.Article;
import com.ibm.articles.business.ArticleDoesNotExist;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;
import java.util.Collection;

public class InMemoryDataAccess implements DataAccess {

    private Map<String, Article> articles;
    
    public InMemoryDataAccess() {
    	articles = new ConcurrentHashMap<>();
    }

    public Article addArticle(Article article) throws NoConnectivity {
        articles.put(article.id, article);
        return article;
    }

    public Article getArticle(String id) throws NoConnectivity, ArticleDoesNotExist { 	
        Article article = articles.get(id);
        if (article == null) {
        	throw new ArticleDoesNotExist();
        }

        return article;
    }

    public Collection<Article> getArticles() throws NoConnectivity {  	        
        return articles.values();
    }
}
