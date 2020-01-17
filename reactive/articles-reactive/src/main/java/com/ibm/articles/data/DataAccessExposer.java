package com.ibm.articles.data;

import io.quarkus.arc.AlternativePriority;
import org.eclipse.microprofile.config.inject.ConfigProperty;

import javax.enterprise.context.ApplicationScoped;
import javax.enterprise.inject.Produces;
import javax.inject.Inject;

@ApplicationScoped
public class DataAccessExposer {

    private static final String USE_IN_MEMORY_STORE = "yes";

    @Inject
    @ConfigProperty(name = "custom.in-memory-store", defaultValue = USE_IN_MEMORY_STORE)
    private String inmemory;

    @Inject
    InMemoryDataAccess inMemoryDataAccess;

    @Inject
    PostgresDataAccess postgresDataAccess;

    @Produces
    @AlternativePriority(1)
    public DataAccess produceDataAccess() {
        if (inmemory.equalsIgnoreCase(USE_IN_MEMORY_STORE)) {
            return inMemoryDataAccess;
        } else {
            return postgresDataAccess;
        }
    }
}
