package com.ibm.webapi.business;

import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.List;
import javax.enterprise.context.ApplicationScoped;
import javax.inject.Inject;
import org.eclipse.microprofile.config.inject.ConfigProperty;

import com.ibm.webapi.data.DataAccess;
import com.ibm.webapi.data.DataAccessManager;
import com.ibm.webapi.data.InMemoryDataAccess;
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
		
		int requestedAmount = 5;
		
		List<Article> articles;
		try {
			articles = DataAccessManager.getDataAccess().getArticles();
			Comparator<Article> comparator = new Comparator<Article>() {
				@Override
				public int compare(Article left, Article right) {
					try {
						int leftDate = Integer.valueOf(left.id.substring(6));
						int rightDate = Integer.valueOf(right.id.substring(6));
						return rightDate - leftDate;
					} catch (NumberFormatException e) {
						return 0;
					}
				}
			};
			Collections.sort(articles, comparator);

			int amount = articles.size();
			if (amount > requestedAmount) {
				amount = requestedAmount;
				List<Article> output = new ArrayList<Article>(amount);
				for (int index = 0; index < amount; index++) {
					output.add(articles.get(index));
				}
				articles = output;
			}
			return articles;
		} catch (NoConnectivity e) {
			e.printStackTrace();
			throw new NoDataAccess(e);
		}
	}
}
