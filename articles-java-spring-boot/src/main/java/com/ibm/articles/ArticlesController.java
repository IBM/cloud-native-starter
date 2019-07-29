package com.ibm.articles;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import io.swagger.annotations.ApiModel;
import io.swagger.annotations.ApiModelProperty;
import io.swagger.annotations.ApiOperation;
import io.swagger.annotations.ApiResponse;
import io.swagger.annotations.ApiResponses;

@RestController
@RequestMapping("/v1")
public class ArticlesController {

	private ArticlesService service;

	public ArticlesController(ArticlesService service) {
		this.service = service;
	}

	@ApiOperation(value = "Get most recently added articles")
	@ApiResponses({
			@ApiResponse(code = 200, message = "Get most recently added articles", responseContainer = "List", response = Article.class),
			@ApiResponse(code = 204, message = "Input not valid (no amount)", response = String.class),
			@ApiResponse(code = 500, message = "Internal service error", response = String.class) })
	@GetMapping(value = "/getmultiple", params = "amount", produces = "application/json")
	public ResponseEntity<Iterable<Article>> getMultipleArticles(
			@RequestParam(name = "amount", required = true) int amount) {
		return ResponseEntity.ok(service.getMultipleArticles(amount));
	}

	@ApiOperation(value = "Get specific article")
	@ApiResponses({ @ApiResponse(code = 200, message = "Article with requested id", response = Article.class),
			@ApiResponse(code = 404, message = "Article Not Found"),
			@ApiResponse(code = 500, message = "Internal service error", response = String.class) })
	@GetMapping(value = "/getone", params = "id", produces = "application/json")
	public ResponseEntity<Article> getSingleArticle(@RequestParam(name = "id", required = true) String id) {
		return ResponseEntity.ok(service.getArticle(id));
	}

	@ApiOperation(value = "Create a new article")
	@ApiResponses({ @ApiResponse(code = 201, message = "Article has been created", response = Article.class),
			@ApiResponse(code = 204, message = "Input not valid (no title)", response = String.class),
			@ApiResponse(code = 500, message = "Internal service error", response = String.class) })
	@PostMapping(value = "/create", consumes = "application/json",  produces = "application/json")
	public ResponseEntity<Article> createNewArticle(@RequestBody Article article) {
		return ResponseEntity.status(HttpStatus.CREATED).body(service.createArticle(article));
	}

	@ExceptionHandler(ClientException.class)
	public ResponseEntity<String> handleClientExceptions(ClientException e) {
		return ResponseEntity.status(HttpStatus.NO_CONTENT).body(e.getMessage());
	}
	
	@ExceptionHandler(NotFoundException.class)
	public ResponseEntity<String> handleNotFoundException(ClientException e) {
		return ResponseEntity.status(HttpStatus.NOT_FOUND).body(e.getMessage());
	}
}
