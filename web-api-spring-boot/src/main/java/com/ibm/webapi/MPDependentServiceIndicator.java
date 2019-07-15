package com.ibm.webapi;

import org.springframework.boot.actuate.health.Health;
import org.springframework.boot.actuate.health.HealthIndicator;
import org.springframework.web.client.RestTemplate;

public class MPDependentServiceIndicator implements HealthIndicator {

	private RestTemplate restTemplate;
	private String healthEndpoint;

	public MPDependentServiceIndicator(RestTemplate restTemplate, String articlesHealthEndpoint) {
		this.restTemplate = restTemplate;
		this.healthEndpoint = articlesHealthEndpoint;
	}

	@Override
	public Health health() {
		MicroProfileHealth health = restTemplate.getForObject(healthEndpoint, MicroProfileHealth.class);
		if (health.isUp()) {
			return Health.up().build();
		} else {
			return Health.down().build();
		}
	}

	private class MicroProfileHealth {
		private static final String UP = "UP";
		private String outcome;

		public boolean isUp() {
			return outcome != null && outcome.equalsIgnoreCase(UP);
		}

		public void setOutcome(String outcome) {
			this.outcome = outcome;
		}
	}
}
