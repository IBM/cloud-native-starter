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

	private RestTemplate restTemplate = new RestTemplate();
	@Value("${articles.springboot.endpoint}")
	private String articlesSpringBootEndpoint;
	@Value("${authors.springboot.endpoint}")
	private String authorsSpringBootEndpoint;
	@Value("${articles.microprofile.endpoint}")
	private String articlesMicroProfileEndpoint;
	@Value("${authors.microprofile.endpoint}")
	private String authorsMicroProfileEndpoint;

	public static void main(String[] args) {
		SpringApplication.run(WebApiApplication.class, args);
	}

	@Bean
	public RouteLocator myRoutes(RouteLocatorBuilder builder) {
		return builder.routes()
				.route(p -> p.path("/v1/getone", "/v1/getmultiple", "/v1/create").uri(articlesSpringBootEndpoint))//
				.route(p -> p.path("/getauthor").uri(authorsSpringBootEndpoint)).build();
	}

	@Bean
	public HealthIndicator articlesSpringBootHealthIndicator() {
		return new DependentServiceIndicator(restTemplate, articlesSpringBootEndpoint);
	}

	@Bean
	public HealthIndicator authorsSpringBootHealthIndicator() {
		return new DependentServiceIndicator(restTemplate, authorsSpringBootEndpoint);
	}

	@Bean
	public HealthIndicator articlesMicroProfileHealthIndicator() {
		return new DependentServiceIndicator(restTemplate, articlesMicroProfileEndpoint);
	}

	@Bean
	public HealthIndicator authorsMicroProfileHealthIndicator() {
		return new DependentServiceIndicator(restTemplate, authorsMicroProfileEndpoint);
	}
}
