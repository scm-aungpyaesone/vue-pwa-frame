<template>
  <div ref="test" class="canvas-container">
    <div>
      <div>
        <template v-if="showDiff">
          <div
            v-for="diffArea in diffAreaList"
            :key="diffArea.id"
            class="diff-area"
            :style="{ width:diffArea.width+ 'px', height: diffArea.height+ 'px', top: diffArea.position.x+ 'px', left: diffArea.position.y+ 'px' }"
          ></div>
        </template>
        <img
          src="../../assets/images/image-diff/map_a.png"
          style="border: 1px solid black;"
          id="imgBefore"
        />
      </div>

      <div>
        <img
          id="imgAfter"
          src="../../assets/images/image-diff/map_b.png"
          style="border: 1px solid black;"
        />
      </div>
    </div>
    <p>
      <button id="diff" class="js-compareImages" @click="start">compare images</button>
      <canvas id="cnvDiff" style="border: 1px solid black; margin: 10px;display:none;"></canvas>
    </p>
    <p id="result"></p>
  </div>
</template>
<script>
import pixelmatch from "pixelmatch";
export default {
  data() {
    return {
      diffAreaList: [],
      showDiff : false,
    };
  },
  methods: {
    start() {
      this.diffAreaList = [];
      let cnvBefore = this.convertImageToCanvas("imgBefore");
      let cnvAfter = this.convertImageToCanvas("imgAfter");
      let ctxBefore = cnvBefore.getContext("2d");
      let ctxAfter = cnvAfter.getContext("2d");

      let imgDataBefore = ctxBefore.getImageData(
        0,
        0,
        cnvBefore.width,
        cnvBefore.height
      );
      let imgDataAfter = ctxAfter.getImageData(
        0,
        0,
        cnvAfter.width,
        cnvAfter.height
      );

      const hght = imgDataBefore.height;
      const wdth = imgDataBefore.width;

      let imgDataOutput = new ImageData(wdth, hght);

      let numDiffPixels = pixelmatch(
        imgDataBefore.data,
        imgDataAfter.data,
        imgDataOutput.data,
        wdth,
        hght,
        { threshold: 0.1, includeAA: true }
      );
      console.log(numDiffPixels);
      let indexPixel = 0;
      let prePixel = null;
      let areaList = [];
      for (let y = 0; y < imgDataOutput.height; y++) {
        for (let x = 0; x < imgDataOutput.width; x++) {
          if (
            imgDataOutput.data[indexPixel + 0] == 255 &&
            imgDataOutput.data[indexPixel + 1] == 0 &&
            imgDataOutput.data[indexPixel + 2] == 0
          ) {
            if (!prePixel) {
              areaList.push([
                {
                  x: x,
                  y: y
                }
              ]);
            } else if (
              (x - prePixel.x >= 0 && x - prePixel.x < 100) ||
              (y - prePixel.y >= 0 && y - prePixel.y < 100)
            ) {
              areaList[areaList.length - 1].push({
                x: x,
                y: y
              });
            } else {
              areaList.push([
                {
                  x: x,
                  y: y
                }
              ]);
            }
            prePixel = {
              x: x,
              y: y
            };
          }
          indexPixel += 4;
        }
      }
      areaList.forEach(area => {
        let pixelXList = area
          .map(pixel => pixel.x)
          .sort((a, b) => {
            return a - b;
          });
        let pixelYList = area
          .map(pixel => pixel.y)
          .sort((a, b) => {
            return a - b;
          });
        let pixel = {
          x: null,
          y: null
        };
        pixel.x = {
          min: pixelXList[0],
          max: pixelXList[pixelXList.length - 1]
        };
        pixel.y = {
          min: pixelYList[0],
          max: pixelYList[pixelYList.length - 1]
        };
        this.diffAreaList.push({
          id: "diff-area" + this.diffAreaList.length,
          position: {
            x: pixel.y.min,
            y: pixel.x.min
          },
          width: pixel.x.max - pixel.x.min + 1,
          height: pixel.y.max - pixel.y.min + 1
        });
      });
      console.log(this.diffAreaList);
      this.writeResultToPage(imgDataOutput);
      this.showDiff = true;
    },
    convertImageToCanvas(imageID) {
      let image = document.getElementById(imageID);
      let canvas = document.createElement("canvas");
      canvas.width = image.width;
      canvas.height = image.height;
      canvas.getContext("2d").drawImage(image, 0, 0);
      return canvas;
    },
    writeResultToPage(imgDataOutput) {
      let canvas = document.getElementById("cnvDiff"); //  new HTMLCanvasElement();
      canvas.width = imgDataOutput.width;
      canvas.height = imgDataOutput.height;
      let ctx = canvas.getContext("2d");
      ctx.putImageData(imgDataOutput, 0, 0);
      let result = document.getElementById("result");
      result.appendChild(ctx.canvas);
    }
  }
};
</script>
<style lang="postcss" scoped>
.canvas-container {
  margin: auto;
  width: 350px;
  height: 640px;
  cursor: pointer;
  position: relative;
}
.diff-area {
  position: absolute;
  border: 1px solid;
  background: pink;
  opacity: 0.5;
}
</style>