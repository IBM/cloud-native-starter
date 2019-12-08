package com.ibm.cns.articles.control;

import com.ibm.cns.articles.entity.ArticleEntity;
import com.ibm.cns.articles.entity.NoConnectivity;
import java.util.List;
import javax.persistence.EntityManager;
import javax.persistence.PersistenceContext;
import javax.annotation.Resource;
import javax.enterprise.context.ApplicationScoped;
import javax.transaction.UserTransaction;

@ApplicationScoped
public class ArticleDao {

    @PersistenceContext(name = "jpa-unit")
    private EntityManager em;

    @Resource
    UserTransaction utx;

    public void createArticle(ArticleEntity article) throws NoConnectivity {
        try {
            utx.begin();
            em.persist(article);
            utx.commit();
        } catch (Exception e) {
            System.out.println(e);
            throw new NoConnectivity();
        }
    }

    public ArticleEntity readArticle(int articleId) {
        return em.find(ArticleEntity.class, articleId);
    }

    public void updateArticle(ArticleEntity article) {
        em.merge(article);
    }

    public void deleteArticle(ArticleEntity article) {
        em.remove(article);
    }

    public List<ArticleEntity> readAllArticles() {
        return em.createNamedQuery("Article.findAll", ArticleEntity.class).getResultList();
    }

    public List<ArticleEntity> find(int articleId) {
        return em.createNamedQuery("Article.findArticle", ArticleEntity.class).setParameter("id", articleId)
                .getResultList();

    }

    public List<ArticleEntity> findArticle(String title, String url, String author) {
        return em.createNamedQuery("Article.findArticle", ArticleEntity.class).setParameter("title", title)
                .setParameter("url", url).setParameter("author", author).getResultList();
    }
}
