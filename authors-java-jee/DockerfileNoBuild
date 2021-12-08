FROM open-liberty:21.0.0.12-full-java11-openj9

COPY liberty/server.xml /config/

COPY target/authors.war /config/apps/

# This script will add the requested XML snippets, grow image to be fit-for-purpose and apply interim fixes
# https://github.com/WASdev/ci.docker
RUN configure.sh

EXPOSE 3000