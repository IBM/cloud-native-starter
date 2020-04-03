package com.ibm.cns.articles.control;

public class NoDataAccess extends Exception {

	private static final long serialVersionUID = 1L;

	public NoDataAccess() {
	}

	public NoDataAccess(String message) {
		super(message);
	}
	
	public NoDataAccess(Throwable cause) {
		super(cause);
	}
}
