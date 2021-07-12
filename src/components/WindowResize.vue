<template>
  <div class="move-resize-element"></div>
</template>

<script>
export default {
  data() {
    return {
      currentPrev: '',
      currentNext: '',
      previousWidth: '',
      nextWidth: '',
      posintZero: ''
    }
  },
  methods: {
    start(event) {
      this.posintZero = event.pageX
      this.currentPrev = event.target.previousElementSibling
      this.currentNext = event.target.nextElementSibling
      this.previousWidth = +((this.currentPrev.style.width + '' || this.currentPrev.getBoundingClientRect().width + '').match(/-?\d+(?:\.\d+)?/g)[0])
      this.nextWidth = +((this.currentNext.style.width + '' || this.currentNext.getBoundingClientRect().width + '').match(/-?\d+(?:\.\d+)?/g)[0])

      event.target.parentNode.addEventListener('mousemove', this.resizeElements)
      document.addEventListener('mouseup', this.end)
    },

    resizeElements(event) {
      const currentValue = event.pageX - this.posintZero
      this.currentPrev.style.width = this.previousWidth + currentValue + 'px'
      this.currentNext.style.width = this.nextWidth - currentValue + 'px'
    },

    end() {
      const resize = document.querySelector('.move-resize-element')
      resize.parentNode.removeEventListener('mousemove', this.resizeElements)
      document.removeEventListener('mouseup', this.end)
    },

    getCoords(elem) {
      const box = elem.getBoundingClientRect();

      const body = document.body;
      const docEl = document.documentElement;

      const scrollTop = window.pageYOffset || docEl.scrollTop || body.scrollTop;
      const scrollLeft = window.pageXOffset || docEl.scrollLeft || body.scrollLeft;

      const clientTop = docEl.clientTop || body.clientTop || 0;
      const clientLeft = docEl.clientLeft || body.clientLeft || 0;

      const top = box.top + scrollTop - clientTop;
      const left = box.left + scrollLeft - clientLeft;

      return {
        top: top,
        left: left
      }
    },
  },
  mounted() {
    const resize = document.querySelector('.move-resize-element')

    resize.addEventListener('mousedown', this.start)
  }
}
</script>

<style>
.move-resize-element {
  padding: 2px;
  cursor: col-resize;
}
</style>
