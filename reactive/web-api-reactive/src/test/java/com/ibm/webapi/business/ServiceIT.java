package com.ibm.webapi.business;

import com.ibm.webapi.data.ArticlesDataAccess;
import com.ibm.webapi.data.AuthorsDataAccess;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.mockito.Mockito;

import java.util.List;
import java.util.concurrent.CompletableFuture;
import java.util.concurrent.CompletionStage;
import java.util.concurrent.locks.LockSupport;

import static org.mockito.ArgumentMatchers.anyInt;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.Mockito.mock;

/**
 * Integration test to verify that the reactive data types are setup correctly, i.e. that we fully make use of parallel execution.
 */
class ServiceIT {

    private Service testObject;

    @BeforeEach
    void setUp() {
        testObject = new Service();
        testObject.managedExecutor = new TestManagedExecutor();

        testObject.authorsDataAccess = mock(AuthorsDataAccess.class);
        testObject.articlesDataAccess = mock(ArticlesDataAccess.class);

        Mockito.when(testObject.authorsDataAccess.getAuthorReactive(anyString())).then(invocationOnMock -> {
            System.out.println("getAuthorReactive: " + invocationOnMock.getArgument(0));
            return CompletableFuture.runAsync(() -> LockSupport.parkNanos(1_000_000_000L))
                    .thenApply(ignored -> author(invocationOnMock.getArgument(0, String.class)));
        });
        Mockito.when(testObject.articlesDataAccess.getArticlesReactive(anyInt())).then(invocationOnMock -> {
            System.out.println("getArticlesReactive");
            return CompletableFuture.runAsync(() -> LockSupport.parkNanos(1_000_000_000L))
                    .thenApply(ignored -> articles());
        });
    }

    private Author author(String name) {
        Author author = new Author();
        author.name = name;
        author.blog = "https://" + name.replace(' ', '-').toLowerCase() + ".com";
        author.twitter = "@" + name.replace(" ", "");
        return author;
    }

    private List<CoreArticle> articles() {
        return List.of(
                article("Foobar", "foo", "John Doe"),
                article("Foobar 2", "foo", "Jane Doe"),
                article("Foobar 3", "foo", "James Doe")
        );
    }

    private CoreArticle article(String title, String url, String author) {
        CoreArticle article = new CoreArticle();
        article.title = title;
        article.url = url;
        article.author = author;
        return article;
    }

    @Test
    void testGetArticlesReactive() {
        long start = System.currentTimeMillis();
        CompletionStage<List<Article>> articlesReactive = testObject.getArticlesReactive();
        System.out.println("Took " + (System.currentTimeMillis() - start) + "ms");

        start = System.currentTimeMillis();
        List<Article> articles = articlesReactive.toCompletableFuture().join();
        System.out.println("Took " + (System.currentTimeMillis() - start) + "ms");

        articles.forEach(a -> System.out.printf("%s by %s (%s, %s)\n", a.title, a.authorName, a.authorTwitter, a.authorBlog));
    }

}