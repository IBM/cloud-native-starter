package com.ibm.webapi.data;

import java.util.List;
import com.ibm.webapi.business.Article;
import com.ibm.webapi.business.InvalidArticle;

public interface DataAccess {
	public Article addArticle(Article article) throws NoConnectivity, InvalidArticle;
  
    public List<Article> getArticles(int amount) throws NoConnectivity;
}