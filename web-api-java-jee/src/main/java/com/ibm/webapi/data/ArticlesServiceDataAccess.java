package com.ibm.webapi.data;

import com.ibm.webapi.business.Article;
import com.ibm.webapi.business.InvalidArticle;

import org.eclipse.microprofile.rest.client.RestClientBuilder;
import org.eclipse.microprofile.rest.client.inject.RestClient;

import java.net.MalformedURLException;
import java.net.URI;
import java.net.URISyntaxException;
import java.net.URL;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Set;

import javax.inject.Inject;
import javax.json.JsonObject;
import javax.ws.rs.ProcessingException;

public class ArticlesServiceDataAccess implements DataAccess {
	
	static final String BASE_URL = "http://articles:9080/articles/v1/";
	
	public ArticlesServiceDataAccess() {
	}	

	public List<Article> getArticles(int amount) throws NoConnectivity {		
		try {
			URL apiUrl = new URL(BASE_URL + "getmultiple?amount=" + amount);
			ArticlesService customRestClient = RestClientBuilder.newBuilder().baseUrl(apiUrl)
					.register(ExceptionMapper.class).build(ArticlesService.class);
			
			// I could not figure out how to get Article objects returned automatically from MicroProfile
			List output = customRestClient.getArticlesFromService();
			return convertToArticleList(output);
	
		} catch (MalformedURLException e) {
			throw new NoConnectivity(e);
		} catch (Exception e) {
			throw new NoConnectivity(e);
		}
	}
	
	public Article addArticle(Article article) throws NoConnectivity, InvalidArticle {
		try {
			URL apiUrl = new URL(BASE_URL + "create");
			ArticlesService customRestClient = RestClientBuilder.newBuilder().baseUrl(apiUrl)
					.register(ExceptionMapper.class).build(ArticlesService.class);
			
			Article output = customRestClient.addArticle(article);
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
	
	private Article convertToArticle(HashMap object) {
		Article article = new Article();
		article.id = object.get("id").toString();
		article.title = object.get("title").toString();
		article.author = object.get("author").toString();
		article.url = object.get("url").toString();
		return article;
	}	
	
	private List<Article> convertToArticleList(List<HashMap> objects) {
		ArrayList<Article> output = new ArrayList<Article>();
		objects.stream().forEach(object -> output.add(convertToArticle(object)));
		return output;
	}
}
