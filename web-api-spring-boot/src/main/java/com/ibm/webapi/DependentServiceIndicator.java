package com.ibm.webapi;

import java.util.logging.Logger;

import org.springframework.boot.actuate.health.Health;
import org.springframework.boot.actuate.health.HealthIndicator;
import org.springframework.web.client.RestTemplate;

public class DependentServiceIndicator implements HealthIndicator {
	private static Logger LOGGER = Logger.getLogger(DependentServiceIndicator.class.getName());
	private RestTemplate restTemplate;
	private String baseUrl;
	private static final String HEALTH_ENDPOINT = "/health";

	public DependentServiceIndicator(RestTemplate restTemplate, String articlesHealthEndpoint) {
		this.restTemplate = restTemplate;
		this.baseUrl = articlesHealthEndpoint;
	}

	@Override
	public Health health() {
		try {
			return Health.status(restTemplate.getForObject(baseUrl + HEALTH_ENDPOINT, DependentServiceHealth.class).status)
					.build();
		} catch (Exception e) {
			LOGGER.warning(e.getMessage());
			e.printStackTrace();
			return Health.down().build();
		}
	}

	private static class DependentServiceHealth {
		private String status;

		public void setStatus(String status) {
			this.status = status;
		}
	}

}
