in progress .....
===================

First terminal (runs on 8080):

```
$ cd web-app
$ yarn install
$ yarn serve
```

Second terminal (runs on 8081):

```
$ cd web-api-secure
$ mvn clean package quarkus:dev
```

Third terminal (runs on 8082):

```
$ cd articles-secure
$ mvn clean package quarkus:dev
```

Test user: alice, alice
