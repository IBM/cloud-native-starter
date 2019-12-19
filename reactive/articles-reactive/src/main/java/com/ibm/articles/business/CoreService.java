package com.ibm.articles.business;

import com.ibm.articles.data.DataAccessManager;
import com.ibm.articles.data.NoConnectivity;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.List;
import javax.annotation.PostConstruct;
import javax.enterprise.context.ApplicationScoped;
import javax.inject.Inject;
import org.eclipse.microprofile.config.inject.ConfigProperty;
import java.util.concurrent.CompletableFuture;
import java.util.concurrent.CompletionStage;
import io.vertx.axle.core.Vertx;

@ApplicationScoped
public class CoreService {

	private static final String CREATE_SAMPLES = "CREATE";
	private static final String USE_IN_MEMORY_STORE = "USE_IN_MEMORY_STORE";

	@Inject
	Vertx vertx;
	
	@Inject
	@ConfigProperty(name = "inmemory", defaultValue = USE_IN_MEMORY_STORE)
	private String inmemory;

	@Inject
	@ConfigProperty(name = "samplescreation", defaultValue = "dontcreate")
	private String samplescreation;

	@Inject
	private DataAccessManager dataAccessManager;

	@PostConstruct
	private void addArticles() {
		//if (inmemory.equalsIgnoreCase(USE_IN_MEMORY_STORE)) {
			//if (samplescreation.equalsIgnoreCase(CREATE_SAMPLES))
				addSampleArticles();
		//}
	}

	public Article addArticle(String title, String url, String author) throws NoDataAccess, InvalidArticle {
		if (title == null)
			throw new InvalidArticle();

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

		try {
			dataAccessManager.getDataAccess().addArticle(article);
			return article;
		} catch (NoConnectivity e) {
			e.printStackTrace();
			throw new NoDataAccess(e);
		}
	}

	public Article getArticle(String id) throws NoDataAccess, ArticleDoesNotExist {
		Article article;
		try {
			article = dataAccessManager.getDataAccess().getArticle(id);
			return article;
		} catch (NoConnectivity e) {
			e.printStackTrace();
			throw new NoDataAccess(e);
		}
	}

	public List<Article> getArticles(int requestedAmount) throws NoDataAccess, InvalidInputParamters {
		if (requestedAmount < 0)
			throw new InvalidInputParamters();
		List<Article> articles;
		try {
			articles = dataAccessManager.getDataAccess().getArticles();

			articles = dataAccessManager.getDataAccess().getArticles();

			articles = this.sortArticles(articles);
			articles = this.applyAmountFilter(articles, requestedAmount);

			return articles;
		} catch (NoConnectivity e) {
			e.printStackTrace();
			throw new NoDataAccess(e);
		}
	}

	public CompletionStage<List<Article>> getArticlesReactive(int requestedAmount) {
		CompletableFuture<List<Article>> future = new CompletableFuture<>();

		if (requestedAmount < 0) {
			future.completeExceptionally(new InvalidInputParamters());
		}
		else {
			dataAccessManager.getDataAccess().getArticlesReactive().thenApplyAsync(articles -> {
				articles = this.sortArticles(articles);
				articles = this.applyAmountFilter(articles, requestedAmount);

				return articles;
			}).whenComplete((articles, throwable) -> {
				future.complete(articles);          
			});
		}

        return future;
	}

	private List<Article> sortArticles(List<Article> articles) {
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
		return articles;
	}

	private List<Article> applyAmountFilter(List<Article> articles, int requestedAmount) {
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
					"https://haralduebele.blog/2019/02/17/blue-cloud-mirror-dont-open-the-doors/", "Harald Uebele");
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
					"https://haralduebele.blog/2019/02/22/install-istio-and-kiali-on-ibm-cloud-or-minikube/", "Harald Uebele");
			Thread.sleep(5);
			this.addArticle("Dockerizing Java MicroProfile Applications",
					"http://heidloff.net/article/dockerizing-container-java-microprofile", "Niklas Heidloff");
			Thread.sleep(5);
			this.addArticle("Debugging Microservices running in Kubernetes",
					"http://heidloff.net/article/debugging-microservices-kubernetes", "Niklas Heidloff");
			System.out.println("com.ibm.articles.business.Service.addSampleArticles: Sample articles have been created");
		} catch (NoDataAccess | InvalidArticle | InterruptedException e) {
			System.out.println("com.ibm.articles.business.Service.addSampleArticles: Sample articles have NOT been created");
			e.printStackTrace();
		}
	}
}
