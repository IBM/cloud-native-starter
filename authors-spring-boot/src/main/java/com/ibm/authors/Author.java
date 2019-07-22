package com.ibm.authors;

import javax.persistence.Entity;
import javax.persistence.Id;
import javax.persistence.Table;

@Entity
@Table(name="AUTHORS")
public class Author {

	@Id
	public String name;
	public String twitter;
	public String blog;

	public Author() {
	}

	public Author(String name, String twitter, String blog) {
		this.name = name;
		this.twitter = twitter;
		this.blog = blog;
	}

	public String getName() {
		return name;
	}

	public void setName(String name) {
		this.name = name;
	}

	public String getTwitter() {
		return twitter;
	}

	public void setTwitter(String twitter) {
		this.twitter = twitter;
	}

	public String getBlog() {
		return blog;
	}

	public void setBlog(String blog) {
		this.blog = blog;
	}

}