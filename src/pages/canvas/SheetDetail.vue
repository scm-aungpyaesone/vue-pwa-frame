<template>
  <v-app>
    <div class="sheet-thumbnail">
      <canvas id="thumbnail" width="180" height="120"></canvas>
    </div>
    <div class="sheet">
      <div v-if="currentImagePath" class="current-image" id="current-image">
        <template v-if="showDiff">
          <div
            v-for="diffArea in diffAreaList"
            :key="diffArea.id"
            class="diff-area"
            :style="{ width:diffArea.width+ 'px', height: diffArea.height+ 'px', top: diffArea.position.x+ 'px', left: diffArea.position.y+ 'px' }"
          ></div>
        </template>
        <img :src="getSrc(currentImagePath)" id="imgBefore" @load="takeThumbnailImage" />
      </div>
      <div v-if="previousImagePath" class="prev-image">
        <img :src="getSrc(previousImagePath)" id="imgAfter" />
      </div>
      <div class="result-image">
        <canvas id="cnvDiff"></canvas>
      </div>
    </div>
    <div class="sheet-panel">
      <div class="panel-btn" @click="findDifferences()">
        <img class="panel-img" :src="getSrc('layers.png')" />
      </div>
      <div class="panel-btn" @click="moveToPrevious()">
        <img class="panel-img" :src="getSrc('history.png')" />
      </div>
    </div>
    <div class="sheet-slider">
      <v-slider
        v-model="currentImageIdx"
        :tick-labels="ticksLabels"
        :max="ticksLabels.length - 1"
        step="1"
        ticks="always"
        tick-size="4"
        @change="selectSlider"
      ></v-slider>
    </div>
  </v-app>
</template>
<style scoped>
.sheet {
  width: 100vw;
  height: 100vh;
  overflow: auto;
}
.sheet-thumbnail {
  position: absolute;
  top: 10px;
  right: 10px;
  border: 1px solid black;
  width: 180px;
  height: 120px;
  background: #fff;
  z-index: 100;
}
.sheet-slider {
  position: absolute;
  border-top: 1px solid;
  width: 100vw;
  height: 90px;
  bottom: 0;
  background: #fff;
  padding: 15px;
}
.sheet-panel {
  position: absolute;
  bottom: 90px;
  display: inline-flex;
}
.panel-btn {
  width: 50px;
  height: 50px;
  margin: 5px;
  cursor: pointer;
  padding: 5px;
}
.panel-img {
  width: 40px;
}
.prev-image {
  display: none;
}
.result-image {
  display: none;
}
.current-image {
  position: relative;
  display: inline-block;
}
.diff-area {
  position: absolute;
  border: 1px solid;
  background: #f707c7;
  opacity: 0.5;
}
</style>
<script>
import html2canvas from "html2canvas";
import pixelmatch from "pixelmatch";
import constants from "../../constants";
export default {
  data() {
    return {
      diffAreaList: [],
      showDiff: false,
      currentImagePath: null,
      previousImagePath: null,
      currentImageIdx: 0
    };
  },
  computed: {
    /**
     * This is to get source of image.
     * @param {string} img image path
     * @returns image
     */
    getSrc() {
      return img => require(`../../assets/images/${img}`);
    },
    /**
     * This is to select image date as tick labels from image object list.
     * @returns image date tick labels
     */
    ticksLabels() {
      return constants.IMAGE_DIFF.map(image => image.date);
    }
  },
  methods: {
    /**
     * This is to take thumbnail photo of div (including hightlight areas).
     * This will show thumbnail image at the top of screen.
     * @return void
     */
    takeThumbnailImage() {
      // used html2canvas library to take div capture
      html2canvas(document.getElementById("current-image")).then(function(
        canvas
      ) {
        if (canvas.width && canvas.height) {
          let thumbnail = document.getElementById("thumbnail");
          let ctx = thumbnail.getContext("2d");
          ctx.drawImage(canvas, 0, 0, 178, 112);
        }
      });
    },
    /**
     * This is to start find differences between two images.
     * @returns void
     */
    findDifferences() {
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
      // used pixelmatch library to get hightlight output
      pixelmatch(
        imgDataBefore.data,
        imgDataAfter.data,
        imgDataOutput.data,
        wdth,
        hght,
        { threshold: 0.1, includeAA: true }
      );

      this.writeResultToPage(imgDataOutput);
      const notMatchAreaList = this.findAllDifferencePixels(imgDataOutput);
      this.diffAreaList = this.markDiffAreaList(notMatchAreaList);
      this.showDiff = true;
    },
    /**
     *  This is to find differnce pixels of two images.
     *  Will get only draft of differences (i.e. draft image with red color hightlight.)
     * @param {ImageData} imgDataOutput image output data
     * @returns {array} notMatchAreaList notMatchPixelPoints
     */
    findAllDifferencePixels(imgDataOutput) {
      let indexPixel = 0;
      let notMatchAreaList = [];
      for (let y = 0; y < imgDataOutput.height; y++) {
        for (let x = 0; x < imgDataOutput.width; x++) {
          if (
            imgDataOutput.data[indexPixel + 0] == 255 &&
            imgDataOutput.data[indexPixel + 1] == 0 &&
            imgDataOutput.data[indexPixel + 2] == 0
          ) {
            if (!notMatchAreaList.length) {
              let tmpObj = {};
              tmpObj[`x${x}y${y}`] = { x: x, y: y };
              notMatchAreaList.push(tmpObj);
            } else {
              let addToAreaList = false;
              // checking neighbour pixels
              for (let idx = 0; idx < notMatchAreaList.length; idx++) {
                if (
                  notMatchAreaList[idx][`x${x - 1}y${y}`] ||
                  notMatchAreaList[idx][`x${x - 2}y${y}`] ||
                  notMatchAreaList[idx][`x${x - 3}y${y}`] ||
                  notMatchAreaList[idx][`x${x - 4}y${y}`] ||
                  notMatchAreaList[idx][`x${x - 5}y${y}`] ||
                  notMatchAreaList[idx][`x${x - 1}y${y - 1}`] ||
                  notMatchAreaList[idx][`x${x + 1}y${y - 1}`]
                ) {
                  notMatchAreaList[idx][`x${x}y${y}`] = { x: x, y: y };
                  addToAreaList = true;
                  break;
                }
              }
              if (!addToAreaList) {
                let tmpObj = {};
                tmpObj[`x${x}y${y}`] = { x: x, y: y };
                notMatchAreaList.push(tmpObj);
              }
            }
          }
          indexPixel += 4;
        }
      }
      notMatchAreaList = notMatchAreaList.sort((a, b) =>
        Object.keys(a).length < Object.keys(b).length ? 1 : -1
      );
      return notMatchAreaList;
    },

    /**
     * This is to mark difference area list.
     * This will reduce areas that overlay each others.
     * @param {array} notMatchAreaList
     */
    markDiffAreaList(notMatchAreaList) {
      let areaList = [];
      notMatchAreaList.forEach(area => {
        let pixelXList = Object.values(area)
          .map(pixel => pixel.x)
          .sort((a, b) => {
            return a - b;
          });
        let pixelYList = Object.values(area)
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
        let currentRangeX = this.generateArrayRange(
          pixel.y.min,
          pixel.y.min + pixel.y.max - pixel.y.min + 1
        );
        let currentRangeY = this.generateArrayRange(
          pixel.x.min,
          pixel.x.min + pixel.x.max - pixel.x.min + 1
        );
        let alreadyExisted = false;
        for (let idx = 0; idx < areaList.length; idx++) {
          let tmpRangeX = this.generateArrayRange(
            areaList[idx].position.x,
            areaList[idx].position.x + areaList[idx].height
          );
          let tmpRangeY = this.generateArrayRange(
            areaList[idx].position.y,
            areaList[idx].position.y + areaList[idx].width
          );
          let tmpCheckX = currentRangeX.filter(x => tmpRangeX.includes(x));
          let tmpCheckY = currentRangeY.filter(y => tmpRangeY.includes(y));
          // check diff area overlay or not
          if (tmpCheckX.length && tmpCheckY.length) {
            alreadyExisted = true;
            if (tmpRangeX[0] - currentRangeX[0] > 0) {
              areaList[idx].height += tmpRangeX[0] - currentRangeX[0];
            }
            if (
              tmpRangeX[tmpRangeX.length - 1] -
                currentRangeX[currentRangeX.length - 1] <
              0
            ) {
              areaList[idx].height -=
                tmpRangeX[tmpRangeX.length - 1] -
                currentRangeX[currentRangeX.length - 1];
            }
            if (tmpRangeY[0] - currentRangeY[0] > 0) {
              areaList[idx].width += tmpRangeY[0] - currentRangeY[0];
            }
            if (
              tmpRangeY[tmpRangeY.length - 1] -
                currentRangeY[currentRangeY.length - 1] <
              0
            ) {
              areaList[idx].width -=
                tmpRangeY[tmpRangeY.length - 1] -
                currentRangeY[currentRangeY.length - 1];
            }
            break;
          }
        }
        if (!alreadyExisted) {
          areaList.push({
            id: "diff-area" + areaList.length,
            position: {
              x: pixel.y.min,
              y: pixel.x.min
            },
            width: pixel.x.max - pixel.x.min + 1,
            height: pixel.y.max - pixel.y.min + 1
          });
        }
      });
      return areaList;
    },
    /**
     * This is to convert image to canvas to compare.
     * @param {string} imageID
     * @returns canvas
     */
    convertImageToCanvas(imageID) {
      let image = document.getElementById(imageID);
      let canvas = document.createElement("canvas");
      canvas.width = image.width;
      canvas.height = image.height;
      canvas.getContext("2d").drawImage(image, 0, 0);
      return canvas;
    },

    /**
     * This is to write the output difference images.
     * @param {ImageData} imgDataOutput
     */
    writeResultToPage(imgDataOutput) {
      let canvas = document.getElementById("cnvDiff"); //  new HTMLCanvasElement();
      canvas.width = imgDataOutput.width;
      canvas.height = imgDataOutput.height;
      let ctx = canvas.getContext("2d");
      ctx.putImageData(imgDataOutput, 0, 0);
    },
    /**
     * This is tp generate array range (e.g (10,15) will get [10,11,12,13,14,15])
     * @param {number} startNum
     * @param {number} endNum
     * @returns generateRange
     */
    generateArrayRange(startNum, endNum) {
      let tmp = [];
      for (let idx = startNum; idx <= endNum; idx++) {
        tmp.push(idx);
      }
      return tmp;
    },
    /**
     * This is to handle selection of slider.
     * @returns void
     */
    selectSlider() {
      this.diffAreaList = [];
      this.currentImagePath =
        constants.IMAGE_DIFF[this.currentImageIdx].image_path;
      this.previousImagePath =
        this.currentImageIdx - 1 < 0
          ? constants.IMAGE_DIFF[this.currentImageIdx].image_path
          : constants.IMAGE_DIFF[this.currentImageIdx - 1].image_path;
    },
    /**
     * This is to move previous image.
     * @returns void
     */
    moveToPrevious() {
      this.currentImageIdx =
        this.currentImageIdx - 1 < 0
          ? this.currentImageIdx
          : this.currentImageIdx - 1;
      this.selectSlider();
    }
  },
  updated() {
    this.takeThumbnailImage();
  },
  mounted() {
    const tmpIdx = constants.IMAGE_DIFF.findIndex(
      image => image.id === this.$route.params.sheetId
    );
    if (tmpIdx < 0) {
      this.$router.push({ name: "sheet-list" });
    } else {
      this.currentImageIdx = tmpIdx;
      this.selectSlider();
    }
  }
};
</script>