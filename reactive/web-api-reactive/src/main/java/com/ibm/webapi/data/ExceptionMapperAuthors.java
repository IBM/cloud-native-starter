package com.ibm.webapi.data;

import com.ibm.webapi.business.NonexistentAuthor;
import org.eclipse.microprofile.rest.client.ext.ResponseExceptionMapper;

import javax.ws.rs.core.MultivaluedMap;
import javax.ws.rs.core.Response;
import javax.ws.rs.ext.Provider;

@Provider
public class ExceptionMapperAuthors implements ResponseExceptionMapper<NonexistentAuthor> {

    @Override
    public boolean handles(int status, MultivaluedMap<String, Object> headers) {
        return status == 204;
    }

    @Override
    public NonexistentAuthor toThrowable(Response response) {
        if (response.getStatus() == 204)
            return new NonexistentAuthor();
        return null;
    }

}
