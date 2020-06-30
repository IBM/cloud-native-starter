import Vue from 'vue'
import Vuex from 'vuex'

Vue.use(Vuex)

export default new Vuex.Store({
  state: {
    authenticationEnabled: "authentication-enabled-yes", // use "authentication-enabled-yes" to turn it on
    endpoints: {
      api: "http://endpoint-api-ip:ingress-np/web-api/v1/", // example: "http://192.168.99.100:31380/web-api/v1/"
      login: "http://endpoint-login-ip:endpoint-login-port/login" // example: "http://localhost:3000/login"
    },
    user: {
      isAuthenticated: false,
      name: "",
      idToken: "",
      accessToken: ""
    }
  },
  mutations: {
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
