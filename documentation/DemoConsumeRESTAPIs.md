## Demo: Consume REST APIs

MicroProfile comes with a REST Client which defines a type safe client programming model. The REST Client makes it easier to convert between the JSON data and Java objects in both directions.

First you need to define the interface of the service you want to invoke.

```
import javax.ws.rs.GET;
import javax.ws.rs.Produces;
import javax.ws.rs.core.MediaType;
import com.ibm.webapi.business.Author;
import com.ibm.webapi.business.NonexistentAuthor;
 
@RegisterProvider(ExceptionMapperArticles.class)
public interface AuthorsService {
  @GET
  @Produces(MediaType.APPLICATION_JSON)
  public Author getAuthor(String name) throws NonexistentAuthor; 
}
```

The method ‘getAuthor’ returns an object of the Author class.

```
public class Author {
   public String name;
   public String twitter;
   public String blog;
}
```

The actual invocation of the authors service happens in AuthorsServiceDataAccess.java. The RestClientBuilder is used to get an implementation of the AuthorsService interface. The deserialization of the data into a Java object is done automatically.

```
import org.eclipse.microprofile.rest.client.RestClientBuilder;
import com.ibm.webapi.business.Author;
import com.ibm.webapi.business.NonexistentAuthor;
 
public class AuthorsServiceDataAccess {
   static final String BASE_URL = "http://authors/api/v1/";
 
   public AuthorsServiceDataAccess() {} 
 
   public Author getAuthor(String name) throws NoConnectivity, NonexistentAuthor {
      try {
         URL apiUrl = new URL(BASE_URL + "getauthor?name=" + name);
         AuthorsService customRestClient = RestClientBuilder.newBuilder().baseUrl(apiUrl).register(ExceptionMapperAuthors.class).build(AuthorsService.class);
         return customRestClient.getAuthor(name);
      } catch (NonexistentAuthor e) {
         throw new NonexistentAuthor(e);            
      } catch (Exception e) {
         throw new NoConnectivity(e);
      }
   }
}
```

In order to use the RESTClientBuilder you need to understand the concept of the ResponseExceptionMapper. This mapper is used to translate certain HTTP response error codes back into Java exceptions.

```
import org.eclipse.microprofile.rest.client.ext.ResponseExceptionMapper;
import com.ibm.webapi.business.NonexistentAuthor;
 
@Provider
public class ExceptionMapperAuthors implements ResponseExceptionMapper<NonexistentAuthor> {
   @Override
   public boolean handles(int status, MultivaluedMap<String, Object> headers) {
      return status == 204;
   }
   @Override
   public NonexistentAuthor toThrowable(Response response) {
      switch (response.getStatus()) {
         case 204:
            return new NonexistentAuthor();
        }
        return null;
   }   
}
```

Invoke the following commands to set up the demo. Skip the commands you've already executed.

```
$ cd $PROJECT_HOME
$ scripts/check-prerequisites.sh
$ scripts/delete-all.sh
$ scripts/deploy-articles-java-jee.sh
$ scripts/deploy-web-api-java-jee.sh
$ scripts/deploy-istio-ingress-v1.sh
$ scripts/show-urls.sh
```

Invoke the curl command of the 'web-api' microserivce which is displayed as output of 'scripts/show-urls.sh' to get ten articles, for example 'http://192.168.99.100:31380/web-api/v1/getmultiple'.

Check out the article [Invoking REST APIs from Java Microservices](hhttp://heidloff.net/invoke-rest-apis-java-microprofile-microservice) for more details.