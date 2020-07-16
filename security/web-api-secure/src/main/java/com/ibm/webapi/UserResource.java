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

    /**
     * Injection point for the Access Token issued by the OpenID Connect Provider
     */
    @Inject
    JsonWebToken accessToken;

    /**
     * Injection point for the Refresh Token issued by the OpenID Connect Provider
     */
    @Inject
    RefreshToken refreshToken;

    @GET
    @Path("/user")
    @RolesAllowed("user")
    //@Authenticated
    @Produces(MediaType.APPLICATION_JSON)
    public String getUserName() {
        System.out.println("niklas");
        String userName = this.accessToken.getName();
        //String userName = "tes6t";
        //System.out.println(this.idToken.toString());

        //System.out.println("idToken.getClaim(preferred_username)" + this.idToken.getClaim("preferred_username"));
        

        //Object userName = this.idToken.getClaim("preferred_username");
        return "{ \"userName\" : " + "\"" + userName + "\"" + " }";
    }
}