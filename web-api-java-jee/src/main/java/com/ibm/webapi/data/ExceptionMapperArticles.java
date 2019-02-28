package com.ibm.webapi.data;

import javax.ws.rs.core.MultivaluedMap;
import javax.ws.rs.core.Response;
import javax.ws.rs.ext.Provider;
import org.eclipse.microprofile.rest.client.ext.ResponseExceptionMapper;
import com.ibm.webapi.business.InvalidArticle;

@Provider
public class ExceptionMapper implements ResponseExceptionMapper<InvalidArticle> {

	@Override
	public boolean handles(int status, MultivaluedMap<String, Object> headers) {
		return status == 204;
	}

	@Override
	public InvalidArticle toThrowable(Response response) {
		switch (response.getStatus()) {
		case 204:
			return new InvalidArticle();
		}
		return null;
	}
}
