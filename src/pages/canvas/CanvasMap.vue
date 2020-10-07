<template>
  <div @click="clickOverMap" id="container" class="canvas-container">
    <img src="../../assets/images/map.png" style="width: 100%; height: 100%" />
    <div
      v-for="camera in cameraList"
      class="camera-icon"
      :style="{top: camera.top+ 'px', left: camera.left+ 'px'}"
      :key="camera.id"
    >
      <img @click="clickIcon(camera)" class="camera-img" src="../../assets/images/camera_icon.png" />
    </div>
  </div>
</template>
<script>
export default {
  data() {
    return {
      clickCamera: false,
      cameraList: []
    };
  },
  methods: {
    clickIcon(camera) {
      this.clickCamera = true;
      this.$router.push({
        name: "canvas-detail",
        params: {
          cameraId: camera.id,
          top: camera.top,
          left: camera.left
        }
      });
    },
    clickOverMap(event) {
      if (!this.clickCamera) {
        let cameraId = "cam_" + this.cameraList.length + 1;
        this.cameraList.push({
          id: cameraId,
          left: event.offsetX,
          top: event.offsetY
        });
        console.log(
          "offsetX: " + event.offsetX + " - offsetY: " + event.offsetY
        );
      }
    }
  }
};
</script>
<style scoped>
.canvas-container {
  margin: auto;
  width: 350px;
  height: 640px;
  cursor: pointer;
  position: relative;
}
.camera-icon {
  width: 20px;
  height: 20px;
  border: 1px solid black;
  position: absolute;
}

.camera-img {
  width: 100%;
  height: 100%;
  background: #7dabf7;
  padding: 3px;
}
</style>