//warning section with triangle TODO change to top-nav and include site info
export default {
    props: {
        propSecure: {
            type: String,
            required: true
        },
        title: {
            type: String,
            required: true
        },
        city: {
            type: String,
            required: true
        },
        logo: {
            type: String,
            required: true
        },
        qrcodeUrl: {
            type: String,
            required: true
        }
    },
    //slicing src part of logo rather than changing it in index.php
    // because other parts of the site are using this variable
    template:
        `<div id="header-top">
            <a id="logo" href="./" title="Home" aria-label="LEAF home">
                <img :src="logo.slice(logo.indexOf('=')+2,logo.indexOf('alt')-2)" alt="VA logo" />
            </a>
            <div><em><h1 id="site-info-title">{{title}}</h1><h2 id="site-info-city">{{city}}</h2></em></div>
            <div v-if="propSecure==='0'" id="leaf-warning">
                <div>
                    <h3>Do not enter PHI/PII: this site is not yet secure</h3>
                    <p><a href="../report.php?a=LEAF_start_leaf_secure_certification">Start certification process</a></p>
                </div>
                <div><i class="fas fa-exclamation-triangle fa-2x"></i></div>
            </div>
            <div v-if="qrcodeUrl != ''">
                <img class="print nodisplay" style="width: 72px" :src="'../../libs/qrcode/?encode=' + qrcodeUrl" alt="QR code" />
            </div>   
        </div>`
}