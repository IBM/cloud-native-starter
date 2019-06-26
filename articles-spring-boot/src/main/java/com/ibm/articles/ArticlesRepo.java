package com.ibm.articles;

import org.springframework.data.repository.PagingAndSortingRepository;

public interface ArticlesRepo extends PagingAndSortingRepository<Article, Integer> {

	
}
