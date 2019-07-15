package com.ibm.webapi;

public class Article {

	public String id;
	public String title;
	public String url;
	public String authorName;
	public String authorTwitter;
	public String authorBlog;

	public Article() {
	}

	public String getId() {
		return id;
	}

	public void setId(String id) {
		this.id = id;
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

	public String getAuthorName() {
		return authorName;
	}

	public void setAuthorName(String authorName) {
		this.authorName = authorName;
	}

	public String getAuthorTwitter() {
		return authorTwitter;
	}

	public void setAuthorTwitter(String authorTwitter) {
		this.authorTwitter = authorTwitter;
	}

	public String getAuthorBlog() {
		return authorBlog;
	}

	public void setAuthorBlog(String authorBlog) {
		this.authorBlog = authorBlog;
	}

}
