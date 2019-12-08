package com.ibm.cns.articles.control;

import com.ibm.cns.articles.entity.Article;
import java.util.ArrayList;
import java.util.List;
import javax.annotation.Resource;
import javax.enterprise.context.ApplicationScoped;
import javax.persistence.EntityManager;
import javax.persistence.PersistenceContext;
import javax.transaction.UserTransaction;

@ApplicationScoped
public class JPADataAccess implements DataAccess {

    @PersistenceContext(name = "jpa-unit")
    private EntityManager em;

    @Resource
    UserTransaction utx;

    public void createArticle(Article article) throws NoConnectivity {
        try {
            utx.begin();
            em.persist(article);
            utx.commit();
        } catch (Exception e) {
            System.out.println(e);
            throw new NoConnectivity("Transaction problem");
        }
    }

    public Article readArticle(int articleId) {
        return em.find(Article.class, articleId);
    }

    public void updateArticle(Article article) {
        em.merge(article);
    }

    public void deleteArticle(Article article) {
        em.remove(article);
    }

    public List<Article> readAllArticles() {
        return em.createNamedQuery("Article.findAll", Article.class).getResultList();
    }

    public List<Article> find(int articleId) {
        return em.createNamedQuery("Article.findArticle", Article.class).
                setParameter("id", articleId)
                .getResultList();

    }

    public List<Article> findArticle(String title, String url, String author) {
        return em.createNamedQuery("Article.findArticle", Article.class).setParameter("title", title)
                .setParameter("url", url).setParameter("author", author).getResultList();
    }

     
    public Article addArticle(Article article) {
        this.createArticle(article);
        List<Article> articleEntities = this.findArticle(article.title, article.url, article.author);
        if (articleEntities.size() < 1) {
            throw new NoConnectivity("No articles were found - assuming there is no DB connection");
        }
        else {
            return articleEntities.get(0);
        }
    }

    public Article getArticle(String id) {
        int idInt;
        try {
            idInt = Integer.parseInt(id);	
        }
        catch (Exception exception) {
            throw new ArticleDoesNotExist("ID " + id + " is not convertible to integer");
        }	
        Article article = this.readArticle(idInt);
        if (article == null) {
            throw new ArticleDoesNotExist("Article with " + id + " not found");
        }
        else {
            return article;
        }
    }

    public List<Article> getArticles() throws NoConnectivity {          
        List<Article> articleEntities = new ArrayList<>();
        
        for (Article articleEntity : this.readAllArticles()) {
            articleEntities.add(articleEntity);
        }
        return articleEntities;
    }

}
