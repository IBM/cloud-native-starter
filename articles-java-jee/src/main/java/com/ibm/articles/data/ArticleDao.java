package com.ibm.articles.data;

import java.util.List;
import javax.persistence.EntityManager;
import javax.persistence.PersistenceContext;
import javax.enterprise.context.ApplicationScoped;
import javax.enterprise.context.RequestScoped;

@RequestScoped
public class ArticleDao {

    @PersistenceContext(name = "jpa-unit")
    private EntityManager em;

    public void createArticle(ArticleEntity article) {
        System.out.println("ArticleDao.createArticle");
        em.persist(article);
        System.out.println("ArticleDao.createArticle2");
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
        return em.createNamedQuery("Article.findArticle", ArticleEntity.class)
            .setParameter("id", articleId).getResultList();
    }

    public List<ArticleEntity> findArticle(String title, String url, String author) {
      return em.createNamedQuery("Article.findArticle", ArticleEntity.class)
          .setParameter("title", title)
          .setParameter("url", url)
          .setParameter("author", author).getResultList();
  }
}
