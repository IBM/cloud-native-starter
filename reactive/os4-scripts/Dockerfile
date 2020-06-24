FROM postgres:12 
# https://hub.docker.com/_/postgres
# Create the needed temp file before the first postgresSQL execution
RUN mkdir temp
# Create group and user
RUN groupadd non-root-postgres-group
RUN useradd non-root-postgres-user --group non-root-postgres-group
# Set user rights to allow the on-root-postgres-user to access the temp folder
RUN chown -R non-root-postgres-user:non-root-postgres-group /temp
RUN chmod 777 /temp
# Change to non-root privilege
USER non-root-postgres
