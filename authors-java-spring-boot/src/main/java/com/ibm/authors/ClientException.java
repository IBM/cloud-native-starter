package com.ibm.authors;

public class ClientException extends RuntimeException {

	private static final long serialVersionUID = 1L;

	public ClientException() {
	}

	public ClientException(String message) {
		super(message);
	}

	public ClientException(Throwable cause) {
		super(cause);
	}

	public ClientException(String message, Throwable cause) {
		super(message, cause);
	}

	public ClientException(String message, Throwable cause, boolean enableSuppression, boolean writableStackTrace) {
		super(message, cause, enableSuppression, writableStackTrace);
	}

}
