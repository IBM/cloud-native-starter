package com.ibm.cns.articles.control;

import javax.ws.rs.WebApplicationException;
import javax.ws.rs.core.Response;

public class NoConnectivity extends WebApplicationException {

	public NoConnectivity(String message) {
            super(Response.status(500).header("info", message).build());
	}
}
