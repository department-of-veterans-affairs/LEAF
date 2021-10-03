import { createApp } from 'vue';

import headerTop from './layout/header/header-top/header-top';
import scrollWarning from './layout/header/scroll-warning/scroll-warning';
import headerNav from './layout/header/header-navbar/header-navbar';
import './layout/header/vue-leaf-header.scss';


export const app = createApp({
    data(){
        return {
            windowTop: 0,
            windowInnerWidth: 800,
            retracted: { refBool: false }  //needs to be an object so provide will update
        }
    },
    provide(){
        return {
            retracted: this.retracted,
            toggleHeader: this.toggleHeader
        }
    },
    components: {
        'header-nav': headerNav,
        'header-top': headerTop,
        'scrolling-leaf-warning': scrollWarning,
    },
    mounted(){
        this.windowInnerWidth = window.innerWidth;
        document.addEventListener("scroll", this.onScroll);
        window.addEventListener("resize", this.onResize);
    },
    beforeUnmount(){
        document.removeEventListener("scroll", this.onScroll);
        window.removeEventListener("resize", this.onResize);
    },
    methods: {
        onScroll(){
            this.windowTop = window.top.scrollY;
        },
        onResize(){
            this.windowInnerWidth = window.innerWidth;
        },
        toggleHeader(){
            this.retracted.refBool = !this.retracted.refBool;//test
        }
    }
}).mount('#vue-app-mount');

