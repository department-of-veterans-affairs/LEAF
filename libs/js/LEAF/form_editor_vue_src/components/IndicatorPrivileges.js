export default {
    data() {
        return {
            allGroups: [],
            groupsWithPrivileges: [],
            group: 0
        }
    },
    inject: [
        'APIroot',
        'CSRFToken',
        'ajaxIndicatorByID',
        'currIndicatorID',
    ],
    mounted() {
        console.log('mounted indicator privs ind', this.indicatorID);
        /**
         * get groups for privileges selection and/or editing
         */
        const loadCalls = [
            $.ajax({
                type: 'GET',
                url: `${this.APIroot}system/groups`,
                success: res => {
                    this.allGroups = res
                },
                error: err => console.log(err),
                cache: false
            }),
            $.ajax({
                type: 'GET',
                url: `${this.APIroot}formEditor/indicator/${this.currIndicatorID}/privileges`,
                success: (res) => {
                    this.groupsWithPrivileges = res;
                },
                error: err => console.log(err),
                cache: false
            })
        ];
        Promise.all(loadCalls).then((res)=> {
            console.log(res);
        });
    },
    computed: {
        availableGroups() {
            const groupIDs = [];
            this.groupsWithPrivileges.map(g => groupIDs.push(parseInt(g.id)));
            return this.allGroups.filter(g => !groupIDs.includes(parseInt(g.groupID)));
        }
    },
    methods:{
        /**
         * 
         * @param {number} groupID 
         */
        removeIndicatorPrivilege(groupID = 0){
            console.log(groupID);
            if (groupID !== 0) {
                $.ajax({
                    method: 'POST',
                    url: `${this.APIroot}formEditor/indicator/${this.currIndicatorID}/privileges/remove`,
                    data: {
                        groupID: groupID,
                        CSRFToken: this.CSRFToken
                    },
                    success: res => {
                        console.log(res);
                        this.groupsWithPrivileges = this.groupsWithPrivileges.filter(g => g.id !== groupID);
                    }, 
                    error: err => console.log(err)
                });
            }
        },
        /**
         *  uses currently selected group to add privileges. Updates component data properties 'group' and 'groupsWithPrivileges' if successful
         */
        addIndicatorPrivilege() {
            if (this.group !== 0) {
                $.ajax({
                    method: 'POST',
                    url: `${this.APIroot}formEditor/indicator/${this.currIndicatorID}/privileges`,
                    data: {
                        groupIDs: [this.group.groupID],
                        CSRFToken: this.CSRFToken
                    },
                    success: () => {
                        this.groupsWithPrivileges.push({id: this.group.groupID, name: this.group.name});
                        this.group = 0;
                    }, 
                    error: err => console.log('an error occurred while setting group access restrictions', err)
                })
            }
        }
    },
    template:`<fieldset id="indicatorPrivileges"  style="font-size: 90%;">
                <legend>Special access restrictions</legend>
                <div>
                    These restrictions limit view access to the request initiator and members of groups you specify.<br/> 
                    They will also only allow the specified groups to apply search filters for this field.<br/>
                    All others will see "[protected data]".
                </div>
                <div v-if="groupsWithPrivileges.length===0" style="margin:0.5rem 0">No special access restrictions are enabled. Normal access rules apply.</div>
                <div v-else style="margin:0.5rem 0">
                    <div style="color: #cb0000;">Special access restrictions are enabled.</div>
                    <ul>
                        <li v-for="g in groupsWithPrivileges" :key="g.name + g.id">
                            {{g.name}}
                            <button @click="removeIndicatorPrivilege(parseInt(g.id))"
                                style="margin-left: 3px; background-color: transparent; color:#a00; padding: 0.1em 0.2em; border: 0; border-radius:3px;" 
                                :title="'remove ' + g.name">
                                <b>[ Remove ]</b>
                            </button>
                        </li>
                    </ul>
                </div>
                <label for="selectIndicatorPrivileges" style="">What group should have access to this field?</label>
                <div style="display: flex; align-items: center;">
                    <select id="selectIndicatorPrivileges" v-model="group" style="width:320px;">
                        <option :value="0">Select a Group</option>
                        <option v-for="g in availableGroups" :value="g">{{g.name}}</option>
                    </select><button class="btn-general" @click="addIndicatorPrivilege" style="margin-left: 3px; align-self:stretch;">Add group</button>
                </div>
            </fieldset>`
}