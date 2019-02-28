package com.ibm.articles.data;

import com.ibm.articles.business.Article;
import javax.inject.Inject;
import org.eclipse.microprofile.config.inject.ConfigProperty;
import com.ibm.articles.business.ArticleDoesNotExist;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;
import java.util.ArrayList;
import java.util.List;

public class HttpDataAccess implements DataAccess {

    private Map<String, Article> articles;

     
    public HttpDataAccess() {
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

    public List<Article> getArticles() throws NoConnectivity {  	        
        return new ArrayList<Article>(articles.values());
    }
}
