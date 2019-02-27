package com.ibm.webapi.data;

import java.util.List;

import com.ibm.webapi.business.Article;
import com.ibm.webapi.business.ArticleDoesNotExist;

public interface DataAccess {
	public Article addArticle(Article article) throws NoConnectivity;
  
    public List<Article> getArticles() throws NoConnectivity;
}