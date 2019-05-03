package com.ibm.articles.data;

import com.ibm.articles.business.Article;
import javax.inject.Inject;
import com.ibm.articles.business.ArticleDoesNotExist;
import java.util.ArrayList;
import java.util.List;
import javax.enterprise.context.RequestScoped;

@RequestScoped
public class JPADataAccess implements DataAccess {
     
    @Inject
    private ArticleDao articleDAO;

    public JPADataAccess() {
    }

    public Article addArticle(Article article) throws NoConnectivity {
        System.out.println("JPADataAccess.addArticle");
        ArticleEntity newArticle = new ArticleEntity(article.title, article.url, article.author);
        System.out.println("JPADataAccess.addArticle2");
        if (articleDAO == null) {
            System.out.println("JPADataAccess.addArticle null");
        }
        else {
            System.out.println("JPADataAccess.addArticle not null");
        }
        articleDAO.createArticle(newArticle);
        System.out.println("JPADataAccess.addArticle3");
        List<ArticleEntity> articleEntities = articleDAO.findArticle(article.title, article.url, article.author);
        System.out.println("JPADataAccess.addArticle4");
        if (articleEntities.size() < 1) {
            System.out.println("JPADataAccess.addArticle5");
            throw new NoConnectivity();
        }
        else {
            System.out.println("JPADataAccess.addArticle6");
            return this.convertArticleEntitytoArticle(articleEntities.get(0));
        }
    }

    public Article getArticle(String id) throws NoConnectivity, ArticleDoesNotExist { 
        int idInt;
        try {
            idInt = Integer.parseInt(id);	
        }
        catch (Exception exception) {
            throw new ArticleDoesNotExist();
        }	
        ArticleEntity article = articleDAO.readArticle(idInt);
        if (article == null) {
            throw new ArticleDoesNotExist();
        }
        else {
            return this.convertArticleEntitytoArticle(article);
        }
    }

    public List<Article> getArticles() throws NoConnectivity {  	        
        List<Article> articleEntities = new ArrayList<Article>();
        for (ArticleEntity articleEntity : articleDAO.readAllArticles()) {
            articleEntities.add(this.convertArticleEntitytoArticle(articleEntity));
        }
        return articleEntities;
    }

    private Article convertArticleEntitytoArticle(ArticleEntity articleEntity) {
        Article article = new Article();
        article.author = articleEntity.getAuthor();
        article.title = articleEntity.getTitle();
        article.url = articleEntity.getUrl();
        article.id = Integer.toString(articleEntity.getId());
        return article;
    }
}