<template>
  <div class="home">
    <h4 style="margin-top:30px;margin-bottom:30px">Articles</h4>
    <div>
      <div class="articlesTable" style="line-height: 30px;">
        <div class="articlesRow">
          <div class="articlesCell">
            &#x1F4C3 Title
          </div>
          <div class="articlesCell" style="width:200px">
            &#x1F9D1 Author
          </div>
          <div class="articlesCell" style="width:150px">
            &#x1F4AC Twitter
          </div>
          <div class="articlesCell" style="width:80px">
            &#x1F171 Blog
          </div>
        </div>
        <div v-for="article in articles" :key="article.id" class="articlesRow">
          <div class="articlesCell">
            <b-link target="_blank" :href="article.url">{{ article.title }}</b-link>
          </div>
          <div class="articlesCell">
            {{ article.authorName }}
          </div>
          <div class="articlesCell">
            <b-link v-if="article.authorTwitter != ''" target="_blank" :href="'https://twitter.com/' + article.authorTwitter">{{ article.authorTwitter }}</b-link>
          </div>
          <div class="articlesCell">
            <b-link v-if="article.authorBlog != ''" target="_blank" :href="article.authorBlog">Blog</b-link>
          </div>
        </div>
      </div>
    </div>
    <div style="margin-top:30px" v-if="(articles.length == 0) && (loading == false) && (error == '')">
      <div>There are no articles</div>
    </div>
    <div style="margin-top:30px" v-if="error != ''">
      <div>Articles could not be read</div>
      <div>{{ error }}</div>
      <div>{{ webApiUrl }}</div>
    </div>
    <b-spinner v-if="loading == true" label="Loading ..."/>
  </div>
</template>

<script>
import axios from "axios";
export default {
  name: "Home",
  data() {
    return {
      webApiUrl: "http://192.168.99.100:31185/web-api/v1/getmultiple",
      articles: [],
      loading: false,
      error: ""
    };
  },
  mounted() {
    this.loading = true;
    const axiosService = axios.create({
      timeout: 5000,
      headers: {
        "Content-Type": "application/json"
      }
    });
    let that = this;
    axiosService
      .get(this.webApiUrl)
      .then(function(response) {
        that.articles = response.data;
        that.loading = false;
        that.error = "";
      })
      .catch(function(error) {
        console.log(error);
        that.loading = false;
        that.error = error;
      });
  }
};
</script>


<style scoped>
.articlesTable {
  display: table;
  width:100%;
}
.articlesRow {
  display: table-row;
}
.articlesCell {
  max-width:100px;
  display: table-cell;
  vertical-align: top;
}
</style>
