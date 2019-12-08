package com.ibm.cns.articles.entity;

public class NoConnectivity extends Exception {

	private static final long serialVersionUID = 1L;

	public NoConnectivity() {
	}

	public NoConnectivity(String message) {
		super(message);
	}
}
