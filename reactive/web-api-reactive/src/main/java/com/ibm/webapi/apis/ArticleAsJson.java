package com.ibm.webapi.apis;

import com.ibm.webapi.business.Article;
import com.ibm.webapi.business.CoreArticle;

import javax.enterprise.context.ApplicationScoped;
import javax.json.Json;
import javax.json.JsonObject;

@ApplicationScoped
public class ArticleAsJson {

    public JsonObject createJsonCoreArticle(CoreArticle article) {
        return Json.createObjectBuilder()
                .add("id", article.id)
                .add("title", article.title)
                .add("url", article.url)
                .add("author", article.author)
                .build();
    }

    public JsonObject createJsonArticle(Article article) {
        return Json.createObjectBuilder()
                .add("id", article.id)
                .add("title", article.title)
                .add("url", article.url)
                .add("authorName", article.authorName)
                .add("authorBlog", article.authorBlog)
                .add("authorTwitter", article.authorTwitter)
                .build();
    }
}