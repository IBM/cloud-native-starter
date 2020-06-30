package com.ibm.webapi;

import java.util.Collections;
import java.util.LinkedHashMap;
import java.util.Set;
import javax.annotation.PostConstruct;
import javax.annotation.security.RolesAllowed;
import javax.inject.Inject;
import javax.ws.rs.GET;
import javax.ws.rs.POST;
import javax.ws.rs.Path;
import javax.ws.rs.Produces;
import javax.ws.rs.core.MediaType;
import org.eclipse.microprofile.jwt.JsonWebToken;
import io.quarkus.oidc.IdToken;
import io.quarkus.oidc.RefreshToken;
import io.quarkus.security.Authenticated;

@Path("/")
public class ArticleResource {

    @Inject
    @IdToken
    JsonWebToken idToken;

    /**
     * Injection point for the Access Token issued by the OpenID Connect Provider
     */
    @Inject
    JsonWebToken accessToken;

    /**
     * Injection point for the Refresh Token issued by the OpenID Connect Provider
     */
    @Inject
    RefreshToken refreshToken;

    private Set<Article> articles = Collections.newSetFromMap(Collections.synchronizedMap(new LinkedHashMap<>()));

    @GET
    @Path("/articles")
    @Produces(MediaType.APPLICATION_JSON)
    @Authenticated
    //@RolesAllowed("user")
    public Set<Article> getArticles() {
        return articles;
    }

    @PostConstruct
    void addArticles() {
        addSampleArticles();
    }

    private void addSampleArticles() {
        System.out.println("com.ibm.articles.business.Service.addSampleArticles");

        addArticle("Blue Cloud Mirror — (Don’t) Open The Doors!", "https://haralduebele.blog/2019/02/17/blue-cloud-mirror-dont-open-the-doors/", "Harald Uebele");
        addArticle("Recent Java Updates from IBM", "http://heidloff.net/article/recent-java-updates-from-ibm", "Niklas Heidloff");
        addArticle("Developing and debugging Microservices with Java", "http://heidloff.net/article/debugging-microservices-java-kubernetes", "Niklas Heidloff");
        addArticle("IBM announced Managed Istio and Managed Knative", "http://heidloff.net/article/managed-istio-managed-knative", "Niklas Heidloff");
        addArticle("Three Minutes Demo of Blue Cloud Mirror", "http://heidloff.net/article/blue-cloud-mirror-demo-video", "Niklas Heidloff");
        addArticle("Blue Cloud Mirror Architecture Diagrams", "http://heidloff.net/article/blue-cloud-mirror-architecture-diagrams", "Niklas Heidloff");
        addArticle("Three awesome TensorFlow.js Models for Visual Recognition", "http://heidloff.net/article/tensorflowjs-visual-recognition", "Niklas Heidloff");
        addArticle("Install Istio and Kiali on IBM Cloud or Minikube", "https://haralduebele.blog/2019/02/22/install-istio-and-kiali-on-ibm-cloud-or-minikube/", "Harald Uebele");
        addArticle("Dockerizing Java MicroProfile Applications", "http://heidloff.net/article/dockerizing-container-java-microprofile", "Niklas Heidloff");
        addArticle("Debugging Microservices running in Kubernetes", "http://heidloff.net/article/debugging-microservices-kubernetes", "Niklas Heidloff");
    }

    private void addArticle(String title, String url, String author) {
        Article article = new Article();
        article.title = title;
        article.url = url;
        article.authorName = author;
        articles.add(article);
    }

    @GET
    @Path("/tokens")
    public String getTokens() {
        System.out.println("niklas1");
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
        else {
            response.append("<li>username: ").append("niklas").append("</li>");
        }
/*
        Object scopes = this.accessToken.getClaim("scope");

        if (scopes != null) {
            response.append("<li>scopes: ").append(scopes.toString()).append("</li>");
        }

       

        
        if (this.accessToken.getClaimNames() != null) {
            response.append("<li>claims: ").append(this.accessToken.getClaimNames().toString()).append("</li>");
        }

        response.append("<li>refresh_token: ").append(refreshToken.getToken() != null).append("</li>");
*/
        return response.append("</ul>").append("</body>").append("</html>").toString();
    }
}