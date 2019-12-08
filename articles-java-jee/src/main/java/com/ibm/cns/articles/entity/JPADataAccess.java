package com.ibm.cns.articles.entity;

import com.ibm.cns.articles.entity.DataAccess;
import com.ibm.cns.articles.entity.ArticleEntity;
import com.ibm.cns.articles.control.ArticleDao;
import com.ibm.cns.articles.entity.Article;
import com.ibm.cns.articles.entity.ArticleDoesNotExist;

import javax.inject.Inject;

import java.util.ArrayList;
import java.util.List;
import javax.enterprise.context.ApplicationScoped;

@ApplicationScoped
public class JPADataAccess implements DataAccess {
     
    @Inject
    private ArticleDao articleDAO;

    public JPADataAccess() {
    }

    public Article addArticle(Article article) throws NoConnectivity {
        long currentTime = new java.util.Date().getTime();
		String currentTimeAsString = String.valueOf(currentTime);
        ArticleEntity newArticle = new ArticleEntity(article.title, article.url, article.author, currentTimeAsString);
        articleDAO.createArticle(newArticle);
        List<ArticleEntity> articleEntities = articleDAO.findArticle(article.title, article.url, article.author);
        if (articleEntities.size() < 1) {
            throw new NoConnectivity();
        }
        else {
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
        article.creationDate = articleEntity.getCreationDate();
        article.id = Integer.toString(articleEntity.getId());
        return article;
    }
}