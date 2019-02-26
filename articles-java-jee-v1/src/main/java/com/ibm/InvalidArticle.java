package com.ibm;

public class InvalidArticle extends Exception {

	private static final long serialVersionUID = 2L;

	public InvalidArticle() {
	}

	public InvalidArticle(String message) {
		super(message);
	}
}