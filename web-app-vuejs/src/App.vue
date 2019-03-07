<template>
  <div id="app">
    <b-navbar toggleable="md" type="dark" style="background-color: #1675fd !important;">
      <b-navbar-brand style="margin-right:40px">Cloud Native Starter</b-navbar-brand>
    </b-navbar>
    <div style="margin-left:20px;margin-right:20px">
      <Home/>
    </div>
  </div>
</template>

<script>
import Home from './components/Home.vue'

export default {
  name: 'app',
  components: {
    Home
  }
}
</script>

<style>
#app {
  font-family: 'Avenir', Helvetica, Arial, sans-serif;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
  text-align: left;
  color: #2c3e50;
}
</style>
