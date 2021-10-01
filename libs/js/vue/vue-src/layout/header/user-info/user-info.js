//user info list in nav
module.exports = {
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
            type: Number
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
}