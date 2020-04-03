package com.ibm.articles.data;

import com.ibm.articles.business.Article;
import com.ibm.articles.business.ArticleDoesNotExist;
import org.eclipse.microprofile.context.ManagedExecutor;

import javax.enterprise.context.ApplicationScoped;
import javax.inject.Inject;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.concurrent.CompletableFuture;
import java.util.concurrent.CompletionStage;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.TimeUnit;

@ApplicationScoped
public class InMemoryDataAccess implements DataAccess {

    private static final int DELAY = 50;
    private static final int MAXIMAL_DURATION = 5000;

    private Map<String, Article> articles = new ConcurrentHashMap<>();

    @Inject
    ManagedExecutor managedExecutor;

    @Override
    public Article addArticle(Article article) {
        simulateDBAccess();
        articles.put(article.id, article);
        return article;
    }

    @Override
    public Article getArticle(String id) throws ArticleDoesNotExist {
        simulateDBAccess();

        Article article = articles.get(id);
        if (article == null)
            throw new ArticleDoesNotExist();

        return article;
    }

    @Override
    public List<Article> getArticles() {
        simulateDBAccess();
        return new ArrayList<>(articles.values());
    }

    @Override
    public CompletionStage<List<Article>> getArticlesReactive() {
        return CompletableFuture.supplyAsync(this::getArticles, managedExecutor)
                .orTimeout(MAXIMAL_DURATION, TimeUnit.MILLISECONDS);
    }

    @Override
    public CompletionStage<Article> addArticleReactive(Article article) {
        return CompletableFuture.supplyAsync(() -> addArticle(article), managedExecutor)
                .orTimeout(MAXIMAL_DURATION, TimeUnit.MILLISECONDS);
    }

    @Override
    public CompletionStage<Article> getArticleReactive(String id) {
        return CompletableFuture.supplyAsync(() -> getArticle(id), managedExecutor)
                .orTimeout(MAXIMAL_DURATION, TimeUnit.MILLISECONDS);
    }

    private void simulateDBAccess() {
        try {
            TimeUnit.MILLISECONDS.sleep(DELAY);
        } catch (InterruptedException e) {
            // continue anyway
        }
    }

}
