<template>
  <div class="output-editor">
    <b-card-text>
      <div class="output-section" :class="{ error: st.exitCode > 0 }" v-for="st in stages" v-bind:key="st.id">
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
  data () {
    return {
      currentStage: '',
      stages: {}
    }
  },
  created: function () {
    this.reset()
  },
  methods: {
    reset () {
      this.currentStage = '';
      this.stages = {}
    },

    addOutput(str, stage) {
      if (!(stage in this.stages)) {
        alert('error 1');
      }
      if (stage !== this.currentStage) {
        alert('error 2');
      }
      this.stages[stage].output.push(str);
    },

    addEvent(eventName, stage) {
      if (eventName === 'started') {
        if (stage === 'compile') {
          if (this.currentStage !== '') {
            alert('error 3');
          }
        }
        if (stage in this.stages) {
          alert('error 4');
        }

        this.currentStage = stage

        Vue.set(this.stages, stage, {
          id: stage,
          prologue: [],
          output: [],
          epilogue: [],
          exitCode: -1,
          duration: 0.0,
          completed: false,
        });
      } else if (eventName === 'completed') {
        if (this.currentStage === '') {
          alert('error 5');
        }
        if (!(stage in this.stages)) {
          alert('error 6');
        }
        this.stages[stage].completed = true
      }

      // text output
      if (eventName === 'started') {
        if (stage === 'compile') {
          this.stages[stage].prologue.push('Compilation started');
        } else if (stage === 'run') {
          this.stages[stage].prologue.push('Program started');
        }
      } else if (eventName === 'completed') {
        if (stage === 'compile') {
          let text = 'Compilation finished'
          const durationSec = this.stages[stage].duration;
          if (durationSec !== 0.0) {
            const duration = Math.floor(durationSec * 100.0) / 100.0;
            text += ' in ' + duration.toString() + ' sec';
          }
          this.stages[stage].epilogue.push(text);
        } else if (stage === 'run') {
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
