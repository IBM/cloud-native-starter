package com.ibm.articles.data;

public class NoConnectivity extends Exception {

	private static final long serialVersionUID = 1L;

	public NoConnectivity() {
	}

	public NoConnectivity(String message) {
		super(message);
	}
}
