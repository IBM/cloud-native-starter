package com.ibm.webapi.apis;

import javax.enterprise.context.RequestScoped;
import javax.inject.Inject;
import javax.json.JsonObject;
import javax.ws.rs.*;
import javax.ws.rs.core.MediaType;
import javax.ws.rs.core.Response;
import javax.json.Json;
import org.eclipse.microprofile.openapi.annotations.Operation;
import org.eclipse.microprofile.openapi.annotations.responses.APIResponses;
import org.eclipse.microprofile.openapi.annotations.responses.APIResponse;
import org.eclipse.microprofile.openapi.annotations.media.Content;
import org.eclipse.microprofile.openapi.annotations.media.Schema;
import org.eclipse.microprofile.jwt.JsonWebToken;

@RequestScoped
@Path("/v1")
public class Manage {

	@Inject
  private JsonWebToken jwtPrincipal;

	@POST
	@Path("/manage")
	@Produces(MediaType.APPLICATION_JSON)
	@APIResponses(value = {
			@APIResponse(responseCode = "200", description = "Manage application", 
				content = @Content(mediaType = "application/json", schema = @Schema(implementation = ManageResponse.class))),			
			@APIResponse(responseCode = "401", description = "Not authorized") })
	@Operation(summary = "Manage application", description = "Manage application")
	public Response getArticles() {
		System.out.println("com.ibm.web-api.apis.GetArticles.getArticles");
		
		System.out.println(this.jwtPrincipal.getName());
		System.out.println(this.jwtPrincipal);

		// to be done
		// throw 401 if user is not admin@demo.email
		
		JsonObject output = Json.createObjectBuilder().add("message", "success").build();
		
		return Response.ok(output).build();
	}
}
