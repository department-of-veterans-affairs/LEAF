const app = Vue.createApp({
    data(){
        return {
            adminLinks: [
                { title: 'Home', link: '../' },
                { title: 'Report Builder', link: '../?a=reports' },
                { title: 'Site Links', link: '#',
                    subLinks: [
                        { title: 'Nexus: Org Charts', link: '../../LEAF_Nexus' }
                    ],
                    subLinkOpen: false},
                { title: 'Admin', link: '#',
                    subLinks: [
                        { title: 'Admin Home', link: './' },
                        { title: 'User Access', link: '#',
                            subLinks: [
                                { title: 'User Access Groups', link: '?a=mod_groups' },
                                { title: 'Service Chiefs', link: '?a=mod_svcChief' }
                            ],
                            subLinkOpen: false,
                            backgroundColor: '#FAF3D1'},
                        { title: 'Portal Admin', link: '#',
                            subLinks: [
                                { title: 'Workflow Editor', link: '?a=workflow' },
                                { title: 'Form Editor', link: '?a=form' },
                                { title: 'LEAF Library', link: '?a=formLibrary' },
                                { title: 'Site Settings', link: '?a=mod_system' },
                                { title: 'Report Builder', link: '../?a=reports' },
                                { title: 'Timeline Explorer', link: '../report.php?a=LEAF_Timeline_Explorer' }
                            ],
                            subLinkOpen: false,
                            backgroundColor: '#DAE9EE'},
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
                            backgroundColor: '#DBEBDE'},
                        { title: 'Toolbox', link: '#',
                            subLinks: [
                                { title: 'Import Spreadsheet', link: '../report.php?a=LEAF_import_data' },
                                { title: 'Mass Action', link: '../report.php?a=LEAF_mass_action' },
                                { title: 'Initiator New Account', link: '../report.php?a=LEAF_request_initiator_new_account' },
                                { title: 'Sitemap Editor', link: '../report.php?a=LEAF_sitemaps_template' },
                            ],
                            subLinkOpen: false,
                            backgroundColor: '#F2E4D4'},

                    ], subLinkOpen: false },

            ],
        }
    },
});


//TODO: move separate comps to own file.
//warning banner
app.component('leaf-warning', {
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
        `<p id="leaf-warning" :style="{backgroundColor: bgColor, color: textColor}"><slot></slot></p>`
});

//nav (nav, ul, li, and sublists)
app.component('leaf-nav', {
    props: {
        navItems: {
            type: Array,
            required: true
        }
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
    },//@click="toggleSubModal(item)"
    template:
        `<nav id="leaf-vue-nav">
        <ul class="primary"> 
            <li :key="item.title" v-for="item in navItems">
                <a :href="item.link" 
                    @click="toggleSubModal(item)"
                    :class="[ (item.subLinkOpen) ? 'active' : '' ]">{{ item.title }}
                    <i v-if="item.subLinks" :style="{visibility: item.subLinks && !item.subLinkOpen ? 'visible' : 'hidden'}" class="fas fa-angle-down"></i>
                </a>
                
                <template v-if="item.subLinks && item.subLinkOpen">
                    <ul class="sublinks active"> 
                        <li :key="subLink.title" v-for="subLink in item.subLinks" @click="adjustIndex($event)">
                            <a :href="subLink.link" 
                                @click="toggleSubModal(subLink)"
                                :class="[ (subLink.subLinkOpen) ? 'active' : '' ]">
                                <i :style="{visibility: subLink.subLinks && !subLink.subLinkOpen ? 'visible' : 'hidden'}" class="fas fa-angle-left"></i>
                                &nbsp;{{ subLink.title }}
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
            </li> 
        </ul><slot></slot> 
    </nav>`, //^slot for user-info
});

app.component('user-info', {
    data(){
        return {
            userItems: [
                { title: this.name, link: '#' },
                { title: this.position, link: '#' },
                { title: 'Log Out', link: '#' },
            ],
            subLinkOpen: false
        }
    },
    props: {
        name: {
            type: String,
            required: true
        },
        position: {
            type: String,
            required: true

        },
        isLoggedIn: {
            type: Boolean,
            required: true
        },
    },
    methods: {
        toggleSubModal() {
            this.subLinkOpen = !this.subLinkOpen;
        }
    },
    template:
        `<ul id="user-info" class="primary">
        <li>
            <a href="#" @click="toggleSubModal()"
                :class="[ (subLinkOpen) ? 'active' : '' ]">
                user info
                <i :style="{visibility: userItems && !subLinkOpen ? 'visible' : 'hidden'}" class="fas fa-angle-down"></i>
            </a>
            <template v-if="subLinkOpen">
                <ul class="sublinks">
                    <li :key="item" v-for="item in userItems">
                        <a :href="item.link">{{ item.title }}</a>
                    </li>
                </ul>
            </template>
        </li>
    </ul>`
});

app.mount('#vue-leaf-header');