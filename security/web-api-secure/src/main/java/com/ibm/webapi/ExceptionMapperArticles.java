package com.ibm.webapi;

import com.ibm.webapi.InvalidArticle;
import org.eclipse.microprofile.rest.client.ext.ResponseExceptionMapper;

import javax.ws.rs.core.MultivaluedMap;
import javax.ws.rs.core.Response;
import javax.ws.rs.ext.Provider;

@Provider
public class ExceptionMapperArticles implements ResponseExceptionMapper<InvalidArticle> {

    @Override
    public boolean handles(int status, MultivaluedMap<String, Object> headers) {
        return status == 204;
    }

    @Override
    public InvalidArticle toThrowable(Response response) {
        if (response.getStatus() == 204)
            return new InvalidArticle();
        return null;
    }

}
