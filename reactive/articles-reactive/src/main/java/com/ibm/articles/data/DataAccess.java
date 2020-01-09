package com.ibm.articles.data;

import java.util.List;

import com.ibm.articles.business.Article;
import com.ibm.articles.business.ArticleDoesNotExist;
import java.util.concurrent.CompletionStage;

public interface DataAccess {
	public Article addArticle(Article article) throws NoConnectivity;
    
    public Article getArticle(String id) throws NoConnectivity, ArticleDoesNotExist;
    
    public List<Article> getArticles() throws NoConnectivity;

    
    public CompletionStage<Article> addArticleReactive(Article article);

    public CompletionStage<Article> getArticleReactive(String id);

    public CompletionStage<List<Article>> getArticlesReactive();
}