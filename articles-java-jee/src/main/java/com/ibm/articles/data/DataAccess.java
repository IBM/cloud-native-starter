package com.ibm.articles.data;

import java.util.Collection;

import com.ibm.articles.business.Article;
import com.ibm.articles.business.ArticleDoesNotExist;

public interface DataAccess {
	public Article addArticle(Article article) throws NoConnectivity;

    public Article getArticle(String id) throws NoConnectivity, ArticleDoesNotExist;
    
    public Collection<Article> getArticles() throws NoConnectivity;
}