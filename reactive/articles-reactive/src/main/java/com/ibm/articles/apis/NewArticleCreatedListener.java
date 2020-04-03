package com.ibm.articles.apis;

import io.quarkus.vertx.ConsumeEvent;
import io.vertx.core.Vertx;
import io.vertx.kafka.client.producer.KafkaProducer;
import io.vertx.kafka.client.producer.KafkaProducerRecord;
import org.eclipse.microprofile.config.inject.ConfigProperty;

import javax.annotation.PostConstruct;
import javax.enterprise.context.ApplicationScoped;
import javax.inject.Inject;
import java.util.HashMap;
import java.util.Map;

@ApplicationScoped
public class NewArticleCreatedListener {

    @Inject
    Vertx vertx;

    @ConfigProperty(name = "kafka.bootstrap.servers")
    String kafkaBootstrapServer;

    private KafkaProducer<String, String> producer;

    @PostConstruct
    void initKafkaClient() {
        Map<String, String> config = new HashMap<>();
        config.put("bootstrap.servers", kafkaBootstrapServer);
        config.put("key.serializer", "org.apache.kafka.common.serialization.StringSerializer");
        config.put("value.serializer", "org.apache.kafka.common.serialization.StringSerializer");
        System.out.println("bootstrapping Kafka with config: " + config);

        producer = KafkaProducer.create(vertx, config);
    }

    @ConsumeEvent
    public void sendMessageToKafka(String articleId) {
        try {
            KafkaProducerRecord<String, String> record = KafkaProducerRecord.create("new-article-created", articleId);
            producer.write(record, done -> System.out.println("Kafka message sent: new-article-created - " + articleId));
        } catch (Exception e) {
            // allow to run this functionality if Kafka hasn't been set up
        }
    }
}
