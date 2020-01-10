package com.ibm.articles.data;

import java.util.List;

import com.ibm.articles.business.Article;
import com.ibm.articles.business.ArticleDoesNotExist;
import java.util.concurrent.CompletableFuture;

public interface DataAccess {
	public Article addArticle(Article article) throws NoConnectivity;
    
    public Article getArticle(String id) throws NoConnectivity, ArticleDoesNotExist;
    
    public List<Article> getArticles() throws NoConnectivity;

    
    public CompletableFuture<Article> addArticleReactive(Article article);

    public CompletableFuture<Article> getArticleReactive(String id);

    public CompletableFuture<List<Article>> getArticlesReactive();
}