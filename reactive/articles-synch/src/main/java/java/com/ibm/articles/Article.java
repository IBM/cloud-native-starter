package com.ibm.articles;

import javax.persistence.Cacheable;
import javax.persistence.Column;
import javax.persistence.Entity;

import io.quarkus.hibernate.orm.panache.PanacheEntity;

@Entity
@Cacheable
public class Article extends PanacheEntity {

    public Article() {}
   
    public String title;

	public String url;

    public String author;
    
    public String creationDate;
}
