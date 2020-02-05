package com.ibm.cns.articles.control;

import org.eclipse.microprofile.config.inject.ConfigProperty;

import javax.enterprise.context.ApplicationScoped;
import javax.enterprise.inject.Produces;
import javax.inject.Inject;

@ApplicationScoped
public class DataAccessFacade {

    @Inject
    @ConfigProperty(name = "inmemory", defaultValue = "true")
    private boolean inMemory;

    @Inject
    InMemoryDataAccess inMemoryDataAccess;

    @Inject
    JPADataAccess jPADataAccess;

    @Produces
    @MPConfigured
    public DataAccess getDataAccess() {
        if (inMemory)
            return inMemoryDataAccess;
        return jPADataAccess;
    }
}
