const appHeader = Vue.createApp({
    data(){
        return {
            windowTop: 0,
            windowInnerWidth: 800,
            topIsRetracted: false
        }
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

appHeader.component('minimize-button', {
    props: {
        isRetracted: {
            type: Boolean,
            required: true
        }
    },
    computed: {
        buttonTitle(){
            return this.$props.isRetracted ? 'Display full header' : 'Minimize header';
        }
    },
    template: `<li role="button" id="header-toggle-button" :title="buttonTitle">
                <a href="#" @click.prevent="$emit('toggle-top-header')"><i :class="[isRetracted ? 'fas fa-angle-double-down': 'fas fa-angle-double-up']"></i></a>
               </li>`
});

//warning section with triangle
appHeader.component('leaf-warning', {
    data(){
        return {
            leafSecure: this.$props.propSecure
        }
    },
    props: {
        propSecure: {
            type: String,
            required: true
        }
    },
    template:
        `<div v-if="leafSecure==='0'" id="leaf-warning">
            <div>
                <h3>Do not enter PHI/PII: this site is not yet secure</h3>
                <p><a href="../report.php?a=LEAF_start_leaf_secure_certification">Start certification process</a></p>
            </div>
            <div><i class="fas fa-exclamation-triangle fa-2x"></i></div>
        </div>`
});
//scrolling warning banner
appHeader.component('scrolling-leaf-warning', {
    data(){
        return {
            leafSecure: this.$props.propSecure
        }
    },
    props: {
        propSecure: {
            type: String,
            required: true,
        },
        bgColor: {
            type: String,
            required: false,
            default: 'rgb(250,75,50)'
        },
        textColor: {
            type: String,
            required: false,
            default: 'rgb(255,255,255)'
        }
    },
    template:
        `<p v-if="leafSecure==='0'" id="scrolling-leaf-warning" :style="{backgroundColor: bgColor, color: textColor}"><slot></slot></p>`
});

//admin view links
appHeader.component('admin-leaf-nav', {
    data(){
        return {
            navItems: [
                { title: 'Home', link: '../' },
                { title: 'Report Builder', link: '../?a=reports' },
                { title: 'Site Links', link: '#',
                    subLinks: [
                        { title: 'Nexus: Org Charts', link: '../' + this.$props.orgchartPath }
                    ],
                    subLinkOpen: false,
                    isClickedOn: false },
                { title: 'Admin', link: '#',
                    subLinks: [
                        { title: 'Admin Home', link: './' },
                        { title: 'User Access', link: '#',
                            subLinks: [
                                { title: 'User Access Groups', link: '?a=mod_groups' },
                                { title: 'Service Chiefs', link: '?a=mod_svcChief' }
                            ],
                            subLinkOpen: false,
                            isClickedOn: false },
                        { title: 'Workflow Editor', link: '?a=workflow', renderCondition: this.$props.siteType !== 'national_subordinate' },
                        { title: 'Form Editor', link: '?a=form', renderCondition: this.$props.siteType !== 'national_subordinate' },
                        { title: 'LEAF Library', link: '?a=formLibrary', renderCondition: this.$props.siteType !== 'national_subordinate' },
                        { title: 'Site Settings', link: '?a=mod_system' },
                        { title: 'Site Distribution', link: '../report.php?a=LEAF_National_Distribution', renderCondition: this.$props.siteType === 'national_primary' },
                        { title: 'Timeline Explorer', link: '../report.php?a=LEAF_Timeline_Explorer' },
                        { title: 'Toolbox', link: '#',
                            subLinks: [
                                { title: 'Import Spreadsheet', link: '../report.php?a=LEAF_import_data' },
                                { title: 'Mass Action', link: '../report.php?a=LEAF_mass_action' },
                                { title: 'Initiator New Account', link: '../report.php?a=LEAF_request_initiator_new_account' },
                                { title: 'Sitemap Editor', link: '../report.php?a=LEAF_sitemaps_template' },
                            ],
                            subLinkOpen: false,
                            isClickedOn: false },
                        { title: 'LEAF Developer', link: '#',
                            subLinks: [
                                { title: 'Template Editor', link: '?a=mod_templates' },
                                { title: 'Email Template Editor', link: '?a=mod_templates_email' },
                                { title: 'LEAF Programmer', link: '?a=mod_templates_reports' },
                                { title: 'File Manager', link: '?a=mod_file_manager' },
                                { title: 'Search Database', link: '../?a=search' },
                                { title: 'Sync Services', link: '?a=admin_sync_services' },
                                { title: 'Update Database', link: '?a=admin_update_database' }
                            ],
                            subLinkOpen: false,
                            isClickedOn: false },
                    ],
                    subLinkOpen: false,
                    isClickedOn: false },
            ],
        }
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
    },
    computed: {
        isSmallScreen(){
            return this.$props.innerWidth < 600;
        }
    },
    methods: {
        toggleSubModal(event, item) {
            if(item.subLinks) {
                event.preventDefault();
                item.isClickedOn = !item.isClickedOn;
                if (item.isClickedOn){
                    this.modalOn(item);
                } else {
                    this.modalOff(item);
                }
                this.adjustIndex(event);
            }
        },
        adjustIndex(event){
            //so that the newest submenu opened will be on top
            const elLi = Array.from(document.querySelectorAll('nav li'));
            elLi.forEach(ele => {
                ele.style.zIndex = 100;
            });
            event.currentTarget.parentElement.style.zIndex = 200;
        },
        modalOn(item) {
            if (item.subLinks) {
                item.subLinkOpen = true;
            }
        },
        modalOff(item) {
            if (item.subLinks && !item.isClickedOn) {
                item.subLinkOpen = false;
            }
        }
    },
    template:
        `<li :key="item.title" 
            v-for="item in navItems"
            
            @mouseenter="modalOn(item)"
            @mouseleave="modalOff(item)">
            <a  :href="item.link" 
                @click="toggleSubModal($event,item)"
                :class="{ 'active': item.isClickedOn }">{{ item.title }}
                <i v-if="item.subLinks" :style="{color: !item.subLinkOpen ? '' : 'white'}" class="fas fa-angle-down"></i>
            </a>
            
            <template v-if="item.subLinks && item.subLinkOpen">
                <ul class="sublinks"> 
                    <li :key="subLink.title" 
                        v-for="subLink in item.subLinks" 
                        :style="{display: !subLink.hasOwnProperty('renderCondition') || subLink.renderCondition === true ? 'block' : 'none'}"
                        @mouseleave="modalOff(subLink)"
                        @mouseenter="modalOn(subLink)">
                        <a :href="subLink.link"
                            :target="subLink.title==='Nexus: Org Charts' ? '_blank' : '_self'"
                            @click="toggleSubModal($event,subLink)" 
                            :class="{'active' : subLink.subLinkOpen || (subLink.subLinks && isSmallScreen)}">
                            {{ subLink.title }} 
                            <i v-if="subLink.subLinks && !isSmallScreen" :style="{color: !subLink.subLinkOpen ? '' : 'white'}" class="fas fa-caret-right"></i>
                        </a>
                        
                        <template v-if="subLink.subLinks && (subLink.subLinkOpen || isSmallScreen)">
                            <ul class="inner-sublinks"> 
                                <li :key="sub.title" v-for="sub in subLink.subLinks">
                                <a :href="sub.link">{{ sub.title }}</a>
                                </li>
                            </ul>  
                        </template>
                    </li>
                </ul> 
            </template>
        </li>`
});

//user info section
appHeader.component('leaf-user-info', {
    data(){
        return {
            userItems: {
                user: this.$props.userName,
                primaryAdmin: ''
            },
            subLinkOpen: false,
            isClickedOn: false
        }
    },
    props: {
        userName: {
            type: String
        },
        innerWidth: {
            type: Number,
            required: true
        }
    },
    methods: {
        toggleSubModal(event) {
            event.preventDefault();
            this.isClickedOn = !this.isClickedOn;
            if (this.isClickedOn){
                this.modalOn();
            } else {
                this.modalOff();
            }
        },
        modalOn() {
            this.subLinkOpen = true;
        },
        modalOff() {
            if (!this.isClickedOn) {
                this.subLinkOpen = false;
            }
        }
    },
    created(){
        fetch('../api/system/primaryadmin', {
            "method": "GET"
        })
            .then(res => res.json())
            .then(data => {
                let emailString = data['Email'] !== '' ? " - " + data['Email'] : '';
                if(data["Fname"] !== undefined && data["Lname"] !== undefined){
                    this.userItems.primaryAdmin = data['Fname'] + " " + data['Lname'] + emailString;
                }
                else {
                    this.userItems.primaryAdmin = data["userName"] !== undefined ? data["userName"] : 'Not Set';
                }
            });
    },
    template:
        `<li @mouseleave="modalOff" @mouseenter="modalOn">
            <a href="#" @click="toggleSubModal">
                <i id="nav-user-icon" class='fas fa-user-circle' alt='User Account Menu'>&nbsp;</i>
                <span>{{ this.userItems.user }}</span> 
                <i :style="{color: !subLinkOpen ? '' : 'white'}" class="fas fa-angle-down"></i> 
            </a>
            <template v-if="subLinkOpen">
                <ul class="sublinks">
                    <li><a href="#">Your primary Admin:<p id="primary-admin" class="leaf-user-menu-name">{{userItems.primaryAdmin}}</p></a></li>
                    <li><a href="../?a=logout">Sign Out</a></li>
                </ul>
            </template>
        </li>`
});

appHeader.mount('#vue-leaf-header');