package com.ibm.webapi.business;

import java.util.List;
import javax.enterprise.context.ApplicationScoped;
import com.ibm.webapi.data.DataAccessManager;
import com.ibm.webapi.data.NoConnectivity;

@ApplicationScoped
public class Service {

	public static Service getService() {
		if (singleton == null) {
			singleton = new Service();
		}
		return singleton;
	}

	private static Service singleton = null;

	private Service() {
	}

	public Article addArticle(String title, String url, String author) throws NoDataAccess, InvalidArticle {
		if (title == null)
			throw new InvalidArticle();

		long id = new java.util.Date().getTime();
		String idAsString = String.valueOf(id);

		if (url == null)
			url = "Unknown";
		if (author == null)
			author = "Unknown";

		Article article = new Article();
		article.title = title;
		article.id = idAsString;
		article.url = url;
		article.author = author;

		try {
			DataAccessManager.getDataAccess().addArticle(article);
			return article;
		} catch (NoConnectivity e) {
			e.printStackTrace();
			throw new NoDataAccess(e);
		}
	}

	public List<Article> getArticles() throws NoDataAccess {
		
		int requestedAmount = 5; // change to 10 for v2
				
		try {
			return DataAccessManager.getDataAccess().getArticles(requestedAmount);			
		} catch (NoConnectivity e) {
			e.printStackTrace();
			throw new NoDataAccess(e);
		}
	}
}
