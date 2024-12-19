import { createApp } from 'vue';
import LEAF_FormEditor_App_vue from "./LEAF_FormEditor_App_vue.js";
import router from "./router";

const app = createApp(LEAF_FormEditor_App_vue);

app.use(router);
app.mount('#vue-formeditor-app');