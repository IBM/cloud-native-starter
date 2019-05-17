package com.ibm.articles.data;

import javax.enterprise.context.ApplicationScoped;
import javax.inject.Inject;
import javax.annotation.PostConstruct;

@ApplicationScoped
public class DataAccessManager {

    @Inject
	JPADataAccess jPADataAccess;
	
	public DataAccess getDataAccess() { 
        return jPADataAccess;
        /*
        if (singleton == null) { 
            //singleton = new InMemoryDataAccess(); 
            singleton = new JPADataAccess(); 
        } 
        return singleton; */
    } 
	
	//private static DataAccess singleton = null; 
}
