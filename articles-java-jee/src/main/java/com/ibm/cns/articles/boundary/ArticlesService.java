package com.ibm.cns.articles.boundary;

import com.ibm.cns.articles.control.DataAccess;
import com.ibm.cns.articles.control.MPConfigured;
import com.ibm.cns.articles.entity.Article;
import org.eclipse.microprofile.config.inject.ConfigProperty;

import javax.annotation.PostConstruct;
import javax.enterprise.context.ApplicationScoped;
import javax.inject.Inject;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.List;

@ApplicationScoped
public class ArticlesService {

    @Inject
    @ConfigProperty(name = "inmemory", defaultValue = "true")
    boolean inMemory;

    @Inject
    @ConfigProperty(name = "samplescreation", defaultValue = "false")
    boolean samplesCreation;

    @Inject
    @MPConfigured
    DataAccess dataAccess;

    @PostConstruct
    private void addArticles() {
        if (inMemory && samplesCreation)
            addSampleArticles();
    }

    public Article addArticle(Article article) {
        this.dataAccess.addArticle(article);
        return article;
    }

    public Article getArticle(String id) {
        return this.dataAccess.getArticle(id);
    }

    public List<Article> getArticles(int requestedAmount) {
        if (requestedAmount < 0) {
            throw new InvalidInputParamters("Requested article amount is < 0");
        }
        List<Article> articles = this.dataAccess.getArticles();

        Comparator<Article> comparator = new Comparator<Article>() {
            @Override
            public int compare(Article left, Article right) {
                try {
                    int leftDate = Integer.valueOf(left.creationDate.substring(6));
                    int rightDate = Integer.valueOf(right.creationDate.substring(6));
                    return rightDate - leftDate;
                } catch (NumberFormatException e) {
                    return 0;
                }
            }
        };
        Collections.sort(articles, comparator);

        int amount = articles.size();
        if (amount > requestedAmount) {
            amount = requestedAmount;
            List<Article> output = new ArrayList<Article>(amount);
            for (int index = 0; index < amount; index++) {
                output.add(articles.get(index));
            }
            articles = output;
        }
        return articles;
    }

    private void addSampleArticles() {
        System.out.println("com.ibm.articles.business.Service.addSampleArticles");
        try {
            this.addArticle("Blue Cloud Mirror — (Don’t) Open The Doors!",
                    "https://haralduebele.github.io/2019/02/17/blue-cloud-mirror-dont-open-the-doors/", "Harald Uebele");
            Thread.sleep(5);
            this.addArticle("Recent Java Updates from IBM", "http://heidloff.net/article/recent-java-updates-from-ibm",
                    "Niklas Heidloff");
            Thread.sleep(5);
            this.addArticle("Developing and debugging Microservices with Java",
                    "http://heidloff.net/article/debugging-microservices-java-kubernetes", "Niklas Heidloff");
            Thread.sleep(5);
            this.addArticle("IBM announced Managed Istio and Managed Knative",
                    "http://heidloff.net/article/managed-istio-managed-knative", "Niklas Heidloff");
            Thread.sleep(5);
            this.addArticle("Three Minutes Demo of Blue Cloud Mirror",
                    "http://heidloff.net/article/blue-cloud-mirror-demo-video", "Niklas Heidloff");
            Thread.sleep(5);
            this.addArticle("Blue Cloud Mirror Architecture Diagrams",
                    "http://heidloff.net/article/blue-cloud-mirror-architecture-diagrams", "Niklas Heidloff");
            Thread.sleep(5);
            this.addArticle("Three awesome TensorFlow.js Models for Visual Recognition",
                    "http://heidloff.net/article/tensorflowjs-visual-recognition", "Niklas Heidloff");
            Thread.sleep(5);
            this.addArticle("Install Istio and Kiali on IBM Cloud or Minikube",
                    "https://haralduebele.github.io/2019/02/22/install-istio-and-kiali-on-ibm-cloud-or-minikube/", "Harald Uebele");
            Thread.sleep(5);
            this.addArticle("Dockerizing Java MicroProfile Applications",
                    "http://heidloff.net/article/dockerizing-container-java-microprofile", "Niklas Heidloff");
            Thread.sleep(5);
            this.addArticle("Debugging Microservices running in Kubernetes",
                    "http://heidloff.net/article/debugging-microservices-kubernetes", "Niklas Heidloff");
            System.out.println("com.ibm.articles.business.Service.addSampleArticles: Sample articles have been created");
        } catch (InterruptedException e) {
            System.out.println("com.ibm.articles.business.Service.addSampleArticles: Sample articles have NOT been created");
            e.printStackTrace();
        }
    }

    void addArticle(String title, String link, String author) {
        Article article = new Article();
        article.author = author;
        article.title = title;
        article.url = link;
        this.addArticle(article);
    }
}
