package com.ibm.cns.articles.boundary;

import javax.ws.rs.WebApplicationException;
import javax.ws.rs.core.Response;

public class InvalidInputParamters extends WebApplicationException {

	public InvalidInputParamters(String message) {
            super(Response.status(400).header("info", message).build());
	}
}