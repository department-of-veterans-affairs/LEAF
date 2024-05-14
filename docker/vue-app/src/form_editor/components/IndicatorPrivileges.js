export default {
    name: 'indicator-privileges',
    data() {
        return {
            allGroups: [],
            groupsWithPrivileges: [],
            group: 0,
            statusMessageError: ''
        }
    },
    props: {
        indicatorID: {
            type: Number,
            required: true
        }
    },
    inject: [
        'APIroot',
        'CSRFToken',
        'showLastUpdate',
        'focusedFormRecord',
        'getFormByCategoryID'
    ],
    mounted() {
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
                error: err => console.log(err)
            }),
            $.ajax({
                type: 'GET',
                url: `${this.APIroot}formEditor/indicator/${this.indicatorID}/privileges`,
                success: (res) => {
                    this.groupsWithPrivileges = res;
                },
                error: err => {
                    console.log(err);
                    this.statusMessageError = 'There was an error retrieving the Indicator Privileges. Please try again.';
                }
            })
        ];
        Promise.all(loadCalls).then((res)=> {
            //console.log(res);
        }).catch(err => console.log('an error has occurred', err));
    },
    computed: {
        availableGroups() {
            const groupIDs = [];
            this.groupsWithPrivileges.map(g => groupIDs.push(parseInt(g.id)));
            return this.allGroups.filter(g => !groupIDs.includes(parseInt(g.groupID)));
        },
        formID() {
            return this.focusedFormRecord?.categoryID || '';
        }
    },
    methods:{
        /**
         * 
         * @param {number} groupID 
         */
        removeIndicatorPrivilege(groupID = 0){
            if (groupID !== 0) {
                $.ajax({
                    method: 'POST',
                    url: `${this.APIroot}formEditor/indicator/${this.indicatorID}/privileges/remove`,
                    data: {
                        groupID: groupID,
                        CSRFToken: this.CSRFToken
                    },
                    success: res => {
                        //console.log(res); //NOTE: followup on this return value ('false').  should server return count(res)?
                        this.groupsWithPrivileges = this.groupsWithPrivileges.filter(g => g.id !== groupID);
                        this.getFormByCategoryID(this.formID);
                        this.showLastUpdate('form_properties_last_update');
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
                    url: `${this.APIroot}formEditor/indicator/${this.indicatorID}/privileges`,
                    data: {
                        groupIDs: [this.group.groupID],
                        CSRFToken: this.CSRFToken
                    },
                    success: () => {
                        this.groupsWithPrivileges.push({id: this.group.groupID, name: this.group.name});
                        this.group = 0;
                        this.getFormByCategoryID(this.formID);
                        this.showLastUpdate('form_properties_last_update');
                    }, 
                    error: err => console.log('an error occurred while setting group access restrictions', err)
                })
            }
        }
    },
    template:`<fieldset id="indicatorPrivileges"  style="font-size: 90%; border-radius: 3px;">
                <legend style="font-family: PublicSans-Bold">Special access restrictions</legend>
                <div>
                    This prevents anyone from reading stored data unless they're part of the following groups.<br/> 
                    If a group is assigned below, everyone else will see "[protected data]".
                </div>
                <template v-if="statusMessageError === ''">
                    <div v-if="groupsWithPrivileges.length === 0" style="margin:0.5rem 0">No special access restrictions are enabled. Normal access rules apply.</div>
                    <div v-else style="margin:0.5rem 0">
                        <div style="color: #a00;">Special access restrictions are enabled.</div>
                        <ul>
                            <li v-for="g in groupsWithPrivileges" :key="g.name + g.id">
                                {{g.name}}
                                <button type="button" @click="removeIndicatorPrivilege(parseInt(g.id))"
                                    style="margin-left: 3px; background-color: transparent; color:#a00; padding: 0.1em 0.2em; border: 0; border-radius:3px;" 
                                    :title="'remove ' + g.name">
                                    <b>[ Remove ]</b>
                                </button>
                            </li>
                        </ul>
                    </div>
                </template>
                <div v-else>{{ statusMessageError }}</div>
                <label for="selectIndicatorPrivileges" style="">What group should have access to this field?</label>
                <div style="display: flex; align-items: center;">
                    <select id="selectIndicatorPrivileges" v-model="group" style="width:260px;">
                        <option :value="0">Select a Group</option>
                        <option v-for="g in availableGroups" :value="g" :key="'avail_' + g.groupID">{{g.name}} (id{{g.groupID}})</option>
                    </select><button type="button" class="btn-general" @click="addIndicatorPrivilege" style="margin-left: 3px; align-self:stretch;">Add group</button>
                </div>
            </fieldset>`
}