package com.ibm.webapi.business;

import java.util.ArrayList;
import java.util.List;
import javax.enterprise.context.ApplicationScoped;
import com.ibm.webapi.data.ArticlesDataAccess;
import com.ibm.webapi.data.AuthorsDataAccess;
import com.ibm.webapi.data.NoConnectivity;
import org.eclipse.microprofile.faulttolerance.Fallback;
import javax.inject.Inject;
import java.util.concurrent.CompletableFuture;
import java.util.concurrent.CompletionStage;

@ApplicationScoped
public class Service {

	private List<Article> lastReadArticles;

	// v1 requests five articles
	// v2 requests ten articles
	private int requestedAmount = 5; 

	public Service() {
	}
	
	@Inject
	ArticlesDataAccess dataAccessArticles;
	
	@Inject
    AuthorsDataAccess dataAccessAuthors;

	public CoreArticle addArticle(String title, String url, String author) throws NoDataAccess, InvalidArticle {
		if (title == null)
			throw new InvalidArticle();

		long id = new java.util.Date().getTime();
		String idAsString = String.valueOf(id);

		if (url == null)
			url = "Unknown";
		if (author == null)
			author = "Unknown";

		CoreArticle article = new CoreArticle();
		article.title = title;
		article.id = idAsString;
		article.url = url;
		article.author = author;

		try {
			dataAccessArticles.addArticle(article);
			return article;
		} catch (NoConnectivity e) {
			e.printStackTrace();
			throw new NoDataAccess(e);
		}
	}

	public List<Article> fallbackNoArticlesService() {
		System.err.println("com.ibm.webapi.business.fallbackNoArticlesService: Cannot connect to articles service");
		if (lastReadArticles == null) lastReadArticles = new ArrayList<Article>();
		return lastReadArticles;
	}

	@Fallback(fallbackMethod = "fallbackNoArticlesService")
	public List<Article> getArticles() throws NoDataAccess {
		List<Article> articles = new ArrayList<Article>();	
		List<CoreArticle> coreArticles = new ArrayList<CoreArticle>();		
				
		try {
			coreArticles = dataAccessArticles.getArticles(requestedAmount);							
		} catch (NoConnectivity e) {
			System.err.println("com.ibm.webapi.business.getArticles: Cannot connect to articles service");
			throw new NoDataAccess(e);
		}		
		
		articles = this.createArticleList(coreArticles);
		articles = this.addAuthors(articles);
		lastReadArticles = articles;
				
		return articles;
	}

	private List<Article> createArticleList(List<CoreArticle> coreArticles) {
		List<Article> articles = new ArrayList<Article>();
		for (int index = 0; index < coreArticles.size(); index++) {
			CoreArticle coreArticle = coreArticles.get(index);
			Article article = new Article();
			article.id = coreArticle.id;
			article.title = coreArticle.title;
			article.url = coreArticle.url;
			article.authorName = coreArticle.author;
			article.authorBlog = "";
			article.authorTwitter = "";
			articles.add(article);
		}
		return articles;
	}

	private List<Article> addAuthors(List<Article> articles) {
		for (int index = 0; index < articles.size(); index++) {
			Article article = articles.get(index);
			try {
				Author author = dataAccessAuthors.getAuthor(article.authorName);
				article.authorBlog = author.blog;
				article.authorTwitter = author.twitter;
			} catch (NoConnectivity e) {	
				System.err.println("com.ibm.webapi.business.getArticles: Cannot connect to authors service");
				article.authorBlog = "";
				article.authorTwitter = "";
			} catch (NonexistentAuthor e) {	
				article.authorBlog = "";
				article.authorTwitter = "";
			}
		}
		return articles;
	}

	int amountReadAuthors;
	private CompletionStage<List<Article>> addAuthorsReactive(List<Article> articles) {
		CompletableFuture<List<Article>> future = new CompletableFuture<>();

		amountReadAuthors = 0;
		int amountArticles = articles.size();
		for (int index = 0; index < articles.size(); index++) {
			Article article = articles.get(index);
			dataAccessAuthors.getAuthorReactive(article.authorName).thenApplyAsync(author -> {
				article.authorTwitter = author.twitter;
				article.authorBlog = author.blog;
				return articles;
			}).exceptionally(throwable -> {
				if (throwable.getCause().toString().equals(NoConnectivity.class.getName().toString())) {
					System.err.println("com.ibm.webapi.business.getArticles: Cannot connect to authors service");
					article.authorTwitter = "";
					article.authorBlog = "";  	
				}
				if (throwable.getCause().toString().equals(NonexistentAuthor.class.getName().toString())) {
					article.authorTwitter = "";
					article.authorBlog = "";  	
				}	
				return articles; 				
			}).whenComplete((articlesWithAuthors, throwable) -> {
				amountReadAuthors++;
				if (amountReadAuthors == amountArticles) {
					future.complete(articlesWithAuthors);
				}
			});
		}
		
		return future;
	}	

	public CompletionStage<List<Article>> getArticlesReactive() {
		CompletableFuture<List<Article>> future = new CompletableFuture<>();
		
		dataAccessArticles.getArticlesReactive(requestedAmount).thenApplyAsync(coreArticles -> {
			List<Article> articles = this.createArticleList(coreArticles);			
			return articles;
		}).thenCompose(articles -> {					
			return this.addAuthorsReactive(articles);
		}).exceptionally(throwable -> {  
			if (lastReadArticles == null) {
				future.completeExceptionally(new NoDataAccess());
				return null; 
			} else {
				return lastReadArticles;
			}
        }).whenComplete((articles, throwable) -> {
			if (articles != null) {
				lastReadArticles = articles;
				future.complete(articles);          
			}
		});

        return future;
	}
}
