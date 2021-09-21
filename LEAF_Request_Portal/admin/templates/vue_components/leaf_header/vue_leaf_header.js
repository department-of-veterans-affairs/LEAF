const app = Vue.createApp({
    data(){
        return {
            windowTop: 0,
            adminLinks: [
                { title: 'Home', link: '../', renderCondition: true },
                { title: 'Report Builder', link: '../?a=reports', renderCondition: true },
                { title: 'Site Links', link: '#',
                    subLinks: [
                        { title: 'Nexus: Org Charts', link: '../{$orgchartPath}' }
                    ],
                    subLinkOpen: false},
                { title: 'Admin', link: '#',
                    subLinks: [
                        { title: 'User Access', link: '#',
                            subLinks: [
                                { title: 'User Access Groups', link: '?a=mod_groups' },
                                { title: 'Service Chiefs', link: '?a=mod_svcChief' }
                            ],
                            subLinkOpen: false},
                        { title: 'Workflow Editor', link: '?a=workflow' },
                        { title: 'Form Editor', link: '?a=form' },
                        { title: 'LEAF Library', link: '?a=formLibrary' },
                        { title: 'Site Settings', link: '?a=mod_system' },
                        { title: 'Timeline Explorer', link: '../report.php?a=LEAF_Timeline_Explorer' },
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
                            subLinkOpen: false},
                        { title: 'Toolbox', link: '#',
                            subLinks: [
                                { title: 'Import Spreadsheet', link: '../report.php?a=LEAF_import_data' },
                                { title: 'Mass Action', link: '../report.php?a=LEAF_mass_action' },
                                { title: 'Initiator New Account', link: '../report.php?a=LEAF_request_initiator_new_account' },
                                { title: 'Sitemap Editor', link: '../report.php?a=LEAF_sitemaps_template' },
                            ],
                            subLinkOpen: false},

                    ], subLinkOpen: false },
            ],
        }
    },
    mounted(){
        document.addEventListener("scroll", this.onScroll);
    },
    beforeUnmount(){
        document.removeEventListener("scroll", this.onScroll);
    },
    methods: {
        onScroll(){
            this.windowTop = window.top.scrollY;
        }
    }
});


//TODO: ideally in own files.
//warning banner
app.component('leaf-warning', {
    template:
        `<div id="leaf-warning">
            <div>
                <h3>Do not enter PHI/PII: this site is not yet secure</h3>
                <p><a>Start certification process</a></p>
            </div>
            <div> &nbsp; <i class="fas fa-exclamation-triangle fa-3x"></i></div>
        </div>`
});

//scrolling warning banner
app.component('scrolling-leaf-warning', {
    props: {
        bgColor: {
            type: String,
            required: false,
            default: 'rgb(250,75,50)'
        },
        textColor: {
            type: String,
            required: false,
            default: 'rgb(255,255,255)'
        },
    },
    template:
        `<p id="scrolling-leaf-warning" :style="{backgroundColor: bgColor, color: textColor}"><slot></slot></p>`
});

//nav (nav, ul, li, and sublists)
app.component('admin-leaf-nav', {
    data(){
        return {
            orgPath: '',
            site_Type: ''
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
        navItems: {
            type: Array,
            required: true
        }
    },
    created(){
        this.site_Type = JSON.parse(this.$props.siteType);
        this.orgPath = JSON.parse(this.$props.orgchartPath);
        console.log("admin-nav created, data: ", this.site_Type, this.orgPath);
    },
    methods: {
        toggleSubModal(item) {
            if (item.subLinks) {
                item.subLinkOpen = !item.subLinkOpen;
            }
        },
        adjustIndex(event){
            //so that the newest submenu opened will be on top of any other open menues
            const elLi = Array.from(document.querySelectorAll('.sublinks > li'));
            elLi.forEach(ele => {
                ele.style.zIndex = 100;
            });
            event.currentTarget.style.zIndex = 200;
        },
        modalOn(item) {
            if (item.subLinks) {
                item.subLinkOpen = true;
            }
        },
        modalOff(item) {
            if (item.subLinks) {
                item.subLinkOpen = false;
            }
        }
    },
    template:
        `<li :key="item.title" 
            v-for="item in navItems"
            @click="toggleSubModal(item)" 
            @mouseenter="modalOn(item)"
            @mouseleave="modalOff(item)">
            <a :href="item.link" 
                :class="[ (item.subLinkOpen) ? 'active' : '' ]">{{ item.title }}&nbsp;
                <i v-if="item.subLinks" :style="{visibility: item.subLinks && !item.subLinkOpen ? 'visible' : 'hidden'}" class="fas fa-angle-down"></i>
            </a>
            
            <template v-if="item.subLinks && item.subLinkOpen">
                <ul class="sublinks active"> 
                    <li :key="subLink.title" 
                        v-for="subLink in item.subLinks" 
                        @click="adjustIndex($event)"
                        @mouseleave="modalOff(subLink)"
                        @mouseenter="modalOn(subLink)">
                        <a :href="subLink.link" 
                            :class="[ (subLink.subLinkOpen) ? 'active' : '' ]">
                            {{ subLink.title }} 
                            <i :style="{visibility: subLink.subLinks && !subLink.subLinkOpen ? 'visible' : 'hidden'}" class="fas fa-angle-right"></i>
                        </a>
                        
                        <template v-if="subLink.subLinks && subLink.subLinkOpen">
                            <ul class="inner-sublinks active"> 
                                <li :key="sub.title" v-for="sub in subLink.subLinks"
                                :style="{backgroundColor: subLink.backgroundColor}">
                                <a :href="sub.link">{{ sub.title }}</a>
                                </li>
                            </ul>  
                        </template>
                    </li>
                </ul> 
            </template>
        </li>`
});

//TODO:
app.component('menu-toggle-button', {
    emits:['toggleNav'],
    template:
        `<li @click="$emit('toggle-nav')" id="toggleMenu" role="button">
            <span class="leaf-menu"><button>MENU</button></span><i class="fas fa-times"></i><span id="toggleMenu-text">Toggle Navigation</span>
        </li>`
});

app.component('leaf-user-info', {
    data(){
        return {
            userItems: {
                user: '',
                primaryAdmin: ''
            },
            subLinkOpen: false
        }
    },
    props: ['user-name'],
    methods: {
        toggleSubModal() {
            this.subLinkOpen = !this.subLinkOpen;
        }
    },
    created(){
        this.userItems.user = JSON.parse(this.$props.userName);
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
        `<li>
            <a href="#" @click="toggleSubModal">
                <i id="nav-user-icon" class='fas fa-user-circle' alt='User Account Menu'></i>
                <span>&nbsp; {{ this.userItems.user }}&nbsp;</span> 
                <i :style="{visibility: !subLinkOpen ? 'visible' : 'hidden'}" class="fas fa-angle-down"></i> 
            </a>
            <template v-if="subLinkOpen">
                <ul class="sublinks active">
                    <li><a href="#">Your account profile<br/><span class="leaf-user-menu-name"></span></a></li>
                    <li><a href="#">Primary Admin:<br/><span id="primary-admin" class="leaf-user-menu-name">{{userItems.primaryAdmin}}</span></a></li>
                    <li><a href="../?a=logout">Sign Out</a></li>
                </ul>
            </template>
        </li>`
});

app.mount('#vue-leaf-header');