<template>
  <div>
    <div
      v-for="sheet in sheetList"
      :key="sheet.date"
      class="sheet-card"
      @click="transitToSheetDetail(sheet.id)"
    >
      <img :src="getSrc(sheet.image_path)" class="thumbnail-img" />
      <p class="sheet-date">{{sheet.date}}</p>
    </div>
  </div>
</template>
<style scoped>
.thumbnail-img {
  width: 150px;
  height: 80px;
  padding: 5px;
}

.sheet-card {
  border: 1px solid;
  margin: 10px;
  display: flex;
  cursor: pointer;
}
.sheet-date {
  padding: 20px;
  font-size: 30px;
}
</style>
<script>
import constants from "../../constants";
export default {
  data() {
    return {
      sheetList: []
    };
  },
  methods: {
    transitToSheetDetail(sheetId) {
      this.$router.push({ name: "sheet-detail", params: { sheetId: sheetId } });
    }
  },
  computed: {
    getSrc() {
      return img => require(`../../assets/images/${img}`);
    },
  },
  mounted() {
    this.sheetList = constants.IMAGE_DIFF;
  }
};
</script>