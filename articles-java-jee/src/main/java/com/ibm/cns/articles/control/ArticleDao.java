package com.ibm.cns.articles.control;

import com.ibm.cns.articles.entity.Article;
import java.util.List;
import javax.annotation.Resource;
import javax.enterprise.context.ApplicationScoped;
import javax.persistence.EntityManager;
import javax.persistence.PersistenceContext;
import javax.transaction.UserTransaction;

@ApplicationScoped
public class ArticleDao {

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
            throw new NoConnectivity();
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
}
