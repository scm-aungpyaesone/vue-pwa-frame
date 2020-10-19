<template>
  <div>
    <div class="sheet-thumbnail">
      <canvas id="thumbnail" width="180" height="120"></canvas>
    </div>
    <div class="sheet">
      <div class="current-image" id="current-image">
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
      <div class="prev-image">
        <img :src="getSrc(previousImagePath)" id="imgAfter" />
      </div>
      <div class="result-image">
        <canvas id="cnvDiff"></canvas>
      </div>
    </div>
    <div class="sheet-panel">
      <div class="panel-btn" @click="findDifferences()"><img class="panel-img" :src="getSrc('layers.png')"/></div>
      <div class="panel-btn"><img class="panel-img" :src="getSrc('history.png')"/></div>
    </div>
    <div class="sheet-slider">sheet slider</div>
  </div>
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
import html2canvas from 'html2canvas';
import pixelmatch from "pixelmatch";
export default {
  data() {
    return {
      diffAreaList: [],
      showDiff: false,
      currentImagePath: "image-diff/construction_map_2.jpg",
      previousImagePath: "image-diff/construction_map_4.jpg"
    };
  },
  computed: {
    getSrc() {
      return img => require(`../../assets/images/${img}`);
    }
  },
  methods: {
    takeThumbnailImage() {
      html2canvas(document.getElementById("current-image")).then(function(canvas) {
          let thumbnail = document.getElementById("thumbnail");
          let ctx = thumbnail.getContext("2d");
          ctx.drawImage(canvas, 0, 0, 178, 112);
      });
    },
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

      let numDiffPixels = pixelmatch(
        imgDataBefore.data,
        imgDataAfter.data,
        imgDataOutput.data,
        wdth,
        hght,
        { threshold: 0.1, includeAA: true }
      );
      console.log(numDiffPixels);
      
      this.writeResultToPage(imgDataOutput);
      const notMatchAreaList = this.findAllDifferencePixels(imgDataOutput);
      console.log(notMatchAreaList);
      this.diffAreaList = this.markDiffAreaList(notMatchAreaList);
      this.showDiff = true;
    },
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
    },
    generateArrayRange(startNum, endNum) {
      let tmp = [];
      for (let idx = startNum; idx <= endNum; idx++) {
        tmp.push(idx);
      }
      return tmp;
    },
  },
  updated() {
      this.takeThumbnailImage();
  }
};
</script>