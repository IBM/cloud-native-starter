package com.ibm.authors;

import java.util.Optional;

import org.springframework.data.repository.CrudRepository;

public interface AuthorRepo extends CrudRepository<Author, String> {

	public Optional<Author> findByName(String name);

}
