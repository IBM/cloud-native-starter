package com.ibm.articles.data;

import com.ibm.articles.business.Article;
import com.ibm.articles.business.ArticleDoesNotExist;
import io.vertx.axle.sqlclient.Row;
import io.vertx.axle.sqlclient.RowSet;
import java.util.ArrayList;
import java.util.List;
import javax.annotation.PostConstruct;
import javax.enterprise.context.ApplicationScoped;
import java.util.concurrent.CompletableFuture;
import java.util.concurrent.TimeUnit;
import javax.inject.Inject;

@ApplicationScoped
public class PostgresDataAccess implements DataAccess {

    private static int MAXIMAL_DURATION = 5000;

    @Inject
    io.vertx.axle.pgclient.PgPool client;
    
    public PostgresDataAccess() {		
    }

    @PostConstruct
    void config() {
        initdb();
    }

    private void initdb() {
        client.query("DROP TABLE IF EXISTS articles")
            .thenCompose(r -> client.query("CREATE TABLE articles (id SERIAL PRIMARY KEY, title TEXT NOT NULL, url TEXT, author TEXT, creationdate TEXT)"))
            .exceptionally(throwable -> {
                System.err.println(throwable);
                return null;
            })              
            .toCompletableFuture()
            .join();
    }

    private String generateSQLStatementToInsertArticle(Article article) {
        String statement = "INSERT INTO articles (title, url, author, creationdate) VALUES ('" + article.title + "', '"
            + article.url + "', '" + article.author + "', '" + article.creationDate + "') RETURNING (id)";

        return statement;
    }

    public CompletableFuture<Article> addArticleReactive(Article article) {
        CompletableFuture<Article> future = new CompletableFuture<Article>();

        String statement = generateSQLStatementToInsertArticle(article);
        client.preparedQuery(statement)
            .toCompletableFuture() 
            .orTimeout(MAXIMAL_DURATION, TimeUnit.MILLISECONDS)
            .thenAccept(pgRowSet -> {
                article.id = pgRowSet.iterator().next().getLong("id").toString();
                future.complete(article);
            }).exceptionally(throwable -> {
                future.completeExceptionally(new NoConnectivity());
                return null;
            }); 

        return future;
    }

    public CompletableFuture<Article> getArticleReactive(String id) {
        CompletableFuture<Article> future = new CompletableFuture<Article>();

        String statement = "SELECT id, title, url, author, creationdate FROM articles WHERE id = " + id;
        client.preparedQuery(statement)
            .toCompletableFuture() 
            .orTimeout(MAXIMAL_DURATION, TimeUnit.MILLISECONDS)
            .thenApply(RowSet::iterator) 
            .thenAccept(iterator -> { 
                if (iterator.hasNext()) {
                    Article article = from(iterator.next());
                    future.complete(article);
                }
                else {
                    future.completeExceptionally(new ArticleDoesNotExist());
                }
            }).exceptionally(throwable -> {
                future.completeExceptionally(new NoConnectivity());
                return null;
            }); 
        return future;
    }

    public CompletableFuture<List<Article>> getArticlesReactive() {
        CompletableFuture<List<Article>> future = new CompletableFuture<List<Article>>();

        client.query("SELECT id, title, url, author, creationdate FROM articles ORDER BY id ASC")
            .toCompletableFuture() 
            .orTimeout(MAXIMAL_DURATION, TimeUnit.MILLISECONDS)
            .thenAccept(pgRowSet -> {
                List<Article> list = new ArrayList<>(pgRowSet.size());
                for (Row row : pgRowSet) {
                    list.add(from(row));
                }
                future.complete(list);
            }).exceptionally(throwable -> {
                future.completeExceptionally(new NoConnectivity());
                return null;
            }); 

        return future;
    }

    private static Article from(Row row) {
        Article article = new Article();
        article.id = row.getLong("id").toString();
        article.title = row.getString("title");
        article.author = row.getString("author");
        article.creationDate = row.getString("creationdate");
        article.url = row.getString("url");
        return article;        
    }

    // not supported
    public Article addArticle(Article article) throws NoConnectivity {
        throw new NoConnectivity();
    }

    // not supported
    public Article getArticle(String id) throws NoConnectivity, ArticleDoesNotExist { 	
        throw new NoConnectivity();
    }

    // not supported
    public List<Article> getArticles() throws NoConnectivity { 
        throw new NoConnectivity();
    }
}
