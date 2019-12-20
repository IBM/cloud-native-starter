package com.ibm.webapi.data;

import com.ibm.webapi.business.Author;
import com.ibm.webapi.business.NonexistentAuthor;

import org.eclipse.microprofile.rest.client.RestClientBuilder;

import java.net.MalformedURLException;
import java.net.URL;
import java.net.URLEncoder;
import javax.enterprise.context.ApplicationScoped;

@ApplicationScoped
public class AuthorsServiceDataAccess implements AuthorsDataAccess {
	
	static final String BASE_URL = "http://authors:3000/api/v1/";
	
	public AuthorsServiceDataAccess() {
	}	

	public Author getAuthor(String name) throws NoConnectivity, NonexistentAuthor {
		try {
			name = URLEncoder.encode(name, "UTF-8").replace("+", "%20");
			URL apiUrl = new URL(BASE_URL + "getauthor?name=" + name);
			AuthorsService customRestClient = RestClientBuilder.newBuilder().baseUrl(apiUrl)
					.register(ExceptionMapperAuthors.class).build(AuthorsService.class);
			
			Author output = customRestClient.getAuthor(name);
			return output;
	
		} catch (MalformedURLException e) {
			throw new NoConnectivity(e);
		} catch (NonexistentAuthor e) {
			e.printStackTrace();
			throw new NonexistentAuthor(e);			
		} catch (Exception e) {
			throw new NoConnectivity(e);
		}
	}
}