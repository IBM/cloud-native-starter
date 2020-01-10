package com.ibm.articles.data;

import javax.enterprise.context.ApplicationScoped;
import javax.inject.Inject;
import org.eclipse.microprofile.config.inject.ConfigProperty;

@ApplicationScoped
public class DataAccessManager {

    private static final String USE_IN_MEMORY_STORE = "yes";

    @Inject
	@ConfigProperty(name = "custom.in-memory-store", defaultValue = "yes")
	private String inmemory;

    @Inject
	InMemoryDataAccess inMemoryDataAccess;

    @Inject
	PostgresDataAccess postgresDataAccess;
	
	public DataAccess getDataAccess() { 
        if (inmemory.equalsIgnoreCase(USE_IN_MEMORY_STORE)) {
            return inMemoryDataAccess;                        
        }
        else {
            return postgresDataAccess;
        }
    } 
}
