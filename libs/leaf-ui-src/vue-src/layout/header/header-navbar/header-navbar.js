import adminNav from './admin-nav/admin-nav';
import userInfo from './user-info/user-info';
import minimizeBtn from './minimize-btn/minimize-btn';

export default {
    components: {
        'admin-nav': adminNav,
        'leaf-user-info': userInfo,
        'minimize-button': minimizeBtn
    },
    props: {
        siteType: {
            type: String,
            required: true
        },
        orgchartPath: {
            type: String,
            required: true
        },
        innerWidth: {
            type: Number,
            required: true
        },
        name: {
            type: String,
            required: true
        }
    },
    template: `<nav id="leaf-vue-nav" aria-label="main menu">
                    <ul id="nav-navlinks">
                        <minimize-button></minimize-button>
                        <admin-nav :inner-width="innerWidth"
                                   :orgchart-path='orgchartPath'
                                   :site-type='siteType'></admin-nav>
                    </ul>
                    <ul id="nav-user-info">
                        <leaf-user-info :inner-width="innerWidth" :user-name='name'></leaf-user-info>
                    </ul>
               </nav>`
}

