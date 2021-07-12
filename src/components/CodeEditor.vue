<template>
  <div>
  <b-card no-body>
    <b-tabs v-model="tabIndex" card>
      <b-tab title="Code" active>
        <b-card-text>
          <MonacoEditor class="editor" v-model="code" :language="language" :options="{minimap:{enabled:false}}"/>
        </b-card-text>
      </b-tab>

      <b-tab title="Output">
        <OutputPane ref="output"></OutputPane>
      </b-tab>
    </b-tabs>

    <div id="button-bar">
      <div id="current-state">{{ stateText }}</div>
      <b-button id="run-btn" variant="success" v-on:click="onRun">Run</b-button>
      <b-dropdown id="menu-btn" no-caret text="..." toggle-text="" class="m-2">
        <b-dropdown-item href="#" v-on:click="onResetCode">Reset code</b-dropdown-item>
        <b-dropdown-item href="#" v-on:click="onToggleBoilerplate">Toggle boilerplate</b-dropdown-item>
        <b-dropdown-item href="#" v-on:click="onSubmitError">Submit an error</b-dropdown-item>
      </b-dropdown>
    </div>
  </b-card>
  </div>
</template>

<script>
import MonacoEditor from 'vue-monaco'
import OutputPane from '@/components/OutputPane.vue'
import Vue from 'vue'

const MAX_CODE_SIZE = 16000;

export default {
  name: 'CodeEditor',
  components: {
    MonacoEditor,
    OutputPane,
  },
  data() {
    return {
      tabIndex: 0,
      originalCode: '#include <iostream>\n#include <chrono>\n#include <thread>\n\nint main() {\n  for (int i = 0; i < 5; i++) {\n    std::this_thread::sleep_for(std::chrono::milliseconds(500));\n    std::cout << "Hello, guys!" << std::endl;\n  }\n  return 0;\n}',
      code: '',
      language: 'cpp',
      state: 'idle'
    }
  },
  created: function() {
    this.onResetCode();
  },
  computed: {
    stateText: function() {
      if (this.state === 'compile') {
        return 'Compiling...';
      } else if (this.state === 'run') {
        return 'Running...';
      }
      return '';
    }
  },
  methods: {
    onResetCode() {
      this.code = this.originalCode;
    },

    onToggleBoilerplate() {
      alert('not implemented');
    },

    onSubmitError() {
      alert('not implemented');
    },

    onRun() {
      if (this.state !== 'idle') {
        return;
      }

      const code = this.code;
      if (code.length > MAX_CODE_SIZE) {
        Vue.toasted.error('Source code is too large (' + code.length.toString() + '), limit is ' + MAX_CODE_SIZE.toString(), { duration: 8000 })
        return;
      }

      this.tabIndex = 1;
      this.$refs.output.reset();
      this.state = 'wait';

      const ws = new WebSocket('ws://localhost:1556/run');

      ws.addEventListener('open', function () {
        const msg = {
          source_files: [
            {
              name: 'src0',
              text: window.btoa(code),
            }
          ]
        };
        ws.send(JSON.stringify(msg));
      });

      var msg = null;
      ws.addEventListener('message', (evt) => {
        try {
          msg = JSON.parse(evt.data)
        } catch (e) {
          Vue.toasted.error('Failed to parse JSON from runjail: ' + e.toString(), { duration: 8000 })
        }

        if ('output' in msg) {
          const text = window.atob(msg.output);
          this.$refs.output.addOutput(text, msg.stage);
        }
        if ('event' in msg) {
          if (msg.event === 'started') {
            this.state = msg.stage;
          }
          this.$refs.output.addEvent(msg.event, msg.stage)
        }
        if ('exit_code' in msg) {
          this.$refs.output.addExitCode(msg.exit_code, msg.stage)
        }
        if ('duration_sec' in msg) {
          this.$refs.output.addDuration(msg.duration_sec, msg.stage)
        }
      });
      ws.addEventListener('close', (evt) => {
        this.state = 'idle';
      });
      ws.addEventListener('error', (evt) => {
        Vue.toasted.error('Websocket error: ' + JSON.stringify(evt), { duration: 8000 })
      });
    },
  }
}
</script>

<style scoped>
.editor {
  height: 720px;
  text-align: left;
}

#button-bar {
  display: flex;
  flex-flow: row wrap;
  justify-content: flex-end;
  align-items: baseline;
}

#run-btn, #menu-btn {
  height: 40px;
}

#current-state {
  margin: 0px 10px;
}
</style>
