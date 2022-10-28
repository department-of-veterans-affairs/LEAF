export default {
    data() {
        return {
            allGroups: [],
            groupsWithPrivileges: [],
            group: ''
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
                url: `${this.APIroot}formEditor/_${this.currIndicatorID}/privileges`,
                success: (res) => {
                    this.groupsWithPrivileges = res;
                },
                error: err => console.log(err),
                cache: false
            })
        ];
        Promise.all(loadCalls).then(()=> {
            console.log(this.allGroups, this.groupsWithPrivileges);
        });
    },
    computed: {
        availableGroups() {
            const groupIDs = [];
            this.groupsWithPrivileges.map(g => groupIDs.push(parseInt(g.groupID)));
            return this.allGroups.filter(g => !groupIDs.includes(parseInt(g.groupID)));
        },
        selectedGroupID() {
            return parseInt(this.group.groupID || 0);
        }
    },
    methods:{
        removeIndicatorPrivilege(groupID = 0){
            console.log(groupID);
        },
        addIndicatorPrivilege() {
            console.log(this.currIndicatorID, groupID)
        }
    },
    template:`<div id="indicatorPrivileges">
                <hr/>
                <div style="margin-bottom:0.5rem;"><b>Special access restrictions for this field</b> ({{currIndicatorID}})</div>
                <div>
                    These restrictions will limit view access to the request initiator and members of any groups you specify.&nbsp; 
                    Additionally, these restrictions will only allow the groups specified below to apply search filters for this field.&nbsp; 
                    All others will see "[protected data]".
                </div>
                <div v-if="groupsWithPrivileges.length===0" style="margin:0.5rem 0">Special access restrictions are not enabled. Normal access rules apply.</div>
                <div v-else style="color: #cb0000; margin:0.5rem 0">Special access restrictions are enabled!
                    <ul style="min-height: 30px;">
                        <li v-for="g in groupsWithPrivileges" :key="g.name + g.groupID">
                            {{g.name}}
                            <button @click="removeIndicatorPrivilege(parseInt(g.groupID))"
                                style="margin-left: 0.25em; background-color: transparent; color:#a00; padding: 0.1em 0.2em; border: 0; border-radius:3px;" 
                                :title="'remove ' + g.name">
                                <b>[ Remove ]</b>
                            </button>
                        </li>
                    </ul>
                </div>
                
                <label for="selectIndicatorPrivileges" style="">What group should have access to this question?</label>
                <select id="selectIndicatorPrivileges" v-model="group" style="width:350px;">
                    <option value="">Select a Group</option>
                    <option v-for="g in availableGroups" :value="g">{{g.name}}</option>
                </select>
            </div>`
}