<template>
  <div id="app">
    <b-navbar
      toggleable="lg"
      type="dark"
      variant="info"
      style="background-color: #1675fd !important;"
    >
      <b-navbar-brand>Cloud Native Starter</b-navbar-brand>

      <b-navbar-nav class="ml-auto" v-if="isAuthenticationEnabled == true">
        <b-navbar-nav v-if="isAuthenticated == false">
          <b-nav-item v-on:click="onLoginClicked">Login</b-nav-item>
        </b-navbar-nav>
        <b-nav-item-dropdown right v-if="isAuthenticated == true">
          <template slot="button-content">{{ getUserName() }}</template>
          <b-dropdown-item v-on:click="onCreateArticleClicked">Create Article</b-dropdown-item>
          <b-dropdown-item v-on:click="onManageApplicationClicked">Manage Application</b-dropdown-item>
          <b-dropdown-item v-on:click="onLogoutClicked">Sign Out</b-dropdown-item>
        </b-nav-item-dropdown>
      </b-navbar-nav>
    </b-navbar>
    <div style="margin-left:20px;margin-right:20px">
      <router-view/>
      <b-spinner v-if="loading == true" label="Loading ..."/>
      <div style="margin-top:30px" v-if="manageResponse != ''">
        <div>Response from 'Manage Application' ({{ webApiUrl }}):</div>
        <div style="margin-top:10px">{{ manageResponse }}</div>
      </div>
    </div>
  </div>
</template>

<script>
import Home from "./components/Home.vue";
import axios from "axios";
export default {
  name: "app",
  components: {
    Home
  },
  computed: {
    isAuthenticated() {
      return this.$store.state.user.isAuthenticated;
    },
    isAuthenticationEnabled() {
      if (
        this.$store.state.authenticationEnabled == "authentication-enabled-yes"
      ) {
        return true;
      } else {
        return false;
      }
    }
  },
  data() {
    return {
      webApiUrl: this.$store.state.endpoints.api + "manage",
      loading: false,
      manageResponse: ""
    };
  },
  methods: {
    onLoginClicked() {
      window.location = this.$store.state.endpoints.login;
    },
    onCreateArticleClicked() {
      this.$router.push("createarticle");
    },
    onManageApplicationClicked() {
      this.loading = true;
      const axiosService = axios.create({
        timeout: 5000,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer " + this.$store.state.user.idToken
        }
      });
      let that = this;
      axiosService
        .post(this.webApiUrl)
        .then(function(response) {
          that.articles = response.data;
          that.loading = false;
          that.manageResponse = "Invocation of /manage has been successful";
        })
        .catch(function(error) {
          console.log(error);
          that.loading = false;
          that.manageResponse = error;
        });
    },
    onLogoutClicked() {
      this.$store.commit("logout");
    },
    getUserName() {
      return this.$store.state.user.name;
    }
  }
};
</script>

<style>
.navbar-dark .navbar-nav .nav-link {
  color: #fff !important;
}
</style>
