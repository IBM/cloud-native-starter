FROM maven:3.6-jdk-8 as BUILD
 
COPY src /usr/src/app/src
COPY pom.xml /usr/src/app
WORKDIR /usr/src/app
RUN mvn package

FROM open-liberty:springBoot2-java8-openj9  as staging
COPY  --from=BUILD --chown=1001:0 /usr/src/app/target/authors.jar \
                    /staging/fat-authors.jar
RUN springBootUtility thin \
 --sourceAppPath=/staging/fat-authors.jar \
 --targetThinAppPath=/staging/authors.jar \
 --targetLibCachePath=/staging/lib.index.cache

# Build the image only copying the lib.index.cache and the thin application
FROM open-liberty:springBoot2-java8-openj9 
COPY --chown=1001:0 src/main/liberty/config/server.xml /config
COPY --from=staging /staging/lib.index.cache /lib.index.cache
COPY --from=staging /staging/authors.jar \
                    /config/apps/authors.jar