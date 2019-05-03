package com.ibm.articles.data;

import javax.enterprise.context.ApplicationScoped;

@ApplicationScoped
public class DataAccessManager {
	
	public static DataAccess getDataAccess() { 
        if (singleton == null) { 
            singleton = new InMemoryDataAccess(); 
            //singleton = new JPADataAccess(); 
        } 
        return singleton; 
    } 
	
	private static DataAccess singleton = null; 
}
