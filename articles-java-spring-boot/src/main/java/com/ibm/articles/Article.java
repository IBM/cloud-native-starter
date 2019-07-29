package com.ibm.articles;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.Id;
import javax.persistence.Table;

import com.fasterxml.jackson.annotation.JsonGetter;
import com.fasterxml.jackson.annotation.JsonIgnore;

import io.swagger.annotations.ApiModelProperty;
import io.swagger.annotations.ApiModelProperty.AccessMode;

@Entity
@Table(name = "Article")
public class Article {

	@GeneratedValue(strategy = GenerationType.AUTO)
	@Id
	@Column(name = "articleId")
	@ApiModelProperty(accessMode=AccessMode.READ_ONLY, dataType="String", notes="READ ONLY")
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

	@JsonGetter("id")//Returning Stringified id for API compatibility with MicroProfile service.  
	public String getStringId() {
		return Integer.toString(id);
	}
	
	@JsonIgnore//Id is a generated field, this prevents jackson from setting an user defined value
	private void setId(int id) {
		//NO-OP
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
