package com.ibm.articles.business;

import com.ibm.articles.data.DataAccess;
import com.ibm.articles.data.NoConnectivity;
import io.vertx.axle.core.eventbus.EventBus;
import org.eclipse.microprofile.config.inject.ConfigProperty;

import javax.annotation.PostConstruct;
import javax.enterprise.context.ApplicationScoped;
import javax.inject.Inject;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.List;
import java.util.concurrent.CompletableFuture;
import java.util.concurrent.CompletionStage;

@ApplicationScoped
public class ArticleService {

    private static final String CREATE_SAMPLES = "CREATE";

    private final Comparator<Article> articleComparator = Comparator.comparing((Article a) -> a.creationDate).reversed();

    @Inject
    @ConfigProperty(name = "samplescreation", defaultValue = CREATE_SAMPLES)
    private String samplescreation;

    @Inject
    DataAccess dataAccess;

    @Inject
    EventBus bus;

    @PostConstruct
    private void addArticles() {
        if (samplescreation.equalsIgnoreCase(CREATE_SAMPLES))
            addSampleArticles();
    }

    public Article addArticle(String title, String url, String author) throws NoDataAccess, InvalidArticle {
        if (title == null)
            throw new InvalidArticle();

        Article article = createArticle(title, url, author);

        try {
            dataAccess.addArticle(article);

            sendMessageToKafka(article);

            return article;
        } catch (NoConnectivity e) {
            e.printStackTrace();
            throw new NoDataAccess(e);
        }
    }

    public CompletionStage<Article> addArticleReactive(String title, String url, String author) {
        CompletableFuture<Article> future = new CompletableFuture<>();

        if (title == null) {
            future.completeExceptionally(new InvalidArticle());
        } else {
            Article article = createArticle(title, url, author);
            dataAccess.addArticleReactive(article).thenAccept(newArticle -> {
                sendMessageToKafka(newArticle);
                future.complete(newArticle);
            });
        }
        return future;
    }

    private Article createArticle(String title, String url, String author) {
        long id = new java.util.Date().getTime();
        String idAsString = String.valueOf(id);

        if (url == null)
            url = "Unknown";
        if (author == null)
            author = "Unknown";

        Article article = new Article();
        article.title = title;
        article.creationDate = idAsString;
        article.id = idAsString;
        article.url = url;
        article.author = author;

        return article;
    }

    private void sendMessageToKafka(Article article) {
        bus.publish("com.ibm.articles.apis.NewArticleCreatedListener", article.id);
    }

    public Article getArticle(String id) throws NoDataAccess, ArticleDoesNotExist {
        Article article;
        try {
            article = dataAccess.getArticle(id);
            return article;
        } catch (NoConnectivity e) {
            e.printStackTrace();
            throw new NoDataAccess(e);
        }
    }

    public CompletionStage<Article> getArticleReactive(String id) {
        return dataAccess.getArticleReactive(id);
    }

    public List<Article> getArticles(int requestedAmount) throws NoDataAccess, InvalidInputParameter {
        if (requestedAmount < 0)
            throw new InvalidInputParameter();

        try {
            List<Article> articles = dataAccess.getArticles();
            articles.sort(articleComparator);
            return applyAmountFilter(articles, requestedAmount);

        } catch (NoConnectivity e) {
            e.printStackTrace();
            throw new NoDataAccess(e);
        }
    }

    public CompletionStage<List<Article>> getArticlesReactive(int requestedAmount) {
        if (requestedAmount < 0)
            return CompletableFuture.failedFuture(new InvalidInputParameter());

        return dataAccess.getArticlesReactive()
                .thenApply(articles -> {
                    articles.sort(articleComparator);
                    return applyAmountFilter(articles, requestedAmount);
                });
    }

    private List<Article> applyAmountFilter(List<Article> articles, int requestedAmount) {
        int amount = articles.size();
        if (amount > requestedAmount) {
            amount = requestedAmount;
            List<Article> output = new ArrayList<>(amount);
            for (int index = 0; index < amount; index++) {
                output.add(articles.get(index));
            }
            articles = output;
        }
        return articles;
    }

    private void addSampleArticles() {
        System.out.println("com.ibm.articles.business.Service.addSampleArticles");

        addArticleAndWait("Blue Cloud Mirror — (Don’t) Open The Doors!", "https://haralduebele.blog/2019/02/17/blue-cloud-mirror-dont-open-the-doors/", "Harald Uebele");
        addArticleAndWait("Recent Java Updates from IBM", "http://heidloff.net/article/recent-java-updates-from-ibm", "Niklas Heidloff");
        addArticleAndWait("Developing and debugging Microservices with Java", "http://heidloff.net/article/debugging-microservices-java-kubernetes", "Niklas Heidloff");
        addArticleAndWait("IBM announced Managed Istio and Managed Knative", "http://heidloff.net/article/managed-istio-managed-knative", "Niklas Heidloff");
        addArticleAndWait("Three Minutes Demo of Blue Cloud Mirror", "http://heidloff.net/article/blue-cloud-mirror-demo-video", "Niklas Heidloff");
        addArticleAndWait("Blue Cloud Mirror Architecture Diagrams", "http://heidloff.net/article/blue-cloud-mirror-architecture-diagrams", "Niklas Heidloff");
        addArticleAndWait("Three awesome TensorFlow.js Models for Visual Recognition", "http://heidloff.net/article/tensorflowjs-visual-recognition", "Niklas Heidloff");
        addArticleAndWait("Install Istio and Kiali on IBM Cloud or Minikube", "https://haralduebele.blog/2019/02/22/install-istio-and-kiali-on-ibm-cloud-or-minikube/", "Harald Uebele");
        addArticleAndWait("Dockerizing Java MicroProfile Applications", "http://heidloff.net/article/dockerizing-container-java-microprofile", "Niklas Heidloff");
        addArticleReactive("Debugging Microservices running in Kubernetes", "http://heidloff.net/article/debugging-microservices-kubernetes", "Niklas Heidloff");
    }

    private void addArticleAndWait(String title, String url, String author) {
        try {
            addArticleReactive(title, url, author);
            Thread.sleep(5);
        } catch (InterruptedException e) {
            // continue anyway
        }
    }
}
