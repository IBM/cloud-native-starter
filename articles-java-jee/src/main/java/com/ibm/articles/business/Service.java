package com.ibm.articles.business;

import com.ibm.articles.data.DataAccessManager;
import com.ibm.articles.data.NoConnectivity;
import java.util.Collection;

import javax.enterprise.context.ApplicationScoped;

@ApplicationScoped
public class Service {

    public Article addArticle(String title, String url, String author) throws NoDataAccess, InvalidArticle {
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
        
        try {
        	DataAccessManager.getDataAccess().addArticle(article);
			return article;
		} catch (NoConnectivity e) {
			e.printStackTrace();
			throw new NoDataAccess(e);		
		}
    }

    public Article getArticle(String id) throws NoDataAccess, ArticleDoesNotExist { 	
        Article article;
		try {
			article = DataAccessManager.getDataAccess().getArticle(id);
			return article;
		} catch (NoConnectivity e) {
			e.printStackTrace();
			throw new NoDataAccess(e);	
		} 
    }

    public Collection<Article> getArticles() throws NoDataAccess {  	        
    	Collection<Article> articles;
		try {
			articles = DataAccessManager.getDataAccess().getArticles();
			return articles;

		} catch (NoConnectivity e) {
			e.printStackTrace();
			throw new NoDataAccess(e);	
		}
	}
}
