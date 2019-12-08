package com.ibm.cns.articles.entity;

import java.io.Serializable;
import javax.json.Json;
import javax.json.JsonObject;
import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.Id;
import javax.persistence.NamedQuery;
import javax.persistence.Table;

@Entity(name = "Article")
@Table(name = "Article")
@NamedQuery(name = "Article.findAll", query = "SELECT e FROM Article e")
@NamedQuery(name = "Article.findArticle", query = "SELECT a FROM Article a WHERE "
    + "a.title = :title AND a.url = :url AND a.author = :author")
public class ArticleEntity implements Serializable {
    private static final long serialVersionUID = 1L;

    @GeneratedValue(strategy = GenerationType.AUTO)
    @Id
    @Column(name = "articleId")
    public int id;

    @Column(name = "articleTitle")
    public String title;

    @Column(name = "articleUrl")
    public String url;

    @Column(name = "articleAuthor")
    public String author;

    @Column(name = "creationDate")
    public String creationDate;

    public ArticleEntity() {        
    }
    
    public ArticleEntity(String title, String url, String author, String creationDate) {
        this.title = title;
        this.url = url;
        this.author = author;
        this.creationDate = creationDate;
    }

    public JsonObject toJSON() {
        return Json.createObjectBuilder().add("id", this.id).add("title", this.title).add("url", this.url)
                .add("author", this.author).build();
    }


    @Override
    public String toString() {
        return "Article [title=" + title + ", url=" + url + ", author=" + author + "]";
    }
}