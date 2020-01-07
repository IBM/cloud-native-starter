package com.ibm.articles.data;

import com.ibm.articles.business.Article;
import com.ibm.articles.business.ArticleDoesNotExist;
import io.vertx.axle.sqlclient.Row;
import java.util.ArrayList;
import java.util.List;
import javax.annotation.PostConstruct;
import javax.enterprise.context.ApplicationScoped;
import java.util.concurrent.CompletableFuture;
import java.util.concurrent.CompletionStage;
import javax.inject.Inject;

@ApplicationScoped
public class PostgresDataAccess implements DataAccess {

    @Inject
    io.vertx.axle.pgclient.PgPool client;
    
    public PostgresDataAccess() {		
    }

    @PostConstruct
    void config() {
        initdb();
    }

    private void initdb() {
        System.out.println("initdb");
        client.query("DROP TABLE IF EXISTS articles")
                .thenCompose(r -> client.query("CREATE TABLE articles (id SERIAL PRIMARY KEY, title TEXT NOT NULL, url TEXT, author TEXT, creationDate TEXT)"))
                .thenCompose(r -> client.query("INSERT INTO articles (title) VALUES ('Orange')"))                
                .toCompletableFuture()
                .join();
        System.out.println("initdb2");
    }

    // not implemented
    public Article addArticle(Article article) throws NoConnectivity {
        return null;
    }

    // not implemented
    public Article getArticle(String id) throws NoConnectivity, ArticleDoesNotExist { 	
        return null;
    }

    // not implemented
    public List<Article> getArticles() throws NoConnectivity {  	        
        return null;
    }

    public CompletionStage<List<Article>> getArticlesReactive() {
        CompletableFuture<List<Article>> future = new CompletableFuture<List<Article>>();

        client.query("SELECT id, title FROM articles ORDER BY title ASC").thenApply(pgRowSet -> {
            List<Article> list = new ArrayList<>(pgRowSet.size());
            for (Row row : pgRowSet) {
                list.add(from(row));
            }
            //future.complete(list);
            return list;
        });

        return future;
    }

    private static Article from(Row row) {
        Article article = new Article();
        article.id = row.getLong("id").toString();
        article.title = row.getString("title");
        return article;        
    }
}
