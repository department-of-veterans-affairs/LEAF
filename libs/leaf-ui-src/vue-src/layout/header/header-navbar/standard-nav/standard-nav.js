export default {
    data() {
        return {
            navItems: [
                { title: 'Site Links', link: '#',
                    subLinks: [
                        { title: 'Nexus: Org Charts', link: '../' + this.$props.orgchartPath }
                    ],
                    subLinkOpen: false,
                    isClickedOn: false
                },
                { title: 'Admin Panel', link: './admin'}
            ]
        }
    },
    props: {
        orgchartPath: {
            type: String,
            required: true
        },
        innerWidth: {
            type: Number,
            required: true
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
            }
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
    template: `<li :key="item.title"
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
                        </li>
                      </ul>
                    </template>
                  </li>`
}