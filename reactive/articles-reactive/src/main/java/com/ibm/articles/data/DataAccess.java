package com.ibm.articles.data;

import com.ibm.articles.business.Article;
import com.ibm.articles.business.ArticleDoesNotExist;

import java.util.List;
import java.util.concurrent.CompletionStage;

public interface DataAccess {

    Article addArticle(Article article) throws NoConnectivity;

    Article getArticle(String id) throws NoConnectivity, ArticleDoesNotExist;

    List<Article> getArticles() throws NoConnectivity;

    CompletionStage<Article> addArticleReactive(Article article);

    CompletionStage<Article> getArticleReactive(String id);

    CompletionStage<List<Article>> getArticlesReactive();
}