package com.ibm.cns.articles.entity;

import java.io.Serializable;
import javax.persistence.Entity;
import javax.persistence.Table;
import javax.persistence.NamedQuery;
import javax.persistence.GeneratedValue;
import javax.persistence.Id;
import javax.persistence.Column;
import javax.persistence.GenerationType;

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
    private int id;

    @Column(name = "articleTitle")
	private String title;

    @Column(name = "articleUrl")
    private String url;

    @Column(name = "articleAuthor")
    private String author;

    @Column(name = "creationDate")
    private String creationDate;

    public ArticleEntity() {        
    }
    
    public ArticleEntity(String title, String url, String author, String creationDate) {
        this.title = title;
        this.url = url;
        this.author = author;
        this.creationDate = creationDate;
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getCreationDate() {
        return this.creationDate;
    }

    public void setCreationDate(String creationDate) {
        this.creationDate = creationDate;
    }

    public String getTitle() {
        return title;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public void setUrl(String url) {
        this.url = url;
    }

    public String getUrl() {
        return url;
    }

    public void setAuthor(String author) {
        this.author = author;
    }

    public String getAuthor() {
        return author;
    }

    @Override
    public boolean equals(Object obj) {
        if (this == obj) {
            return true;
        }
        if (obj == null) {
            return false;
        }
        if (getClass() != obj.getClass()) {
            return false;
        }
        ArticleEntity other = (ArticleEntity) obj;
        if (url == null) {
            if (other.url != null) {
                return false;
            }
        } else if (!url.equals(other.url)) {
            return false;
        }
        if (title == null) {
            if (other.title != null) {
                return false;
            }
        } else if (!title.equals(other.title)) {
            return false;
        }
        if (creationDate == null) {
            if (other.creationDate != null) {
                return false;
            }
        } else if (!creationDate.equals(other.creationDate)) {
            return false;
        }
        if (author == null) {
            if (other.author != null) {
                return false;
            }
        } else if (!author.equals(other.author)) {
            return false;
        }

        return true;
    }

    @Override
    public String toString() {
        return "Article [title=" + title + ", url=" + url + ", author=" + author + "]";
    }
}