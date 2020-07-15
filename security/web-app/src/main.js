import Vue from 'vue'
import App from './App.vue'
import store from './store'
import router from './router';
import BootstrapVue from 'bootstrap-vue';
import Keycloak from 'keycloak-js';

import 'bootstrap/dist/css/bootstrap.css';
import 'bootstrap-vue/dist/bootstrap-vue.css';

let initOptions = {
  url: 'https://keycloak-default.niklas-heidloff-dal12-b-162e406f043e20da9b0ef0731954a894-0000.us-south.containers.appdomain.cloud/auth/', realm: 'quarkus', clientId: 'frontend', onLoad: 'login-required'
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

  let payload = {
    idToken: keycloak.idToken,
    accessToken: keycloak.token
  }
  if (keycloak.token && keycloak.idToken && keycloak.token != '' && keycloak.idToken != '') {
    store.commit("login", payload);
    console.log("accessToken: " + store.state.user.accessToken)
  }
  else {
    store.commit("logout");
  }

  setInterval(() => {
    keycloak.updateToken(70).then((refreshed) => {
      if (refreshed) {
        let payloadRefreshedTokens = {
          idToken: keycloak.idToken,
          accessToken: keycloak.token
        }

        if (keycloak.token && keycloak.idToken && keycloak.token != '' && keycloak.idToken != '') {
          store.commit("login", payloadRefreshedTokens);
        }
        else {
          store.commit("logout");
        }
      }
    }).catch(() => {
      console.log('Failed to refresh token');
    });
  }, 60000)
}).catch(() => {
  console.log("Failed to authenticate");
});