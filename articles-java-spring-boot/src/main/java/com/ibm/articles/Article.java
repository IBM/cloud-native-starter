package com.ibm.articles;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.GeneratedValue;
import javax.persistence.Id;
import javax.persistence.SequenceGenerator;
import javax.persistence.Table;

import com.fasterxml.jackson.annotation.JsonGetter;
import com.fasterxml.jackson.annotation.JsonIgnore;

@Entity
@Table(name = "Article")
public class Article {

	@Id
	@Column(name = "articleId")
	@GeneratedValue(generator="articles_generator")
	@SequenceGenerator(name="articles_generator", initialValue = 10)
	private int id;

	@Column(name = "articleTitle")
	private String title;

	@Column(name = "articleUrl")
	private String url;

	@Column(name = "articleAuthor")
	private String author;

	@Column(name = "creationDate")
	private String creationDate;

	public Article() {
	}

	public Article(String title, String url, String author, String creationDate) {
		this.title = title;
		this.url = url;
		this.author = author;
		this.creationDate = creationDate;
	}

	public int getId() {
		return id;
	}

	@JsonGetter("id") // Returning Stringified id for API compatibility with MicroProfile service.
	public String getStringId() {
		return Integer.toString(id);
	}

	@JsonIgnore // Id is a generated field, this prevents jackson from setting an user defined
				// value
	private void setId(int id) {
		// NO-OP
	}

	public String getTitle() {
		return title;
	}

	public void setTitle(String title) {
		this.title = title;
	}

	public String getUrl() {
		return url;
	}

	public void setUrl(String url) {
		this.url = url;
	}

	public String getAuthor() {
		return author;
	}

	public void setAuthor(String author) {
		this.author = author;
	}

	public String getCreationDate() {
		return creationDate;
	}

	public void setCreationDate(String creationDate) {
		this.creationDate = creationDate;
	}

	@Override
	public String toString() {
		return "Article [id=" + id + ", title=" + title + ", url=" + url + ", author=" + author + ", creationDate="
				+ creationDate + "]";
	}

}
