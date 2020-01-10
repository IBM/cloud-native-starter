package com.ibm.articles.apis;

import javax.enterprise.context.ApplicationScoped;
import javax.inject.Inject;
import org.eclipse.microprofile.config.inject.ConfigProperty;
import io.vertx.kafka.client.producer.KafkaProducer;
import io.vertx.kafka.client.producer.KafkaProducerRecord;
import java.util.HashMap;
import java.util.Map;
import io.quarkus.vertx.ConsumeEvent;
import io.vertx.core.Vertx;

@ApplicationScoped
public class NewArticleCreated {

	@Inject
	Vertx vertx;
	
	@ConfigProperty(name = "kafka.bootstrap.servers")
	String kafkaBootstrapServer;

	@ConsumeEvent
	public void sendMessageToKafka(String articleId) {
		try {
			KafkaProducer<String, String> producer;

			Map<String, String> config = new HashMap<>();
			config.put("bootstrap.servers", kafkaBootstrapServer);
			config.put("key.serializer", "org.apache.kafka.common.serialization.StringSerializer");
			config.put("value.serializer", "org.apache.kafka.common.serialization.StringSerializer");										

			producer = KafkaProducer.create(vertx, config);

			KafkaProducerRecord<String, String> record = KafkaProducerRecord.create("new-article-created", articleId);
			producer.write(record, done -> {
				System.out.println("Kafka message sent: new-article-created - " + articleId);
			});
		}
		catch (Exception e) {
			// allow to run this functionality if Kafka hasn't been set up
		}
	}
}
