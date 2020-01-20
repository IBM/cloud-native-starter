package com.ibm.articles.business;

public class InvalidArticle extends RuntimeException {

	private static final long serialVersionUID = 2L;

	public InvalidArticle() {
	}

	public InvalidArticle(String message) {
		super(message);
	}
}