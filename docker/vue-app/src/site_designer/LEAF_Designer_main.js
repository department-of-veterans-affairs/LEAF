import { createApp } from 'vue';
import LEAF_Designer_App from "./LEAF_Designer_App.js";
import router from "./router";

const app = createApp(LEAF_Designer_App);

app.use(router);
app.mount('#site-designer-app');