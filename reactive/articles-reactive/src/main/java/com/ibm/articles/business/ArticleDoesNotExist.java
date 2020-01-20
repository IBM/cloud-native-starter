package com.ibm.articles.business;

public class ArticleDoesNotExist extends RuntimeException {

	private static final long serialVersionUID = 1L;

	public ArticleDoesNotExist() {
	}

	public ArticleDoesNotExist(String message) {
		super(message);
	}
}
