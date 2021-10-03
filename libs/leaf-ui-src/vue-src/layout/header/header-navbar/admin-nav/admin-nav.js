//admin view links
export default {
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
}