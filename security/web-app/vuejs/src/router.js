import Vue from 'vue';
import Router from 'vue-router';
import Home from './components/Home.vue';
import CreateArticle from './components/CreateArticle.vue';

Vue.use(Router);

export default new Router({
  mode: 'history',
  routes: [
    {
      path: '/',
      name: 'home',
      component: Home
    },
    {
      path: '/createarticle',
      name: 'createarticle',
      component: CreateArticle
    }
  ],
});