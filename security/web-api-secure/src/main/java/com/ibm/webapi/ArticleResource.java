package com.ibm.webapi;

import java.util.List;
import java.util.stream.Collectors;
import javax.annotation.security.RolesAllowed;
import javax.inject.Inject;
import javax.ws.rs.GET;
import javax.ws.rs.Path;
import javax.ws.rs.Produces;
import javax.ws.rs.core.MediaType;
import org.eclipse.microprofile.jwt.JsonWebToken;
import io.quarkus.oidc.IdToken;
import io.quarkus.oidc.RefreshToken;
import org.jboss.resteasy.annotations.cache.NoCache;

@Path("/")
public class ArticleResource {

    @Inject
    @IdToken
    JsonWebToken idToken;

    @Inject
    JsonWebToken accessToken;

    @Inject
    RefreshToken refreshToken;

    @Inject
    ArticlesDataAccess articlesDataAccess;

    @GET
    @Path("/articles")
    @Produces(MediaType.APPLICATION_JSON)
    //@Authenticated
    @RolesAllowed("user")
    @NoCache
    public List<Article> getArticles() {
        try {
            List<CoreArticle> coreArticles = articlesDataAccess.getArticles(5);
            return createArticleList(coreArticles);
        } catch (NoConnectivity e) {
            System.err.println("com.ibm.webapi.business.getArticles: Cannot connect to articles service");
            throw new NoDataAccess(e);
        }
    }

    private List<Article> createArticleList(List<CoreArticle> coreArticles) {
        return coreArticles.stream()
                .map(coreArticle -> {
                    Article article = new Article();
                    article.id = coreArticle.id;
                    article.title = coreArticle.title;
                    article.url = coreArticle.url;
                    article.authorName = coreArticle.author;
                    article.authorBlog = "";
                    article.authorTwitter = "";
                    return article;
                }).collect(Collectors.toList());
    }

    @GET
    @Path("/tokens")
    public String getTokens() {
        StringBuilder response = new StringBuilder().append("<html>")
                .append("<body>")
                .append("<ul>");

        Object userName = this.idToken.getClaim("preferred_username");

        Object groups = this.idToken.getGroups();
        
        if (groups != null) {
            response.append("<li>groups: ").append(groups.toString()).append("</li>");
        }

        if (userName != null) {
            response.append("<li>username: ").append(userName.toString()).append("</li>");
        }

        Object scopes = this.accessToken.getClaim("scope");

        if (scopes != null) {
            response.append("<li>scopes: ").append(scopes.toString()).append("</li>");
        }
        
        if (this.accessToken.getClaimNames() != null) {
            response.append("<li>claims: ").append(this.accessToken.getClaimNames().toString()).append("</li>");
        }

        response.append("<li>refresh_token: ").append(refreshToken.getToken() != null).append("</li>");

        return response.append("</ul>").append("</body>").append("</html>").toString();
    }
    
}