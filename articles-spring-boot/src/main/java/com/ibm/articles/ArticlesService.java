package com.ibm.articles;

import org.springframework.data.querydsl.QPageRequest;

public class ArticlesService {

	private ArticlesRepo repo;
	
	public Iterable<Article> getMultipleArticles(int amount) {
		return repo.findAll(new QPageRequest(1, amount));
	}

	public Article getArticle() {
		// TODO Auto-generated method stub
		return null;
	}

	public Article createArticle(Article article) {
		// TODO Auto-generated method stub
		return null;
	}

}
