<template>
  <div class="create">
    <h4 style="margin-top:30px;margin-bottom:30px">Create new Article</h4>
    <div>
      <b-form @submit="onSubmit">
        <b-form-group id="input-group-2" label="Title:" label-for="input-2">
          <b-form-input id="input-2" v-model="form.title" required placeholder="Enter title"></b-form-input>
        </b-form-group>
        <b-form-group id="input-group-2" label="URL:" label-for="input-2">
          <b-form-input id="input-2" v-model="form.url" required placeholder="Enter URL"></b-form-input>
        </b-form-group>
        <b-form-group id="input-group-2" label="Author:" label-for="input-2">
          <b-form-input id="input-2" v-model="form.author" required placeholder="Enter author"></b-form-input>
        </b-form-group>

        <b-button type="submit" variant="primary">Submit</b-button>
      </b-form>
      <b-spinner v-if="loading == true" label="Loading ..."/>
      <div style="margin-top:30px" v-if="createResponse != ''">
        <div>Response from 'Create Article / Submit' ({{ webApiUrl }}):</div>
        <div style="margin-top:10px">{{ createResponse }}</div>
      </div>
    </div>
  </div>
</template>

<script>
import axios from "axios";
export default {
  name: "CreateArticle",
  data() {
    return {
      webApiUrl: this.$store.state.endpoints.api + "create",
      loading: false,
      createResponse: "",
      form: {
        title: "",
        url: "",
        author: ""
      }
    };
  },
  methods: {
    onSubmit(evt) {
      evt.preventDefault();
      this.loading = true;
      const axiosService = axios.create({
        timeout: 5000,
        headers: {
          "Content-Type": "application/json",
          Authorization: "Bearer " + this.$store.state.user.idToken
        }
      });
      let that = this;
      axiosService
        .post(this.webApiUrl, {
          title: this.form.title,
          url: this.form.url,
          author: this.form.author,
          id: "something"
        })
        .then(function(response) {
          that.loading = false;
          that.createResponse =
            "Invocation of /create has been successful. Article has been saved.";
        })
        .catch(function(error) {
          console.log(error);
          that.loading = false;
          that.createResponse = error;
        });
    }
  }
};
</script>


<style scoped>
.articlesTable {
  display: table;
  width: 100%;
}
.articlesRow {
  display: table-row;
}
.articlesCell {
  max-width: 100px;
  display: table-cell;
  vertical-align: top;
}
</style>
