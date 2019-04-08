<template>
  <div class="create">
    <h4 style="margin-top:30px;margin-bottom:30px">Create new Article</h4>
    <div>
      <b-form @submit="onSubmit">
        <b-form-group id="input-group-2" label="Title:" label-for="input-2">
          <b-form-input id="input-2" v-model="form.title" required placeholder="Enter title"></b-form-input>
        </b-form-group>

        <b-button type="submit" variant="primary">Submit</b-button>
      </b-form>
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
      error: "",
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
      console.log(JSON.stringify(this.form));
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
