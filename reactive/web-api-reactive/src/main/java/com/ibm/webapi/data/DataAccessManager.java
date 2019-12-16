package com.ibm.webapi.data;

import javax.enterprise.context.ApplicationScoped;

@ApplicationScoped
public class DataAccessManager {
	
	public static ArticlesDataAccess getArticlesDataAccess() { 
        if (singletonArticles == null) { 
        	singletonArticles = new ArticlesServiceDataAccess(); 
        } 
        return singletonArticles; 
    } 
	
	private static ArticlesDataAccess singletonArticles = null; 
	
	public static AuthorsDataAccess getAuthorsDataAccess() { 
        if (singletonAuthors == null) { 
        	singletonAuthors = new AuthorsServiceDataAccess(); 
        } 
        return singletonAuthors; 
    } 
	
	private static AuthorsDataAccess singletonAuthors = null; 
}
