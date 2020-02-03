package com.ibm.articles.data;

import com.ibm.articles.business.Article;
import com.ibm.articles.business.ArticleDoesNotExist;
import io.vertx.axle.sqlclient.Row;
import io.vertx.axle.sqlclient.RowIterator;
import io.vertx.axle.sqlclient.Tuple;

import javax.annotation.PostConstruct;
import javax.enterprise.context.ApplicationScoped;
import javax.inject.Inject;
import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.CompletionStage;
import java.util.concurrent.ExecutionException;
import java.util.concurrent.TimeUnit;

@ApplicationScoped
public class PostgresDataAccess implements DataAccess {

    private static int MAXIMAL_DURATION = 5000;

    @Inject
    io.vertx.axle.pgclient.PgPool client;

    public PostgresDataAccess() {
    }

    @PostConstruct
    void config() {
        initDb();
    }

    private void initDb() {
        client.query("DROP TABLE IF EXISTS articles").thenCompose(r -> client.query(
                "CREATE TABLE articles (id SERIAL PRIMARY KEY, title TEXT NOT NULL, url TEXT, author TEXT, creationdate TEXT)"))
                .exceptionally(throwable -> {
                    throwable.printStackTrace();
                    throw new NoConnectivity(throwable);
                })
                .toCompletableFuture().join();
    }

    public CompletionStage<Article> addArticleReactive(Article article) {
        return client.preparedQuery("INSERT INTO articles (title, url, author, creationdate) VALUES ($1, $2, $3, $4) RETURNING (id)",
                Tuple.of(article.title, article.url, article.author, article.creationDate))
                .toCompletableFuture()
                .orTimeout(MAXIMAL_DURATION, TimeUnit.MILLISECONDS)
                .thenApply(pgRowSet -> {
                    article.id = pgRowSet.iterator().next().getLong("id").toString();
                    return article;
                })
                .exceptionally(throwable -> {
                    throw new NoConnectivity();
                });
    }

    public CompletionStage<Article> getArticleReactive(String id) {
        String statement = "SELECT id, title, url, author, creationdate FROM articles WHERE id = $1";
        return client.preparedQuery(statement, Tuple.of(id))
                .toCompletableFuture()
                .orTimeout(MAXIMAL_DURATION, TimeUnit.MILLISECONDS)
                .exceptionally(throwable -> {
                    throw new NoConnectivity();
                }).thenApply(rows -> {
                    RowIterator<Row> iterator = rows.iterator();
                    if (iterator.hasNext()) {
                        return fromRow(iterator.next());
                    }
                    throw new ArticleDoesNotExist();
                });
    }

    public CompletionStage<List<Article>> getArticlesReactive() {
        return client.query("SELECT id, title, url, author, creationdate FROM articles ORDER BY id ASC")
                .toCompletableFuture()
                .orTimeout(MAXIMAL_DURATION, TimeUnit.MILLISECONDS)
                .thenApply(rowSet -> {
                    List<Article> list = new ArrayList<>(rowSet.size());
                    for (Row row : rowSet) {
                        list.add(fromRow(row));
                    }
                    return list;
                }).exceptionally(throwable -> {
                    throw new NoConnectivity();
                });
    }

    private static Article fromRow(Row row) {
        Article article = new Article();
        article.id = row.getLong("id").toString();
        article.title = row.getString("title");
        article.author = row.getString("author");
        article.creationDate = row.getString("creationdate");
        article.url = row.getString("url");
        return article;
    }

    public Article addArticle(Article article) throws NoConnectivity {
        try {
            article = addArticleReactive(article)
                    .toCompletableFuture().get();
            if (article == null)
                throw new NoConnectivity();
            return article;

        } catch (InterruptedException e) {
            // ignored
            throw new NoConnectivity();
        } catch (ExecutionException e) {
            throw new NoConnectivity(e.getCause());
        }
    }

    public Article getArticle(String id) throws NoConnectivity, ArticleDoesNotExist {
        try {
            return getArticleReactive(id).toCompletableFuture().get();

        } catch (InterruptedException e) {
            throw new NoConnectivity();
        } catch (ExecutionException e) {
            if (e.getCause() instanceof ArticleDoesNotExist)
                throw (ArticleDoesNotExist) e.getCause();
            throw new NoConnectivity(e.getCause());
        }
    }

    public List<Article> getArticles() throws NoConnectivity {
        CompletionStage<List<Article>> future = getArticlesReactive();
        try {
            return future.toCompletableFuture().get();
        } catch (InterruptedException | ExecutionException e) {
            throw new NoConnectivity(e.getCause());
        }
    }
}
