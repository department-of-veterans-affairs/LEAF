export default {
    data() {
        return {
            allGroups: [],
            groupsWithPrivileges: []
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
                url: `${this.APIroot}formEditor/_${this.formID}/privileges`,
                success: (res) => {
                    this.groupsWithPrivileges = res;
                },
                error: err => console.log(err),
                cache: false
            })
        ];
        Promise.all(loadCalls).then(()=> {
            const elSelect = document.getElementById('selectIndicatorPrivileges');
            console.log(this.allGroups, this.groupsWithPrivileges);
            if(elSelect!==null) elSelect.focus();
        });
    },
    computed: {
        availableGroups() {
            const groupIDs = [];
            this.groupsWithPrivileges.map(g => groupIDs.push(parseInt(g.groupID)));
            return this.allGroups.filter(g => !groupIDs.includes(parseInt(g.groupID)));
        }
    },
    methods:{
        removeIndicatorPrivilege(indicatorID = 0, groupID = 0){

        },
        addIndicatorPrivilege() {

        }
    },
    template:`<div>
                <label for="selectIndicatorPrivileges">What group should have access to this question?</label>
                <select id="selectIndicatorPrivileges" v-model.number="">
                    <option v-for="g in groupsWithPrivileges" value="">{{g.name}}</option>
                </select>
            </div>`
}