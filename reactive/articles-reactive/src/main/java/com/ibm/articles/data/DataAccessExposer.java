package com.ibm.articles.data;

import io.quarkus.arc.AlternativePriority;
import org.eclipse.microprofile.config.inject.ConfigProperty;

import javax.enterprise.context.ApplicationScoped;
import javax.enterprise.inject.Produces;
import javax.inject.Inject;

@ApplicationScoped
public class DataAccessExposer {

    @Inject
    @ConfigProperty(name = "custom.in-memory-store", defaultValue = "true")
    boolean inmemory;

    @Inject
    InMemoryDataAccess inMemoryDataAccess;

    @Inject
    PostgresDataAccess postgresDataAccess;

    @Produces
    @AlternativePriority(1)
    public DataAccess produceDataAccess() {
        if (inmemory) {
            return inMemoryDataAccess;
        } else {
            return postgresDataAccess;
        }
    }
}
