package com.ibm.articles.apis;

import javax.inject.Inject;
import javax.ws.rs.*;
import javax.ws.rs.core.MediaType;
import javax.ws.rs.core.Response;

import org.eclipse.microprofile.config.inject.ConfigProperty;
import org.eclipse.microprofile.openapi.annotations.Operation;
import org.eclipse.microprofile.openapi.annotations.responses.APIResponses;
import com.ibm.articles.business.Article;
import com.ibm.articles.business.InvalidArticle;
import com.ibm.articles.business.NoDataAccess;
import org.eclipse.microprofile.openapi.annotations.responses.APIResponse;
import org.eclipse.microprofile.openapi.annotations.media.Content;
import org.eclipse.microprofile.openapi.annotations.media.Schema;
import org.eclipse.microprofile.openapi.annotations.parameters.RequestBody;
import javax.enterprise.context.ApplicationScoped;
import io.vertx.kafka.client.producer.KafkaProducer;
import io.vertx.kafka.client.producer.KafkaProducerRecord;
import io.vertx.core.Vertx;
import java.util.HashMap;
import java.util.Map;

@ApplicationScoped
@Path("/v1")
public class CreateNewArticle {

	@Inject
	ArticleAsJson articleAsJson;
	
	@Inject 
	com.ibm.articles.business.CoreService coreService;

	@Inject
    private Vertx vertx;

	@POST
	@Path("/create")
	@Produces(MediaType.APPLICATION_JSON)
	@Consumes(MediaType.APPLICATION_JSON)
	@APIResponses(value = {
		@APIResponse(
	      responseCode = "204",
	      description = "Input not valid (no title)"
	    ),
	    @APIResponse(
	      responseCode = "201",
	      description = "Article has been created",
	      content = @Content(
	        mediaType = "application/json",
	        schema = @Schema(implementation = Article.class)
	      )
	    ),
	    @APIResponse(
  	      responseCode = "500",
  	      description = "Internal service error"  	      
  	    )
	})
	@Operation(
		    summary = "Create a new article",
		    description = "Create a new article"
	)
	public Response addArticle(@RequestBody(description = "New article", required = true,
            content = @Content(schema = @Schema(implementation = Article.class))) Article newArticle) {
		System.out.println("com.ibm.articles.apis.CreateNewArticle.addArticle");

		String title = newArticle.title;
		String url = newArticle.url;
		String author = newArticle.author;

		Article article;
		try {
			article = coreService.addArticle(title, url, author);

			sendMessageToKafka(article);

			return Response.status(Response.Status.CREATED).entity(articleAsJson.createJson(article)).build();
		} catch (InvalidArticle excpetion) {
			return Response.status(Response.Status.NO_CONTENT).build();
		} catch (NoDataAccess e) {
			e.printStackTrace();
			return Response.status(Response.Status.INTERNAL_SERVER_ERROR).build();
		}
	}

	@ConfigProperty(name = "kafka.bootstrap.servers")
	String kafkaBootstrapServer;

	public void sendMessageToKafka(Article article){
		KafkaProducer<String, String> producer;

		Map<String, String> config = new HashMap<>();
        config.put("bootstrap.servers", kafkaBootstrapServer);
        config.put("key.serializer", "org.apache.kafka.common.serialization.StringSerializer");
		config.put("value.serializer", "org.apache.kafka.common.serialization.StringSerializer");										

		producer = KafkaProducer.create(vertx, config);

		KafkaProducerRecord<String, String> record = KafkaProducerRecord.create("new-article-created", article.id);
		producer.write(record, done -> {
			System.out.println("Kafka message sent: new-article-created - " + article.id);
		});
	}
}