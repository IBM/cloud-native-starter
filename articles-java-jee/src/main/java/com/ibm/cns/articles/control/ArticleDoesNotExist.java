package com.ibm.cns.articles.control;

import javax.ws.rs.WebApplicationException;
import javax.ws.rs.core.Response;

public class ArticleDoesNotExist extends WebApplicationException {

    public ArticleDoesNotExist(String message) {
        super(Response.status(204).header("info", "message").build());
	}
}
