<template>
  <div class="output-editor">
    <b-card-text>
      <div class="output-section" :class="{ error: st.exitCode > 0 || st.error }" v-for="st in stages" v-bind:key="st.id">
        <div v-for="(t, idx) in st.prologue" class="event-msg" v-bind:key="idx">
          {{ t }}
        </div>
        <div v-for="(t, idx) in st.output" v-bind:key="idx">
          {{ t }}
        </div>
        <div v-for="(t, idx) in st.epilogue" class="event-msg" v-bind:key="idx">
          {{ t }}
        </div>
      </div>
    </b-card-text>
  </div>
</template>

<script>
import Vue from 'vue'

export default {
  name: 'OutputPane',
  components: {
  },
  data() {
    return {
      currentStage: '',
      stages: {},
    }
  },
  created: function() {
    this.reset()
  },
  methods: {
    reset() {
      this.currentStage = '';
      this.stages = {}
    },

    addOutput(str, stage) {
      if (!(stage in this.stages)) {
        Vue.toasted.error('Error: got output, but there\'s no stage \'' + stage + '\'', { duration: 8000 })
      }
      if (stage !== this.currentStage) {
        Vue.toasted.error('Error: got ouput, but stage \'' + stage + '\' doesn\'t match current stage \'' + this.currentStage + '\'', { duration: 8000 })
      }
      if (str === '') {
        return;
      }

      // split on \n
      const strs = str.split('\n');
      for (const i in strs) {
        const s = strs[i];
        if (s === '') {
          continue;
        }
        // append to the previous line, if it's not finished by a newline
        if (this.stages[stage].newLine) {
          this.stages[stage].output.push(s);
        } else {
          const output = this.stages[stage].output;
          output[output.length - 1] += s;
        }
      }
      this.stages[stage].newLine = str[str.length - 1] === '\n';
    },

    ensureStage(stage) {
      if (!(stage in this.stages)) {
        Vue.set(this.stages, stage, {
          id: stage,
          prologue: [],
          output: [],
          epilogue: [],
          exitCode: -1,
          duration: 0.0,
          completed: false,
          error: false, // true when runner had an error
          newLine: true // next output line should be new line
        });
      }
    },

    addError(description, stage) {
      this.ensureStage(stage);
      this.stages[stage].epilogue.push(description);
      this.stages[stage].error = true;
    },

    addEvent(eventName, stage) {
      if (eventName === 'started') {
        if (stage === 'compile' || stage === 'compile_tests') {
          if (this.currentStage !== '') {
            Vue.toasted.error('Error: got started event, but current stage is \'' + stage + '\'', { duration: 8000 })
          }
        }
        if (stage in this.stages) {
          Vue.toasted.error('Error: got an event, but there\'s no stage \'' + stage + '\'', { duration: 8000 })
        }

        this.currentStage = stage
        this.ensureStage(stage);
      } else if (eventName === 'completed') {
        if (this.currentStage === '') {
          Vue.toasted.error('Error: got completed event, while current stage is empty', { duration: 8000 })
        }
        if (!(stage in this.stages)) {
          Vue.toasted.error('Error: got an event, but there\'s no stage \'' + stage + '\'', { duration: 8000 })
        }
        this.stages[stage].completed = true
      }

      // text output
      if (eventName === 'started') {
        if (stage === 'compile' || stage === 'compile_tests') {
          this.stages[stage].prologue.push('Compilation started');
        } else if (stage === 'run' || stage === 'run_tests') {
          this.stages[stage].prologue.push('Program started');
        }
      } else if (eventName === 'completed') {
        if (stage === 'compile' || stage === 'compile_tests') {
          let text = 'Compilation finished'
          const durationSec = this.stages[stage].duration;
          if (durationSec !== 0.0) {
            const duration = Math.floor(durationSec * 100.0) / 100.0;
            text += ' in ' + duration.toString() + ' sec';
          }
          this.stages[stage].epilogue.push(text);
        } else if (stage === 'run' || stage === 'run_tests') {
          let text = 'Program finished';
          const exitCode = this.stages[stage].exitCode;
          if (exitCode !== -1) {
            text += ' with exit code ' + exitCode.toString();
          }
          const durationSec = this.stages[stage].duration;
          if (durationSec !== 0.0) {
            const duration = Math.floor(durationSec * 100.0) / 100.0;
            text += ' in ' + duration.toString() + ' sec';
          }
          this.stages[stage].epilogue.push(text);
        }

        this.stages[stage].completed = true;
      }
    },

    addExitCode(code, stage) {
      this.stages[stage].exitCode = code
    },

    addDuration(seconds, stage) {
      this.stages[stage].duration = seconds
    },
  }
}
</script>

<style scoped>
.editor {
  height: 720px;
  text-align: left;
}
.output-editor {
  /*height from the .editor */
  height: 720px;
  overflow-y: auto;
  word-wrap: break-word;
}
.output-section {
  margin: 2px 2px;
  padding: 2px 2px;
  border-top: 1px solid #bababa;
}

.output-section div {
  margin: 2px 2px;
  padding: 2px 2px;
  font-family: monospace;
}

.error {
  background-color: #fad0c4;
}

.event-msg {
  color: #5a5aff;
}

</style>
