import Vue from "vue";
import VueRouter from "vue-router";

// import Login from "../pages/user/Login";
// import PostList from "../pages/post/PostList";
import CanvasMap from "../pages/canvas/CanvasMap";
import CanvasDetail from "../pages/canvas/CanvasDetail";
import ImageDiff from "../pages/canvas/ImageDiff";
// import store from "../store";

Vue.use(VueRouter);

const routes = [
  // {
  //   path: "/login",
  //   name: "login",
  //   component: Login,
  // },
  // {
  //   path: "/post/list",
  //   name: "post-list",
  //   component: PostList,
  // },
  {
    path: "/canvas",
    name: "canvas",
    component: CanvasMap,
  },
  {
    path: "/canvas/:cameraId",
    name: "canvas-detail",
    component: CanvasDetail,
    props: true,
  },
  {
    path: "/image-diff",
    name: "image-dff",
    component: ImageDiff,
  },
  // {
  //   path: "/*",
  //   redirect: "/post/list",
  // },
];

const router = new VueRouter({
  mode: "history",
  routes,
});

/**
 * This is to handle and check authentication for routing.
 */
// router.beforeEach((to, from, next) => {
//   const loggedIn = store.getters.isLoggedIn;
//   if (!loggedIn && to.name != "login") {
//     return next("/login");
//   }
//   next();
// });

export default router;
