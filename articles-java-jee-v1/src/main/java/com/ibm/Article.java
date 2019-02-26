package com.ibm;

import org.eclipse.microprofile.openapi.annotations.media.Schema;

@Schema(name="Article", description="POJO that represents a single article")
public class Article {

	@Schema(required = true)
	public String title;
	
	public String url;
    public String author;
    public String id;

    public Article() {
    }
}
