package com.ibm.webapi.data;

import org.eclipse.microprofile.config.inject.ConfigProperty;
import com.ibm.webapi.business.CoreArticle;
import com.ibm.webapi.business.InvalidArticle;
import org.eclipse.microprofile.rest.client.RestClientBuilder;
import java.net.MalformedURLException;
import java.net.URL;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import javax.inject.Inject;
import io.vertx.axle.core.Vertx;
import java.util.concurrent.CompletionStage;
import javax.enterprise.context.ApplicationScoped;
import io.vertx.axle.ext.web.client.WebClient;
import io.vertx.core.json.JsonObject;
import io.vertx.ext.web.client.WebClientOptions;
import javax.annotation.PostConstruct;
import java.util.concurrent.CompletableFuture;

@ApplicationScoped
public class ArticlesServiceDataAccess implements ArticlesDataAccess {
	
	public ArticlesServiceDataAccess() {
	}	

	static String ARTICLES_DNS = "articles-reactive";
	static String ARTICLES_PORT = "8080";
	
	@ConfigProperty(name = "cloud-native-starter.local")
	String LOCAL_MODE;

	@ConfigProperty(name = "cloud-native-starter.minikube.ip")
	String MINIKUBE_IP;

	@ConfigProperty(name = "cloud-native-starter.articles.port", defaultValue = "8080")
	String ARTICLES_LOCAL_PORT;

	@Inject
	Vertx vertx;

	private WebClient client;

	@PostConstruct
    void initialize() {		
		if (LOCAL_MODE.equalsIgnoreCase("true")) {
			ARTICLES_DNS = MINIKUBE_IP;
			ARTICLES_PORT = ARTICLES_LOCAL_PORT;
		}

		int articlesPortInt = 8080;
		try {
			articlesPortInt = Integer.parseInt(ARTICLES_PORT);
		}
		catch(Exception e) {
		}
        this.client = WebClient.create(vertx,
                new WebClientOptions().setDefaultHost(ARTICLES_DNS).setDefaultPort(articlesPortInt).setSsl(false));
    }

	public List<CoreArticle> getArticles(int amount) throws NoConnectivity {		
		try {
			URL apiUrl = new URL("http://" + ARTICLES_DNS + ":" + ARTICLES_PORT + "/v1/articles?amount=" + amount);
			System.out.println(apiUrl);
			ArticlesService customRestClient = RestClientBuilder.newBuilder().baseUrl(apiUrl)
					.register(ExceptionMapperArticles.class).build(ArticlesService.class);
			
			// not sure why the conversion is not done automatically
			// as workaround the output is converted manually
			List output = customRestClient.getArticlesFromService();
			return convertToArticleList(output);
	
		} catch (MalformedURLException e) {
			throw new NoConnectivity(e);
		} catch (Exception e) {
			throw new NoConnectivity(e);
		}
	}

	public CompletableFuture<List<CoreArticle>> getArticlesReactive(int amount) {		
		CompletableFuture<List<CoreArticle>> future = new CompletableFuture<>();

		this.client.get("/v2/articles?amount=" + amount)
			.send()
			.thenAcceptAsync(resp -> {
				if (resp.statusCode() == 200) {
					List<CoreArticle> articles = this.convertJsonToCoreArticleList(resp.bodyAsJsonArray());
					future.complete(articles);
				} else {
					future.completeExceptionally(new NoConnectivity());
				}
			}).exceptionally(throwable -> {
				future.completeExceptionally(new NoConnectivity());
				return null;
			});

		return future;
	}

	private CoreArticle convertJsonToCoreArticle(io.vertx.core.json.JsonObject jsonObject) {
		CoreArticle article = new CoreArticle();
		article.id = jsonObject.getString("id", "");
		article.author = jsonObject.getString("author", "");
		article.title = jsonObject.getString("title", "");
		article.url = jsonObject.getString("url", "");
		return article;
	}

	private List<CoreArticle> convertJsonToCoreArticleList(io.vertx.core.json.JsonArray jsonArray) {
		List<CoreArticle> articles = new ArrayList<CoreArticle>();
		if (jsonArray != null) {
			List list = jsonArray.getList();
			for (int index = 0; index < list.size(); index++) {
				io.vertx.core.json.JsonObject object = new JsonObject((Map<String, Object>) list.get(index));
				articles.add(this.convertJsonToCoreArticle(object));
			}
		}
		return articles;
	}

	public CoreArticle addArticle(CoreArticle article) throws NoConnectivity, InvalidArticle {
		try {
			URL apiUrl = new URL("http://" + ARTICLES_DNS + ":" + ARTICLES_PORT + "/v1/articles");
			ArticlesService customRestClient = RestClientBuilder.newBuilder().baseUrl(apiUrl)
					.register(ExceptionMapperArticles.class).build(ArticlesService.class);
			
			CoreArticle output = customRestClient.addArticle(article);
			return output;
	
		} catch (MalformedURLException e) {
			throw new NoConnectivity(e);
		} catch (InvalidArticle e) {
			e.printStackTrace();
			throw new InvalidArticle(e);			
		} catch (Exception e) {
			throw new NoConnectivity(e);
		}
	}
	
	private CoreArticle convertToArticle(HashMap object) {
		CoreArticle article = new CoreArticle();
		article.id = object.get("id").toString();
		article.title = object.get("title").toString();
		article.author = object.get("author").toString();
		article.url = object.get("url").toString();
		return article;
	}	
	
	private List<CoreArticle> convertToArticleList(List<HashMap> objects) {
		ArrayList<CoreArticle> output = new ArrayList<CoreArticle>();
		objects.stream().forEach(object -> output.add(convertToArticle(object)));
		return output;
	}
}
