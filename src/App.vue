<template>
  <div id="app">
    <TaskWorkaround init-title="C++ task example" init-task-id="cpp-example-task-1" init-lang="cpp"></TaskWorkaround>
    <TaskWorkaround init-title="Go task example" init-task-id="golang-example-task-1" init-lang="go"></TaskWorkaround>
    <TaskWorkaround init-title="Python task example" init-lang="python"></TaskWorkaround>
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
.monaco-editor,
.overflow-guard,
.monaco-scrollable-element {
  width: 100% !important;
}
</style>
