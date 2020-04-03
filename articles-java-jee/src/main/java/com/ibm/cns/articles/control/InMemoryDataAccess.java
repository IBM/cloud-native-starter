package com.ibm.cns.articles.control;

import com.ibm.cns.articles.entity.Article;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;
import javax.enterprise.context.ApplicationScoped;

@ApplicationScoped
public class InMemoryDataAccess implements DataAccess {

    private Map<String, Article> articles;

     
    public InMemoryDataAccess() {
		articles = new ConcurrentHashMap<>();
    }

    public Article addArticle(Article article) throws NoConnectivity {
        long id = new java.util.Date().getTime();
        String idAsString = String.valueOf(id);
        article.creationDate = idAsString;
        if (article.id == 0) {
            idAsString = idAsString.substring(6, idAsString.length());
            try {
                article.id = Integer.parseInt(idAsString);
            }
            catch (Exception parseException) {}
        }
        articles.put(article.getIDAsString(), article);
        return article;
    }

    public Article getArticle(String id) throws NoConnectivity, ArticleDoesNotExist { 	
        Article article = articles.get(id);
        if (article == null) {
            throw new ArticleDoesNotExist("No article found for " + id);
        }

        return article;
    }

    public List<Article> getArticles() throws NoConnectivity {  	        
        return new ArrayList<Article>(articles.values());
    }
}
