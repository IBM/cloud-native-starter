package com.ibm.webapi.data;

import com.ibm.webapi.business.Author;
import com.ibm.webapi.business.NonexistentAuthor;
import java.util.concurrent.CompletableFuture;
import java.util.concurrent.TimeUnit;
import org.eclipse.microprofile.rest.client.RestClientBuilder;
import java.net.MalformedURLException;
import java.net.URL;
import java.net.URLEncoder;
import javax.enterprise.context.ApplicationScoped;
import org.eclipse.microprofile.config.inject.ConfigProperty;
import javax.inject.Inject;
import io.vertx.axle.core.Vertx;
import io.vertx.axle.ext.web.client.WebClient;
import io.vertx.ext.web.client.WebClientOptions;
import javax.annotation.PostConstruct;

@ApplicationScoped
public class AuthorsServiceDataAccess implements AuthorsDataAccess {
	
	public AuthorsServiceDataAccess() {
	}	

	private static int MAXIMAL_DURATION = 5000;

	static String AUTHORS_DNS = "authors";
	static String AUTHORS_PORT = "3000";
	
	@ConfigProperty(name = "cloud-native-starter.local")
	String LOCAL_MODE;

	@ConfigProperty(name = "cloud-native-starter.minikube.ip")
	String MINIKUBE_IP;

	@ConfigProperty(name = "cloud-native-starter.authors.port", defaultValue = "3000")
	String AUTHORS_LOCAL_PORT;

	@Inject
	Vertx vertx;

	private WebClient client;

	@PostConstruct
    void initialize() {		
		if (LOCAL_MODE.equalsIgnoreCase("true")) {
			AUTHORS_DNS = MINIKUBE_IP;
			AUTHORS_PORT = AUTHORS_LOCAL_PORT;
		}

		int authorsPortInt = 8080;
		try {
			authorsPortInt = Integer.parseInt(AUTHORS_PORT);
		}
		catch(Exception e) {
		}
        this.client = WebClient.create(vertx,
                new WebClientOptions().setDefaultHost(AUTHORS_DNS).setDefaultPort(authorsPortInt).setSsl(false));
    }

	public Author getAuthor(String name) throws NoConnectivity, NonexistentAuthor {
		try {
			name = URLEncoder.encode(name, "UTF-8").replace("+", "%20");
			URL apiUrl = new URL("http://" + AUTHORS_DNS + ":" + AUTHORS_PORT + "/api/v1/getauthor?name=" + name);
			System.out.println(apiUrl);
			AuthorsService customRestClient = RestClientBuilder.newBuilder().baseUrl(apiUrl)
					.register(ExceptionMapperAuthors.class).build(AuthorsService.class);
			
			Author output = customRestClient.getAuthor();
			return output;
	
		} catch (MalformedURLException e) {
			throw new NoConnectivity(e);
		} catch (NonexistentAuthor e) {
			e.printStackTrace();
			throw new NonexistentAuthor(e);			
		} catch (Exception e) {
			throw new NoConnectivity(e);
		}
	}

	public CompletableFuture<Author> getAuthorReactive(String name) {
		CompletableFuture<Author> future = new CompletableFuture<>();
		
		try {
			name = URLEncoder.encode(name, "UTF-8").replace("+", "%20");
		}
		catch (Exception e) {}
		this.client.get("/api/v1/getauthor?name=" + name)
			.send()
			.toCompletableFuture() 
			.orTimeout(MAXIMAL_DURATION, TimeUnit.MILLISECONDS)
			.thenAccept(resp -> {
				if (resp.statusCode() == 200) {
					Author author = this.convertJsonToAuthor(resp.bodyAsJsonObject());
					future.complete(author);
				} else {
					if (resp.statusCode() == 204) {
						future.completeExceptionally(new NonexistentAuthor());
					}
					else {
						future.completeExceptionally(new NoConnectivity());
					}
				}
			}).exceptionally(throwable -> {
				future.completeExceptionally(new NoConnectivity());
				return null;
			});

		return future;
	}

	private Author convertJsonToAuthor(io.vertx.core.json.JsonObject jsonObject) {
		Author author = new Author();
		author.blog = jsonObject.getString("blog", "");
		author.name = jsonObject.getString("name", "");
		author.twitter = jsonObject.getString("twitter", "");
		return author;
	}
}