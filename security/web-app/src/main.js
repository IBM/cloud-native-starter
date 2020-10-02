import Vue from 'vue'
import App from './App.vue'
import store from './store'
import router from './router';
import BootstrapVue from 'bootstrap-vue';
import Keycloak from 'keycloak-js';

import 'bootstrap/dist/css/bootstrap.css';
import 'bootstrap-vue/dist/bootstrap-vue.css';

Vue.config.productionTip = false
Vue.config.devtools = true
Vue.use(BootstrapVue);

let currentHostname = window.location.hostname; 
let urls;
if (currentHostname.indexOf('localhost') > -1) {
  urls = {
    api: 'http://localhost:8081/',
    login: 'https://YOUR-URL/auth' // insert your http or https://<KeycloakURL>/auth
  }
  store.commit("setAPIAndLogin", urls);
}
else {
  let webapiUrl = 'https://' + currentHostname + '/';
  let keycloakUrl = 'https://' + currentHostname + '/auth'; 
  urls = {
    api: webapiUrl,
    login: keycloakUrl
  }
  store.commit("setAPIAndLogin", urls);
}

let initOptions = {
  url: store.state.endpoints.login , realm: 'quarkus', clientId: 'frontend', onLoad: 'login-required'
}

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
    // console.log("User has logged in: " + keycloak.subject);
    // console.log("TokenParsed: "+ JSON.stringify(keycloak.tokenParsed));
    // console.log("User name: " + keycloak.tokenParsed.preferred_username);
    // console.log("accessToken: " + store.state.user.accessToken);
    payload = {
      name: keycloak.tokenParsed.preferred_username
    };
    store.commit("setName", payload);
  }
  else {
    store.commit("logout");
  }

  setInterval(() => {
    keycloak.updateToken(70).then((refreshed) => {
      if (refreshed) {
        console.log("--> log: updateToken");
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
      console.log('-->log: Failed to refresh token');
    });
  }, 60000)
}).catch(() => {
  console.log("-->log: Failed to authenticate");
});
