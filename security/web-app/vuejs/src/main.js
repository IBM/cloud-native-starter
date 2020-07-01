import Vue from 'vue'
import App from './App.vue'
import store from './store'
import router from './router';
import BootstrapVue from 'bootstrap-vue';
import Keycloak from 'keycloak-js';
import axios from "axios";

import 'bootstrap/dist/css/bootstrap.css';
import 'bootstrap-vue/dist/bootstrap-vue.css';

let initOptions = {
  url: 'https://keycloak-default.niklas-heidloff-dal12-b-162e406f043e20da9b0ef0731954a894-0000.eu-gb.containers.appdomain.cloud/auth', realm: 'quarkus', clientId: 'frontend', onLoad: 'login-required'
}

Vue.config.productionTip = false
Vue.config.devtools = true

Vue.use(BootstrapVue);

let keycloak = Keycloak(initOptions);


keycloak.init({ onLoad: initOptions.onLoad }).then((auth) => {

  if (!auth) {
    window.location.reload();
  } 

  new Vue({
    store,
    router,
    render: h => h(App)
  }).$mount('#app')

  localStorage.setItem("vue-token", keycloak.token);
  localStorage.setItem("vue-refresh-token", keycloak.refreshToken);

  let name = "Unknown"
  let idToken = keycloak.idToken
  let accessToken = keycloak.token
  let payload = {
    idToken: idToken,
    accessToken: accessToken
  }

  if (accessToken && idToken && accessToken != '' && idToken != '') {
    store.commit("login", payload);    
    console.log("accessToken: " + store.state.user.accessToken)
  }
  else {
    store.commit("logout");
  }

  setInterval(() => {
    keycloak.updateToken(70).then((refreshed) => {
      if (refreshed) {  
        let idToken2 = keycloak.idToken
        let accessToken2 = keycloak.token

        let payload2 = {
          idToken: idToken2,
          accessToken: accessToken2
        }
      
        if (accessToken2 && idToken2 && accessToken2 != '' && idToken2 != '') {
          store.commit("login", payload2);
        }
        else {
          store.commit("logout");
        }
      
      } else {
        //console.log('Token not refreshed, valid for ' + Math.round(keycloak.tokenParsed.exp + keycloak.timeSkew - new Date().getTime() / 1000) + ' seconds');
      }
    }).catch(() => {
      console.log('Failed to refresh token');
    });

  }, 60000)

}).catch(() => {
  console.log("Failed to authenticate");
});

