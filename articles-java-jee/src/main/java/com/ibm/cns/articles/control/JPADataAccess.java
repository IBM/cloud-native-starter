package com.ibm.cns.articles.control;

import com.ibm.cns.articles.control.ArticleDao;
import com.ibm.cns.articles.entity.Article;
import com.ibm.cns.articles.entity.Article;
import java.util.ArrayList;
import java.util.List;
import javax.enterprise.context.ApplicationScoped;
import javax.inject.Inject;

@ApplicationScoped
public class JPADataAccess implements DataAccess {
     
    @Inject
    private ArticleDao articleDAO;

    public Article addArticle(Article article) throws NoConnectivity {
        long currentTime = new java.util.Date().getTime();
        articleDAO.createArticle(article);
        List<Article> articleEntities = articleDAO.findArticle(article.title, article.url, article.author);
        if (articleEntities.size() < 1) {
            throw new NoConnectivity();
        }
        else {
            return articleEntities.get(0);
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
        Article article = articleDAO.readArticle(idInt);
        if (article == null) {
            throw new ArticleDoesNotExist();
        }
        else {
            return article;
        }
    }

    public List<Article> getArticles() throws NoConnectivity {          
        List<Article> articleEntities = new ArrayList<>();
        
        for (Article articleEntity : articleDAO.readAllArticles()) {
            articleEntities.add(articleEntity);
        }
        return articleEntities;
    }

}
