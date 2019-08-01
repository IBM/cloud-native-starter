package com.ibm.webapi;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.actuate.health.HealthIndicator;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.cloud.gateway.route.RouteLocator;
import org.springframework.cloud.gateway.route.builder.RouteLocatorBuilder;
import org.springframework.context.annotation.Bean;
import org.springframework.web.client.RestTemplate;

@SpringBootApplication
public class WebApiApplication {

	@Value("${articles.base.url}")
	private String articlesSpringBootEndpoint;
	@Value("${authors.base.url}")
	private String authorsSpringBootEndpoint;

	public static void main(String[] args) {
		SpringApplication.run(WebApiApplication.class, args);
	}

	@Bean
	public RouteLocator routes(RouteLocatorBuilder builder) {
		return builder.routes()
				.route(p -> p.path("/getone", "/getmultiple", "/create").uri(articlesSpringBootEndpoint))//
				.route(p -> p.path("/getauthor").uri(authorsSpringBootEndpoint)).build();
	}
}
