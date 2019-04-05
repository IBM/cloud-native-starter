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
          <template slot="button-content">
            {{ getUserName() }}
          </template>
          <b-dropdown-item v-on:click="onCreateArticleClicked">Create Article</b-dropdown-item>
          <b-dropdown-item v-on:click="onManageApplicationClicked">Manage Application</b-dropdown-item>
          <b-dropdown-item v-on:click="onLogoutClicked">Sign Out</b-dropdown-item>
        </b-nav-item-dropdown>
      </b-navbar-nav>
    </b-navbar>
    <div style="margin-left:20px;margin-right:20px">
      <Home/>
    </div>
  </div>
</template>

<script>
import Home from "./components/Home.vue";

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
      if (this.$store.state.authenticationEnabled == "authentication-enabled-yes") {
        return true;
      }
      else {
        return false;
      }
    },
  },
  methods: {
    onLoginClicked() {
      window.location = this.$store.state.endpoints.login;
    },
    onCreateArticleClicked() {
      console.log("onCreateArticleClicked");
    },
    onManageApplicationClicked() {
      console.log("onManageApplicationClicked");
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
        color: #fff!important;
}
</style>
