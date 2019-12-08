package com.ibm.cns.articles.control;

import java.util.List;

import com.ibm.cns.articles.entity.Article;
import com.ibm.cns.articles.entity.Article;

public interface DataAccess {
	public Article addArticle(Article article) throws NoConnectivity;

    public Article getArticle(String id) throws NoConnectivity, ArticleDoesNotExist;
    
    public List<Article> getArticles() throws NoConnectivity;
}