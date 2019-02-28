package com.ibm.webapi.apis;

import javax.enterprise.context.ApplicationScoped;
import javax.json.Json;
import javax.json.JsonObject;

import com.ibm.webapi.business.Article;
import com.ibm.webapi.business.CoreArticle;

@ApplicationScoped
public class ArticleAsJson {

	public ArticleAsJson() {}
	
	public JsonObject createJsonCoreArticle(CoreArticle article) {
		JsonObject output = Json.createObjectBuilder().add("id", article.id).add("title", article.title).add("url", article.url)
				.add("author", article.author).build();
		return output;
	}
	
	public JsonObject createJsonArticle(Article article) {		
		JsonObject output = Json.createObjectBuilder().add("id", article.id).add("title", article.title).add("url", article.url)
				.add("authorName", article.authorName).add("authorBlog", article.authorBlog).add("authorTwitter", article.authorTwitter).build();
		return output;
	}
}