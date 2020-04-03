package com.ibm.articles.business;

public class InvalidInputParameter extends RuntimeException {

	private static final long serialVersionUID = 2L;

	public InvalidInputParameter() {
	}

	public InvalidInputParameter(String message) {
		super(message);
	}
}