import minimizeButton from './minimize-btn/minimize-btn';
import leafWarning from './leaf-warning/leaf-warning';
import scrollWarning from './scroll-warning/scroll-warning';
import adminNav from './admin-nav/admin-nav';
import userInfo from './user-info/user-info';
import './vue-leaf-header.scss';


export const appHeader = Vue.createApp({
    data(){
        return {
            windowTop: 0,
            windowInnerWidth: 800,
            topIsRetracted: false
        }
    },
    components: {
        'minimize-button': minimizeButton,
        'leaf-warning': leafWarning,
        'scrolling-leaf-warning': scrollWarning,
        'admin-leaf-nav': adminNav,
        'leaf-user-info': userInfo
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
            this.topIsRetracted = !this.topIsRetracted;
        }
    }
});



