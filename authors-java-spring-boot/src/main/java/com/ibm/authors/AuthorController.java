package com.ibm.authors;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import io.swagger.annotations.ApiOperation;
import io.swagger.annotations.ApiResponse;
import io.swagger.annotations.ApiResponses;

@RestController
public class AuthorController {

	private AuthorService service;

	public AuthorController(AuthorService service) {
		this.service = service;
	}

	@ApiOperation(value = "Get specific article")
	@ApiResponses({ @ApiResponse(code = 200, message = "Author with requested name", response = Author.class),
			@ApiResponse(code = 404, message = "Author Not Found"),
			@ApiResponse(code = 500, message = "Internal service error", response = String.class) })
	@GetMapping(value = "/getauthor", params = "name", produces = "application/json")
	public ResponseEntity<Author> getAuthor(@RequestParam(name="name", required = true) String name) {
		return ResponseEntity.ok(service.getAuthorByName(name));
	}
}
