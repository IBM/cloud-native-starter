package com.ibm.authors;

import java.util.Optional;

import org.springframework.stereotype.Service;

@Service
public class AuthorService {

	private AuthorRepo repo;

	public AuthorService(AuthorRepo repo) {
		this.repo = repo;
	}

	public Author getAuthorByName(String name) {
		Optional<Author> author = repo.findByName(name);

		if (author.isPresent()) {
			return author.get();
		} else {
			throw new ClientException("Author Not Found");
		}
	}
}
