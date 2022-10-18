//import Vue from "../../vue3/vue.global.prod.js";
import LEAF_FormEditor_App_vue from "./LEAF_FormEditor_App_vue.js";


const app = Vue.createApp(LEAF_FormEditor_App_vue);

/*This opt-in config setting is used to allow computed injections to be used without
the value property.  per Vue dev, will not be needed after next minor update */
app.config.unwrapInjectedRef = true;

app.mount('#vue-formeditor-app');