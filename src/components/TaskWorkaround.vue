<template>
  <div class="container">
    <!-- Left part -->
    <div id="left">
        <b-card class="mb-2">
          <h5 class="mb-0">Task #3: Concurrency - condition_variable</h5>
        </b-card>
    </div>
    <window-resize></window-resize>
    <!-- Right part -->
    <div id="right">
      <CodeEditor></CodeEditor>
    </div>
  </div>
</template>

<script>
import CodeEditor from '@/components/CodeEditor.vue'
import WindowResize from '@/components/WindowResize.vue'

export default {
  name: 'TaskWorkaround',
  components: {
    CodeEditor,
    WindowResize
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
}

#editor {
  height: 800px;
}

#left {
  width: 50%;
}

#right {
  width: 50%;
}
</style>
