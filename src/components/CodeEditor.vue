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
      <b-button id="run-btn" variant="success" :disabled="readyToRun" v-on:click="onRun">Run</b-button>
      <b-button id="stop-btn" v-on:click="onStop">Stop</b-button>
      <b-dropdown id="menu-btn" no-caret text="..." toggle-text="" class="m-2">
        <b-dropdown-item href="#" v-on:click="onResetCode">Reset code</b-dropdown-item>
        <b-dropdown-item href="https://github.com/practicode-org/editor-demo/issues/new" target="_blank">Submit an error</b-dropdown-item>
      </b-dropdown>
    </div>
  </b-card>
  </div>
</template>

<script>
import MonacoEditor from 'vue-monaco'
import OutputPane from '@/components/OutputPane.vue'
import Vue from 'vue'
import MD5 from 'crypto-js/md5'

const MAX_CODE_SIZE = 16000;
const WEBSOCKET_SILENT_WAIT_TIME = 1600; // ms
const WEBSOCKET_CONNECTION_TIMEOUT = 6000; // ms

var ID = function () {
  return Math.random().toString(36).substr(2, 9);
};

export default {
  name: 'CodeEditor',
  components: {
    MonacoEditor,
    OutputPane,
  },

  props: {
    initLang: String
  },

  data() {
    return {
      tabIndex: 0,

      originalCode: '',
      code: '',
      language: this.initLang,
      taskTemplate: '',

      state: 'idle',
      queueNum: 0, // when waiting in a client queue, this is your number in the queue (1 => only one request is ahead of you, you're next)
      stateCompleted: false,
      wsUrl: '',
      requestId: '',
      ws: null,
      timeouts: [],
    }
  },

  created: function() {
    this.fetchRunnerWebsocketUrl();
    this.onResetCode();
  },

  computed: {
    stateText: function() {
      switch (this.state) {
        case 'compile':
          return 'Compiling...';
        case 'run':
          return 'Running...';
        case 'long-wait':
          if (this.queueNum > 0) {
            return 'Number ' + this.queueNum.toString() + ' in queue...';
          }
          return 'Waiting...';
      }
      return '';
    },
    readyToRun() {
      return this.wsUrl.length === 0 || this.state.idle;
    }
  },

  methods: {
    onResetCode() {
      this.code = this.originalCode;
    },

    fetchRunnerWebsocketUrl() {
      this.state = 'wait';
      fetch('/api/v1/runner')
        .then(response => response.json())
        .then(data => {
          if (data && data.RUNNER_WEBSOCKET_URL.length) {
            this.wsUrl = data.RUNNER_WEBSOCKET_URL;
            this.state = 'idle';
          }
        })
        .catch(error => {
          Vue.toasted.error('Failed to fetch runner websocket url: ' + error.toString(), { duration: 8000 })
        });
    },

    onRun() {
      if (this.state !== 'idle') {
        return;
      }

      if (!this.wsUrl.length) {
        Vue.toasted.error('Undefined ws url', { duration: 8000 })
        return;
      }
      if (!this.taskTemplate.length) {
        Vue.toasted.error('Undefined task template', { duration: 8000 })
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

      this.requestId = ID();
      const ws = new WebSocket(this.wsUrl + '?build_env=' + this.taskTemplate + '&request_id=' + this.requestId);

      this.ws = ws;

      ws.addEventListener('open', () => {
        const msg = {
          request_id: this.requestId,
          source_files: [
            {
              name: 'src0',
              text: window.btoa(code),
              hash: MD5(code).toString()
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
          Vue.toasted.error('Failed to parse JSON from runner: ' + e.toString(), { duration: 8000 })
        }

        if ('output' in msg) {
          const text = window.atob(msg.output);
          this.$refs.output.addOutput(text, msg.stage);
        }
        if ('error' in msg) {
          this.$refs.output.addError(msg.description, msg.stage);
        }
        if ('event' in msg) {
          if (msg.event === 'started') {
            this.state = msg.stage;
            this.stateCompleted = false;
          } if (msg.event === 'completed') {
            this.stateCompleted = true;
          }
          this.$refs.output.addEvent(msg.event, msg.stage)
        }
        if ('exit_code' in msg) {
          this.$refs.output.addExitCode(msg.exit_code, msg.stage)
        }
        if ('duration_sec' in msg) {
          this.$refs.output.addDuration(msg.duration_sec, msg.stage)
        }
        if ('queue' in msg) {
          this.queueNum = msg.queue;
        }
      });

      ws.addEventListener('close', (evt) => {
        if (!this.stateCompleted) {
          Vue.toasted.error('Websocket unexpectedly closed', { duration: 8000 })
        }
        this.state = 'idle';
        this.ws = null;
      });

      ws.addEventListener('error', (evt) => {
        Vue.toasted.error('Websocket error: ' + JSON.stringify(evt), { duration: 8000 })
      });

      const tid1 = setTimeout(() => {
        if (this.state === 'wait') {
          this.state = 'long-wait';
        }
      }, WEBSOCKET_SILENT_WAIT_TIME);

      const tid2 = setTimeout(() => {
        if (this.state === 'long-wait' && this.queueNum === 0) {
          this.state = 'idle';
          ws.close();
          this.ws = null;
          Vue.toasted.error('Websocket timeout, couldn\'t connect to backend', { duration: 8000 })
        }
      }, WEBSOCKET_CONNECTION_TIMEOUT);

      this.timeouts.push(tid1);
      this.timeouts.push(tid2);
    },

    onStop() {
      if (this.state !== 'run' &&
        this.state !== 'compile') {
        return;
      }

      for (var tid in this.timeouts) {
        clearTimeout(tid);
      }
      this.timeouts = []

      const msg = {
        request_id: this.requestId,
        command: 'stop'
      };
      this.ws.send(JSON.stringify(msg));
      this.requestId = '';
    },

    setSourceCode(text) {
      // TODO: disable editor before this
      this.originalCode = text;
      this.onResetCode();
    },

    setTaskTemplate(taskTemplate) {
      this.taskTemplate = taskTemplate;
    }
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

#run-btn, #stop-btn, #menu-btn {
  height: 40px;
  margin: 0px 5px;
}

#current-state {
  margin: 0px 10px;
}
</style>
