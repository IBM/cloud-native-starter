package com.ibm.webapi.business;

public class NonexistentAuthor extends Exception {

	private static final long serialVersionUID = 2L;

	public NonexistentAuthor() {
	}

	public NonexistentAuthor(String message) {
		super(message);
	}
	
	public NonexistentAuthor(Throwable cause) {
		super(cause);
	}
}