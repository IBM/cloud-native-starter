package com.ibm.cns.articles.control;

import javax.enterprise.context.ApplicationScoped;
import javax.enterprise.inject.Produces;
import javax.inject.Inject;
import org.eclipse.microprofile.config.inject.ConfigProperty;

@ApplicationScoped
public class DataAccessFacade {

    private static final String USE_IN_MEMORY_STORE = "USE_IN_MEMORY_STORE";

    @Inject
    @ConfigProperty(name = "inmemory", defaultValue = USE_IN_MEMORY_STORE)
    private String inmemory;

    @Inject
    InMemoryDataAccess inMemoryDataAccess;

    @Inject
    JPADataAccess jPADataAccess;

    @Produces
    @MPConfigured
    public DataAccess getDataAccess() {

        if (inmemory.equalsIgnoreCase(USE_IN_MEMORY_STORE)) {
            return inMemoryDataAccess;
        } else {
            return jPADataAccess;
        }
    }
}
