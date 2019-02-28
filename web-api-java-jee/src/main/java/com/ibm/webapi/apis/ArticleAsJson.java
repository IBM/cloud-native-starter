package com.ibm.webapi.apis;

import javax.enterprise.context.ApplicationScoped;
import javax.json.Json;
import javax.json.JsonObject;

import com.ibm.webapi.business.Article;

@ApplicationScoped
public class ArticleAsJson {

	public ArticleAsJson() {}
	
	public JsonObject createJson(Article article) {
		JsonObject output = Json.createObjectBuilder().add("id", article.id).add("title", article.title).add("url", article.url)
				.add("author", article.author).build();
		return output;
	}
}