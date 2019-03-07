package com.ibm.articles.business;

import com.ibm.articles.data.DataAccessManager;
import com.ibm.articles.data.NoConnectivity;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.List;
import javax.enterprise.context.ApplicationScoped;
import javax.inject.Inject;
import org.eclipse.microprofile.config.inject.ConfigProperty;

@ApplicationScoped
public class CoreService {

	private static final String CREATE_SAMPLES = "CREATE";

	@Inject
	@ConfigProperty(name = "samplescreation", defaultValue = "dontcreate")
	private String samplescreation;

	public CoreService() {
		if (samplescreation != null) {
			if (samplescreation.equalsIgnoreCase(CREATE_SAMPLES))
				addSampleArticles();
		} else {
			// sometimes MicroProfile does not work. as a workaround the config is read from
			// an environment variable directly
			samplescreation = System.getenv("samplescreation");
			if (samplescreation != null) {
				if (samplescreation.equalsIgnoreCase(CREATE_SAMPLES))
					addSampleArticles();
			}
		}
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
		article.id = idAsString;
		article.url = url;
		article.author = author;

		try {
			DataAccessManager.getDataAccess().addArticle(article);
			return article;
		} catch (NoConnectivity e) {
			e.printStackTrace();
			throw new NoDataAccess(e);
		}
	}

	public Article getArticle(String id) throws NoDataAccess, ArticleDoesNotExist {
		Article article;
		try {
			article = DataAccessManager.getDataAccess().getArticle(id);
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
			articles = DataAccessManager.getDataAccess().getArticles();
			Comparator<Article> comparator = new Comparator<Article>() {
				@Override
				public int compare(Article left, Article right) {
					try {
						int leftDate = Integer.valueOf(left.id.substring(6));
						int rightDate = Integer.valueOf(right.id.substring(6));
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
		} catch (NoConnectivity e) {
			e.printStackTrace();
			throw new NoDataAccess(e);
		}
	}

	private void addSampleArticles() {
		System.out.println("com.ibm.articles.business.Service.addSampleArticles");

		try {
			addArticle("Blue Cloud Mirror — (Don’t) Open The Doors!",
					"https://haralduebele.blog/2019/02/17/blue-cloud-mirror-dont-open-the-doors/", "Harald Uebele");
			Thread.sleep(5);
			addArticle("Recent Java Updates from IBM", "http://heidloff.net/article/recent-java-updates-from-ibm",
					"Niklas Heidloff");
			Thread.sleep(5);
			addArticle("Developing and debugging Microservices with Java",
					"http://heidloff.net/article/debugging-microservices-java-kubernetes", "Niklas Heidloff");
			Thread.sleep(5);
			addArticle("IBM announced Managed Istio and Managed Knative",
					"http://heidloff.net/article/managed-istio-managed-knative", "Niklas Heidloff");
			Thread.sleep(5);
			addArticle("Three Minutes Demo of Blue Cloud Mirror", "http://heidloff.net/article/blue-cloud-mirror-demo-video",
					"Niklas Heidloff");
			Thread.sleep(5);
			addArticle("Blue Cloud Mirror Architecture Diagrams",
					"http://heidloff.net/article/blue-cloud-mirror-architecture-diagrams", "Niklas Heidloff");
			Thread.sleep(5);
			addArticle("Three awesome TensorFlow.js Models for Visual Recognition",
					"http://heidloff.net/article/tensorflowjs-visual-recognition", "Niklas Heidloff");
			Thread.sleep(5);
			addArticle("Install Istio and Kiali on IBM Cloud or Minikube",
					"https://haralduebele.blog/2019/02/22/install-istio-and-kiali-on-ibm-cloud-or-minikube/", "Harald Uebele");
			Thread.sleep(5);
			addArticle("Dockerizing Java MicroProfile Applications",
					"http://heidloff.net/article/dockerizing-container-java-microprofile", "Niklas Heidloff");
			Thread.sleep(5);
			addArticle("Debugging Microservices running in Kubernetes",
					"http://heidloff.net/article/debugging-microservices-kubernetes", "Niklas Heidloff");
			System.out.println("com.ibm.articles.business.Service.addSampleArticles: Sample articles have been created");
		} catch (NoDataAccess | InvalidArticle | InterruptedException e) {
			System.out.println("com.ibm.articles.business.Service.addSampleArticles: Sample articles have NOT been created");
			e.printStackTrace();
		}
	}
}
