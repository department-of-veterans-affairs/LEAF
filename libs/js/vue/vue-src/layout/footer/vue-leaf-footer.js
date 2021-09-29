const appFooter = Vue.createApp({

});

appFooter.component('vue-footer', {
    props: {
        hideFooter: {
            type: String, //json encoded boolean (is usually null)
            default: "null"
        },
        productName: {
            type: String,
        },
        version: {
            type: String
        },
        revision: {
            type: String
        }
    },
    template: `<footer v-if="hideFooter !== 'true'" id="footer" class="usa-footer leaf-footer noprint">
            <a id="versionID" href="../?a=about">{{productName}}<br />Version {{version}} r{{revision}}</a>
            </footer>`
});

appFooter.mount('#leaf-vue-footer');