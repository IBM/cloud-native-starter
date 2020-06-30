package com.ibm.authentication;

import javax.inject.Inject;
import javax.ws.rs.GET;
import javax.ws.rs.Path;
import javax.ws.rs.Produces;
import javax.ws.rs.core.MediaType;
import org.eclipse.microprofile.jwt.JsonWebToken;
import io.quarkus.oidc.IdToken;
import io.quarkus.oidc.RefreshToken;

@Path("/")
public class UserResource {

    @Inject
    @IdToken
    JsonWebToken idToken;

    @Inject
    JsonWebToken accessToken;

    @Inject
    RefreshToken refreshToken;

    @GET
    @Path("/user")
    @Produces(MediaType.APPLICATION_JSON)
    public String getUserName() {
        Object userName = this.idToken.getClaim("preferred_username");
        return "{ \"userName\" : " + "\"" + userName + "\"" + " }";
    }
}