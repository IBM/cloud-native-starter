import Vue from 'vue'
import Vuex from 'vuex'

Vue.use(Vuex)

export default new Vuex.Store({
  state: {
    endpoints: {
      api: " ", // is set automatically. when running locally: 'http://localhost:8081/'
      login: "<yourkeycloakurl>/auth" // needs to be defined when running locally. example: 'https://<name>-<hash>-0000.us-south.containers.appdomain.cloud/auth'
    },
    user: {
      isAuthenticated: false,
      name: "",
      idToken: "",
      accessToken: ""
    }
  },
  mutations: {
    setAPI(state, payload) {
      state.endpoints.api = payload.api;      
    },
    setAPIAndLogin(state, payload) {
      state.endpoints.api = payload.api;
      state.endpoints.login = payload.login;
    },
    logout(state) {
      state.user.isAuthenticated = false;
      state.user.name = "";
      state.user.idToken = "";
      state.user.accessToken = "";
    },
    login(state, payload) {
      state.user.isAuthenticated = true;
      state.user.idToken =payload.idToken;
      state.user.accessToken =payload.accessToken;
    },
    setName(state, payload) {
      state.user.name = payload.name;
    }
  },
  actions: {
  }
})
