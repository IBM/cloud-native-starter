package com.ibm.webapi.data;

import com.ibm.webapi.business.Article;
import java.util.ArrayList;
import java.util.List;

public class InMemoryDataAccess implements DataAccess {

    public InMemoryDataAccess() {
    }

    public Article addArticle(Article article) throws NoConnectivity {
    	return null;
    }

    public List<Article> getArticles() throws NoConnectivity {  	        
        return new ArrayList<Article>();
    }
}
