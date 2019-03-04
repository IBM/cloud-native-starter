package com.ibm.webapi.business;

import java.util.ArrayList;
import java.util.List;
import javax.enterprise.context.ApplicationScoped;
import com.ibm.webapi.data.DataAccessManager;
import com.ibm.webapi.data.NoConnectivity;
import org.eclipse.microprofile.faulttolerance.Fallback;

@ApplicationScoped
public class Service {

	private List<Article> lastReadArticles;

	public Service() {
	}

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
			DataAccessManager.getArticlesDataAccess().addArticle(article);
			return article;
		} catch (NoConnectivity e) {
			e.printStackTrace();
			throw new NoDataAccess(e);
		}
	}

	@Fallback(fallbackMethod = "fallbackNoArticlesService")
	public List<Article> getArticles() throws NoDataAccess {
		List<Article> articles = new ArrayList<Article>();	
		List<CoreArticle> coreArticles = new ArrayList<CoreArticle>();	
		
		int requestedAmount = 5; // change to 10 for v2
				
		try {
			coreArticles = DataAccessManager.getArticlesDataAccess().getArticles(requestedAmount);							
		} catch (NoConnectivity e) {
			System.err.println("com.ibm.webapi.business.getArticles: Cannot connect to articles service");
			throw new NoDataAccess(e);
		}		
		
		for (int index = 0; index < coreArticles.size(); index++) {
			CoreArticle coreArticle = coreArticles.get(index);
			Article article = new Article();
			article.id = coreArticle.id;
			article.title = coreArticle.title;
			article.url = coreArticle.url;
			article.authorName = coreArticle.author;
			try {
				Author author = DataAccessManager.getAuthorsDataAccess().getAuthor(coreArticle.author);
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
			articles.add(article);
		}
		lastReadArticles = articles;
				
		return articles;
	}

	public List<Article> fallbackNoArticlesService() {
		System.err.println("com.ibm.webapi.business.fallbackNoArticlesService: Cannot connect to articles service");
		if (lastReadArticles == null) lastReadArticles = new ArrayList<Article>();
		return lastReadArticles;
	}
}
