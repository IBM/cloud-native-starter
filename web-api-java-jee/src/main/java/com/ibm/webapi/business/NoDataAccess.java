package com.ibm.webapi.business;

public class NoDataAccess extends RuntimeException {

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
