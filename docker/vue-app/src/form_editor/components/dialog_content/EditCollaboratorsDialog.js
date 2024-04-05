export default {
    name: 'edit-collaborators-dialog',
    data() {
        return {
            formID: this.focusedFormRecord.categoryID,
            group: '',
            allGroups: [],
            collaborators: []
        }
    },
    inject: [
        'APIroot',
        'CSRFToken',
        'setDialogSaveFunction',
        'categories',
        'focusedFormRecord',
        'checkFormCollaborators',
        'closeFormDialog'
    ],
    created() {
        this.setDialogSaveFunction(this.onSave);
    },
    mounted() {
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
                    this.collaborators = res;
                },
                error: err => console.log(err),
                cache: false
            })
        ];
        Promise.all(loadCalls).then(()=> {
            const elSelect = document.getElementById('selectFormCollaborators');
            if(elSelect !== null) elSelect.focus();
        }).catch(err => console.log('an error has occurred', err));
    },
    beforeUnmount() {
        this.checkFormCollaborators();
    },
    computed: {
        availableGroups() {
            const collabGroupIDs = [];
            this.collaborators.map(c => collabGroupIDs.push(parseInt(c.groupID)));
            return this.allGroups.filter(g => !collabGroupIDs.includes(parseInt(g.groupID)));
        }
    },
    methods: {
        /**
        * Remove form permissions for the group and update the collaborators array on success
        * @param {number} groupID
        */
        removePermission(groupID = 0) {
            $.ajax({
                type: 'POST',
                url: `${this.APIroot}formEditor/_${this.formID}/privileges`,
                data: {
                    CSRFToken: this.CSRFToken,
                    groupID: groupID,
                    read: 0,
                    write: 0
                },
                success: res => {
                    this.collaborators = this.collaborators.filter(c => parseInt(c.groupID) !== groupID);
                },
                error: err => console.log(err)
            });
        },
        /**
         * uses LEAF XSSHelpers
         * @returns form name with tags stripped
         */
        formNameStripped() {
            const formName = this.categories[this.formID].categoryName;
            return XSSHelpers.stripAllTags(formName) || 'Untitled';
        },
        /**
        * Purpose: Add Permissions to Form for currently selected groupID
        */
        onSave() {
            if(this.group !== '') {
                $.ajax({
                    type: 'POST',
                    url: `${this.APIroot}formEditor/_${this.formID}/privileges`,
                    data: {
                        CSRFToken: this.CSRFToken,
                        groupID: parseInt(this.group.groupID),
                        read: 1,
                        write: 1
                    },
                    success: (res) => { //returns null uwu
                        const group = this.collaborators.find(c => parseInt(c.groupID) === parseInt(this.group.groupID));
                        if (group === undefined) {
                            this.collaborators.push({groupID: this.group.groupID, name: this.group.name});
                            this.group = '';
                        }
                    },
                    error: err => console.log(err),
                    cache: false
                });
            }
        }
    },
    template:`<div>
        <h3>Editing Form: {{formNameStripped()}}</h3>
        <p>You can customize write access, enabling specific groups to fill out data fields at any time in the workflow.</p>
        <p>This is typically used to give groups access to fill out internal-use fields.</p>
        <div id="formPrivs" style="margin-top: 1rem;">
            <template v-if="collaborators.length > 0">
                <ul style="list-style-type:none; padding: 0; min-height: 30px;">
                    <li v-for="c in collaborators" :key="c.name + c.groupID">
                        {{c.name}}
                        <button type="button"
                            style="margin-left: 0.25em; background-color: transparent; color:#a00; padding: 0.1em 0.2em; border: 0; border-radius:3px;" 
                            @click="removePermission(parseInt(c.groupID))" :title="'remove ' + c.name">
                            <b>[ Remove ]</b>
                        </button>
                    </li>
                </ul>
            </template>
        </div><hr/>
        <div style="min-height: 50px; margin: 1em 0;">
            <template v-if="availableGroups.length > 0">
                <label for="selectFormCollaborators" style="display:block; margin-bottom:2px;">Select a group to add</label>
                <select v-model="group" id="selectFormCollaborators" style="width:100%;">
                    <option value="">Select a Group</option>
                    <option v-for="g in availableGroups" :value="g" :key="'collab_group_' + g.groupID">{{g.name}}</option>
                </select>
            </template>
            <div v-else>There are no available groups to add</div>
        </div>
    </div>`
}