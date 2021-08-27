<template>
  <div class="container">
    <!-- Left part -->
    <div id="left">
      <b-card class="mb-2">
        <h5 class="mb-0">{{ title }}</h5>
      </b-card>
      <b-card id="task-text" v-html="text">
      </b-card>
    </div>
    <window-resize></window-resize>
    <!-- Right part -->
    <div id="right">
      <CodeEditor ref="codeEditor" :init-lang="lang"></CodeEditor>
    </div>
  </div>
</template>

<script>
import CodeEditor from '@/components/CodeEditor.vue'
import WindowResize from '@/components/WindowResize.vue'
import Vue from 'vue'

export default {
  name: 'TaskWorkaround',

  components: {
    CodeEditor,
    WindowResize,
  },

  props: {
    initTitle: String,
    initTaskId: String,
    initLang: String,
  },

  data() {
    return {
      title: this.initTitle,
      text: '',
      taskId: this.initTaskId,
      lang: this.initLang,
    }
  },

  created: function () {
    const getTask = (id) => {
      const url = '/api/v1/tasks/' + id;
      fetch(url)
        .then((resp) => {
          return resp.text();
        })
        .then((text) => {
          return JSON.parse(text);
        })
        .catch(err => {
          Vue.toasted.error(`Failed to fetch task from ${url}: ${err}`, { duration: 8000 });
        })
        .then((json) => {
          this.titile = json.title;
          this.text = window.atob(json.text);
          this.lang = json.lang;
          this.$refs.codeEditor.setTaskId(this.taskId);
          this.$refs.codeEditor.setBuildEnv(json.build_env);
          this.$refs.codeEditor.setSourceCode(window.atob(json.code[0].text));
        })
        .catch(err => {
          Vue.toasted.error(`Failed to parse task from ${url}: ${err}`, { duration: 8000 });
        });
    }
    if (this.taskId) {
      getTask(this.taskId);
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

#task-text {
  padding: 10px;
}

code {
  background-color: #d5d5d5;
  margin: 5px;
  color: #ff0000;
  display: inline;
}
</style>
