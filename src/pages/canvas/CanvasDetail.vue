<template>
  <div>
    <div id="range">
      <div
        id="draggable-container"
        ref="draggableContainer"
        @touchstart="dragTouchDown"
        @mousedown="dragMouseDown"
        :style="{top: '-' +topCanvas+ 'px', left: '-' + leftCanvas+ 'px'}"
      >
        <img src="../../assets/images/map.png" style="width: 100%; height: 100%" />
        <div class="camera-icon" :style="{top: top+ 'px', left: left+ 'px'}">
          <img class="camera-img" src="../../assets/images/camera_icon.png" />
        </div>
      </div>
    </div>
    <div style="text-align: center;padding: 10px;">
      <input
        class="inputfile"
        type="file"
        name="file"
        id="file"
        accept="image/*"
        capture="camera"
        @change="takeCapture"
      />
      <label for="file">Take Photo</label>
      <div>
        <span>{{captureName}}</span>
      </div>
      <div class="send-btn" @click="sendRequest">Send</div>
    </div>
  </div>
</template>
<script>
export default {
  props: ["top", "left"],
  data: function() {
    return {
      positions: {
        clientX: undefined,
        clientY: undefined,
        movementX: 0,
        movementY: 0
      },
      captureFile: null,
      captureName: ""
    };
  },
  computed: {
    leftCanvas() {
      return this.left - 250;
    },
    topCanvas() {
      return this.top - 150;
    }
  },
  created() {
    console.log(this.top);
    console.log(this.left);
  },
  methods: {
    takeCapture(event) {
      this.captureFile = event.srcElement.files[0];
      this.captureName = this.captureFile.name;
    },
    sendRequest() {
      alert(`x : ${this.top}, y : ${this.left}, image : ${this.captureName}`);
    },
    dragTouchDown: function(event) {
      event.preventDefault();
      // get touch position at startup:
      this.positions.clientX = event.changedTouches[0].clientX;
      this.positions.clientY = event.changedTouches[0].clientY;
      document.ontouchmove = this.elementTouchDrag;
      document.ontouchend = this.closeDragElement;
    },
    dragMouseDown: function(event) {
      event.preventDefault();
      // get the mouse cursor position at startup:
      this.positions.clientX = event.clientX;
      this.positions.clientY = event.clientY;
      document.onmousemove = this.elementDrag;
      document.onmouseup = this.closeDragElement;
    },
    elementTouchDrag: function(event) {
      this.positions.movementX =
        this.positions.clientX - event.changedTouches[0].clientX;
      this.positions.movementY =
        this.positions.clientY - event.changedTouches[0].clientY;
      this.positions.clientX = event.changedTouches[0].clientX;
      this.positions.clientY = event.changedTouches[0].clientY;
      // set the element's new position:
      this.$refs.draggableContainer.style.top =
        this.$refs.draggableContainer.offsetTop -
        this.positions.movementY +
        "px";
      this.$refs.draggableContainer.style.left =
        this.$refs.draggableContainer.offsetLeft -
        this.positions.movementX +
        "px";
    },

    elementDrag: function(event) {
      event.preventDefault();
      this.positions.movementX = this.positions.clientX - event.clientX;
      this.positions.movementY = this.positions.clientY - event.clientY;
      this.positions.clientX = event.clientX;
      this.positions.clientY = event.clientY;
      // set the element's new position:
      this.$refs.draggableContainer.style.top =
        this.$refs.draggableContainer.offsetTop -
        this.positions.movementY +
        "px";
      this.$refs.draggableContainer.style.left =
        this.$refs.draggableContainer.offsetLeft -
        this.positions.movementX +
        "px";
    },
    closeDragElement() {
      document.onmouseup = null;
      document.onmousemove = null;
      document.ontouchup = null;
      document.ontouchmove = null;
    }
  }
};
</script>
<style scoped>
body {
  padding: 10px;
}
#draggable-container {
  width: 100vw;
  height: 100vh;
  background-color: #666;
  position: absolute;
}
#range {
  margin: auto;
  width: 350px;
  height: 350px;
  overflow: hidden;
  border: 1px solid black;
  position: relative;
}

.camera-icon {
  width: 40px;
  height: 40px;
  border: 1px solid black;
  position: absolute;
}

.camera-img {
  width: 100%;
  height: 100%;
  background: #7dabf7;
  padding: 3px;
}

.inputfile {
  width: 0.1px;
  height: 0.1px;
  opacity: 0;
  overflow: hidden;
  position: absolute;
  z-index: -1;
}

.inputfile + label {
  font-size: 1.25em;
  font-weight: 700;
  color: white;
  background-color: black;
  display: inline-block;
  cursor: pointer;
}

.inputfile:focus + label,
.inputfile + label:hover {
  background-color: red;
}

.send-btn {
  margin: 80px auto;
  font-size: 20px;
  border-radius: 50%;
  width: 80px;
  height: 80px;
  background: red;
  padding-top: 27px;
  cursor: pointer;
}
</style>