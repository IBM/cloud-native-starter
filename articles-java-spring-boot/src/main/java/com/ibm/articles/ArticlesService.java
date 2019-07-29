package com.ibm.articles;

import java.util.Optional;

import org.springframework.data.domain.PageRequest;
import org.springframework.stereotype.Service;

@Service
public class ArticlesService {

	private ArticlesRepo repo;

	public ArticlesService(ArticlesRepo repo) {
		this.repo = repo;
	}

	public Iterable<Article> getMultipleArticles(int amount) {
		if (amount > 0) {
			return repo.findAll(PageRequest.of(0, amount)).getContent();
		} else {
			throw new ClientException("Article Not Found");
		}
	}

	public Article getArticle() {
		return null;
	}

	public Article createArticle(Article article) {
		if (article.getTitle().isEmpty()) {
			throw new ClientException("Input not valid (no title)");
		}
		return repo.save(article);
	}

	public Article getArticle(String id) {
		Optional<Article> optionalArticle = repo.findById(Integer.valueOf(id));
		if (optionalArticle.isEmpty()) {
			throw new NotFoundException("Article Not Found");
		} else {
			return optionalArticle.get();
		}
	}

}
