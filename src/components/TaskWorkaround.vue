<template>
  <div class="container">
    <!-- Left part -->
    <div id="left">
        <b-card class="mb-2">
          <h5 class="mb-0">{{ title }}</h5>
        </b-card>
        <b-card>
          {{ text }}
        </b-card>
    </div>
    <window-resize></window-resize>
    <!-- Right part -->
    <div id="right">
      <CodeEditor :init-lang="lang"></CodeEditor>
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
  props: {
    initTitle: String,
    initTaskId: String,
    initLang: String
  },
  data () {
    return {
      title: this.initTitle,
      text: '',
      taskId: this.initTaskId,
      lang: this.initLang
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
