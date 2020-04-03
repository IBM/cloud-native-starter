package com.ibm.webapi.business;

import com.ibm.webapi.data.ArticlesDataAccess;
import com.ibm.webapi.data.AuthorsDataAccess;
import com.ibm.webapi.data.NoConnectivity;
import org.eclipse.microprofile.context.ManagedExecutor;
import org.eclipse.microprofile.faulttolerance.Fallback;
import org.eclipse.microprofile.faulttolerance.Timeout;

import javax.enterprise.context.ApplicationScoped;
import javax.inject.Inject;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.concurrent.CompletionStage;
import java.util.function.BiConsumer;
import java.util.stream.Collectors;

@ApplicationScoped
public class Service {

    private List<Article> lastReadArticles;

    // v1 requests five articles
    // v2 requests ten articles
    private int requestedAmount = 5;

    @Inject
    ArticlesDataAccess articlesDataAccess;

    @Inject
    AuthorsDataAccess authorsDataAccess;

    @Inject
    ManagedExecutor managedExecutor;

    public CoreArticle addArticle(String title, String url, String author) throws NoDataAccess, InvalidArticle {
        if (title == null)
            throw new InvalidArticle();

        String id = String.valueOf(System.currentTimeMillis());
        if (url == null)
            url = "Unknown";
        if (author == null)
            author = "Unknown";

        CoreArticle article = new CoreArticle();
        article.title = title;
        article.id = id;
        article.url = url;
        article.author = author;

        try {
            return articlesDataAccess.addArticle(article);
        } catch (NoConnectivity e) {
            e.printStackTrace();
            throw new NoDataAccess(e);
        }
    }

    @Timeout(20000) // set high for load tests
    @Fallback(fallbackMethod = "fallbackNoArticlesService")
    public List<Article> getArticles() throws NoDataAccess {
        try {
            List<CoreArticle> coreArticles = articlesDataAccess.getArticles(requestedAmount);
            List<Article> articles = createArticleList(coreArticles);

            addAuthors(articles);
            lastReadArticles = articles;

            return articles;
        } catch (NoConnectivity e) {
            System.err.println("com.ibm.webapi.business.getArticles: Cannot connect to articles service");
            throw new NoDataAccess(e);
        }
    }

    private List<Article> createArticleList(List<CoreArticle> coreArticles) {
        return coreArticles.stream()
                .map(coreArticle -> {
                    Article article = new Article();
                    article.id = coreArticle.id;
                    article.title = coreArticle.title;
                    article.url = coreArticle.url;
                    article.authorName = coreArticle.author;
                    article.authorBlog = "";
                    article.authorTwitter = "";
                    return article;
                }).collect(Collectors.toList());
    }

    private void addAuthors(List<Article> articles) {
        articles.forEach(article -> {
            try {
                Author author = authorsDataAccess.getAuthor(article.authorName);
                article.authorBlog = author.blog;
                article.authorTwitter = author.twitter;
            } catch (NoConnectivity e) {
                System.err.println("com.ibm.webapi.business.getArticles: Cannot connect to authors service");
                article.authorBlog = "";
                article.authorTwitter = "";
            } catch (NonexistentAuthor e) {
                article.authorBlog = "";
                article.authorTwitter = "";
            }
        });
    }

    public List<Article> fallbackNoArticlesService() {
        System.err.println("com.ibm.webapi.business.fallbackNoArticlesService: Cannot connect to articles service");
        if (lastReadArticles == null)
            lastReadArticles = new ArrayList<>();
        return lastReadArticles;
    }

    public CompletionStage<List<Article>> getArticlesReactive() {
        return articlesDataAccess.getArticlesReactive(requestedAmount)
                .thenApply(this::createArticleList)
                .thenCompose(this::addAuthorsReactive)
                .exceptionally(e -> {
                    e.printStackTrace();
                    if (lastReadArticles == null)
                        throw new NoDataAccess();
                    return lastReadArticles;
                })
                .whenComplete((articles, e) -> {
                    if (articles != null)
                        lastReadArticles = articles;
                });
    }

    private CompletionStage<List<Article>> addAuthorsReactive(List<Article> articles) {
        List<CompletionStage<Author>> futuresOfAuthor = articles.stream()
                .map(this::fetchAuthorsReactive)
                .collect(Collectors.toList());

        return transform(futuresOfAuthor)
                .thenApply(authors -> merge(articles, authors));
    }

    private CompletionStage<Author> fetchAuthorsReactive(Article article) {
        return authorsDataAccess.getAuthorReactive(article.authorName)
                .exceptionally(throwable -> {
                    System.err.println("com.ibm.webapi.business.getArticles: Could not get author: " + throwable);
                    return new Author();
                });
    }

    private CompletionStage<List<Author>> transform(List<CompletionStage<Author>> authors) {
        BiConsumer<CompletionStage<List<Author>>, CompletionStage<Author>> accumulator = (csl, csa) -> {
            csl.thenCombine(csa, (list, author) -> {
                list.add(author);
                return list;
            }).toCompletableFuture().join();
        };

        BiConsumer<CompletionStage<List<Author>>, CompletionStage<List<Author>>> combiner = (l1, l2) -> l1.thenCombine(l2, (as1, as2) -> {
            as1.addAll(as2);
            return as1;
        });

        return authors.stream().collect(() -> managedExecutor.supplyAsync(ArrayList::new),
                accumulator,
                combiner);
    }

    private List<Article> merge(List<Article> articles, List<Author> authors) {
        Map<String, Author> authorsMap = authors.stream()
                .collect(Collectors.toMap(a -> a.name, a -> a, (oldV, newV) -> newV));

        articles.forEach(article -> merge(article, authorsMap.get(article.authorName)));
        return articles;
    }

    private void merge(Article article, Author author) {
        if (author == null) {
            article.authorBlog = "";
            article.authorTwitter = "";
        } else {
            article.authorBlog = author.blog;
            article.authorTwitter = author.twitter;
        }
    }

}
