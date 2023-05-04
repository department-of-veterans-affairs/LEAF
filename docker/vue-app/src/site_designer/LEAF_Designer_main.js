import { createApp } from 'vue';
import LEAF_Designer_App from "./LEAF_Designer_App.js";

const app = createApp(LEAF_Designer_App);

/* This opt-in config setting is used to allow computed injections to be used without
the value property.  per Vue dev, will not be needed after next minor update */
app.config.unwrapInjectedRef = true;

app.mount('#site-designer-app');