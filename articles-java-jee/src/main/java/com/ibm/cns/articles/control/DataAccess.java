package com.ibm.cns.articles.control;

import com.ibm.cns.articles.entity.Article;
import java.util.List;

public interface DataAccess {

    public Article addArticle(Article article);

    public Article getArticle(String id);

    public List<Article> getArticles();
}
