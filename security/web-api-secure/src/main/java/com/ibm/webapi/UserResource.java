package com.ibm.webapi;

import javax.annotation.security.RolesAllowed;
import javax.inject.Inject;
import javax.ws.rs.GET;
import javax.ws.rs.Path;
import javax.ws.rs.Produces;
import javax.ws.rs.core.MediaType;
import org.eclipse.microprofile.jwt.JsonWebToken;
import io.quarkus.oidc.IdToken;
import io.quarkus.oidc.RefreshToken;
import io.quarkus.security.Authenticated;

@Path("/")
public class UserResource {

    @Inject
    @IdToken
    JsonWebToken idToken;

    @Inject
    JsonWebToken accessToken;

    //@Inject
    //RefreshToken refreshToken;

    @GET
    @Path("/user")
    //@RolesAllowed("user")
    @Authenticated
    @Produces(MediaType.APPLICATION_JSON)
    public String getUserName() {
        String userName = this.accessToken.getName();
        

        //Object userName = this.idToken.getClaim("preferred_username");
        return "{ \"userName\" : " + "\"" + userName + "\"" + " }";
    }
}