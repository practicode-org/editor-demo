<template>
  <div id="app">
    <TaskWorkaround></TaskWorkaround>
  </div>
</template>

<script>
import TaskWorkaround from '@/components/TaskWorkaround.vue'

export default {
  name: 'App',
  components: {
    TaskWorkaround
  },
  data() {
    return {
    }
  },
}

</script>

<style>

#app {
  font-family: Avenir, Helvetica, Arial, sans-serif;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
  color: #2c3e50;
  margin-top: 20px;
}

</style>
