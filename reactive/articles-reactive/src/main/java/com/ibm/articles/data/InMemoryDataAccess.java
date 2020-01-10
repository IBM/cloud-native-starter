package com.ibm.articles.data;

import com.ibm.articles.business.Article;
import com.ibm.articles.business.ArticleDoesNotExist;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.TimeUnit;
import java.util.ArrayList;
import java.util.List;
import javax.enterprise.context.ApplicationScoped;
import java.util.concurrent.CompletableFuture;
import java.util.concurrent.CompletionStage;
import io.vertx.axle.core.Vertx;
import javax.inject.Inject;

@ApplicationScoped
public class InMemoryDataAccess implements DataAccess {

    private Map<String, Article> articles;

    @Inject
    Vertx vertx;

    public InMemoryDataAccess() {
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

    public CompletableFuture<List<Article>> getArticlesReactive() {
        CompletableFuture<List<Article>> future = new CompletableFuture<List<Article>>();

        CompletableFuture.supplyAsync(() -> {
            // simulate database access
            try {
                TimeUnit.MILLISECONDS.sleep(50);
            } catch (InterruptedException e) {
            }
            return null;
        }).thenAccept(nothing -> {
            List<Article> articlesList = new ArrayList<Article>(articles.values());
            future.complete(articlesList);
        }).orTimeout(5000, TimeUnit.MILLISECONDS)
        .exceptionally(throwable -> {
            future.completeExceptionally(new NoConnectivity());
            return null;
        });

        return future;
    }

    public CompletableFuture<Article> addArticleReactive(Article article) {
        CompletableFuture<Article> future = new CompletableFuture<Article>();

        CompletableFuture.supplyAsync(() -> {
            // simulate database access
            try {
                TimeUnit.MILLISECONDS.sleep(50);
            } catch (InterruptedException e) {
            }
            return null;
        }).thenAccept(nothing -> {
            articles.put(article.id, article);
            future.complete(article);
        }).orTimeout(5000, TimeUnit.MILLISECONDS)
        .exceptionally(throwable -> {
            future.completeExceptionally(new NoConnectivity());
            return null;
        });

        return future;
    }

    public CompletableFuture<Article> getArticleReactive(String id) {
        CompletableFuture<Article> future = new CompletableFuture<Article>();

        CompletableFuture.supplyAsync(() -> {
            // simulate database access
            try {
                TimeUnit.MILLISECONDS.sleep(50);
            } catch (InterruptedException e) {
            }
            return null;
        }).thenAccept(nothing -> {
            Article article = articles.get(id);
            if (article == null) {
                future.completeExceptionally(new ArticleDoesNotExist());
            }
            else {
                future.complete(article);
            }
        }).orTimeout(5000, TimeUnit.MILLISECONDS)
        .exceptionally(throwable -> {
            future.completeExceptionally(new NoConnectivity());
            return null;
        });

        return future;
    }
}
