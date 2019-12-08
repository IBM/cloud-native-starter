package com.ibm.cns.articles.boundary;

public class InvalidInputParamters extends Exception {

	private static final long serialVersionUID = 2L;

	public InvalidInputParamters() {
	}

	public InvalidInputParamters(String message) {
		super(message);
	}
}