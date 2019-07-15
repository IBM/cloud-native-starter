package com.ibm.webapi;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.actuate.health.HealthIndicator;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.annotation.Bean;
import org.springframework.web.client.RestTemplate;

@SpringBootApplication
public class WebApiApplication {

	private RestTemplate restTemplate = new RestTemplate();
	@Value("${articles.springboot.health.endpoint}")
	private String articlesHealthEndpoint;
	@Value("${authors.springboot.health.endpoint}")
	private String authorsHealthEndpoint;

	public static void main(String[] args) {
		SpringApplication.run(WebApiApplication.class, args);
	}

	@Bean
	public HealthIndicator articlesHealthIndicator() {
		return new DependentServiceIndicator(restTemplate, articlesHealthEndpoint);
	}

	@Bean
	public HealthIndicator authorsHealthIndicator() {
		return new DependentServiceIndicator(restTemplate, authorsHealthEndpoint);
	}
}
