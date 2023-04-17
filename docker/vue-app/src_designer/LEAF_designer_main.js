import { createApp } from 'vue';
import LEAF_designer_App from "./LEAF_designer_App.js";

/*TODO: test if still needed.
This opt-in config setting is used to allow computed injections to be used without
the value property.  per Vue dev, will not be needed after next minor update 
app.config.unwrapInjectedRef = true; */

const app = createApp(LEAF_designer_App);
app.mount('#site-designer-app');