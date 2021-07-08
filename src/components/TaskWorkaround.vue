<template>
  <div class="container">
    <!-- Left part -->
    <div id="left">
        <b-card class="mb-2">
          <h5 class="mb-0">Task #3: Concurrency - condition_variable</h5>
        </b-card>
    </div>
    <!-- Right part -->
    <div id="right">
      <CodeEditor></CodeEditor>
    </div>
  </div>
</template>

<script>
import CodeEditor from '@/components/CodeEditor.vue'

export default {
  name: 'TaskWorkaround',
  components: {
    CodeEditor
  },
  data () {
    return {
    }
  }
}
</script>

<style scoped>
.container {
  display: flex;
  flex-flow: row nowrap;
  justify-content: space-evenly;
  align-items: stretch;
  border: 1px solid red;
}

#editor {
  background-color: #faeaff;
  height: 800px;
}

#left {
  flex-grow: 1;
  border: 1px solid red;
}

#right {
  flex-grow: 1;
  border: 1px solid green;
}
</style>
