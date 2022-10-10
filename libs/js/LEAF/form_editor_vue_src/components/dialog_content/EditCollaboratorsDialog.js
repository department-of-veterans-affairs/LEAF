export default {
    data() {
        return {
            //subformID will be null if the selected form is not a subform.  currCategoryID will always be a main form.
            formID: this.currSubformID || this.currCategoryID,
            group: '',
            groups: [],
            collaborators: [] 
        }
    },
    inject: [
        'APIroot',
        'CSRFToken',
        'categories',
        'currCategoryID',
        'currSubformID',
        'closeFormDialog',
        'openEditCollaboratorsDialog'
    ],
    beforeMount() {
        $.ajax({
            type: 'GET',
            url: `${this.APIroot}system/groups`,
            success: res => {
                this.groups = res
                const elSelect = document.getElementById('selectFormCollaborators');
                if(elSelect!==null) elSelect.focus();
            },
            error: err => console.log(err),
            cache: false
        });
        $.ajax({
            type: 'GET',
            url: `${this.APIroot}formEditor/_${this.formID}/privileges`,
            success: (res) => {
                console.log('collabs', res)
                this.collaborators = res
            },
            error: err => console.log(err),
            cache: false
        });
    },
    methods: {
        /**
        * Purpose: Remove Permissions from Form
        * @param groupID number
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
                    console.log(res);
                    this.collaborators = this.collaborators.filter(c => parseInt(c.groupID) !== groupID);
                },
                error: err => console.log(err)
            });
        },
        formNameStripped() { //NOTE: XSSHelpers global
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
                        const group = this.collaborators.find(c => parseInt(c.groupID)===parseInt(this.group.groupID));
                        if (group === undefined) {
                            this.collaborators.push({groupID: this.group.groupID, name: this.group.name})
                        }
                        //this.closeFormDialog();
                    },
                    error: err => console.log(err),
                    cache: false
                });
            }
        }
    },
    template:`<div>
        <h3>{{formNameStripped()}}</h3>
        <p>Collaborators have access to fill out data fields at any time in the workflow.</p>
        <p>This is typically used to give groups access to fill out internal-use fields.</p>
        <div id="formPrivs">
            <template v-if="collaborators.length > 0">
                <ul style="list-style-type:none; padding: 0; min-height: 30px;">
                    <li v-for="c in collaborators" :key="c.name + c.groupID">
                        {{c.name}}
                        <button 
                            style="margin-left: 0.25em; background-color: transparent; color:#a00; padding: 0.1em 0.2em; border: 0; border-radius:3px;" 
                            @click="removePermission(parseInt(c.groupID))" :title="'remove ' + c.name">
                            <b>[ Remove ]</b>
                        </button>
                    </li>
                </ul>
            </template>
        </div><hr/>
        <div style="min-height: 50px; margin: 1em 0;">
            <template v-if="groups.length > 0">
                <label for="selectFormCollaborators" style="display:block; margin-bottom:2px;">Select a group to add</label>
                <select v-model="group" id="selectFormCollaborators">
                    <option value="">Select a Group</option>
                    <option v-for="g in groups" :value="g" :key="'group_' + g.groupID">{{g.name}}</option>
                </select>
            </template>
            <div v-else>There are no available groups to add</div>
        </div>
    </div>`
}