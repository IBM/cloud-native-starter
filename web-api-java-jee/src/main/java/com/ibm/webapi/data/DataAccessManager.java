package com.ibm.webapi.data;

import javax.enterprise.context.ApplicationScoped;

@ApplicationScoped
public class DataAccessManager {
	
	public static DataAccess getDataAccess() { 
        if (singleton == null) { 
        	singleton = new InMemoryDataAccess(); 
        } 
        return singleton; 
    } 
	
	private static DataAccess singleton = null; 
}
