export default {
    data() {
        return {
            catIDtoStaple: '',
            formID: this.currSubformID || this.currCategoryID   
            //NOTE: subforms can have staples.  subformID will be null if the selected form is not a subform.  currCategoryID will always be a main form.

        }
    },
    inject: [
        'APIroot',
        'CSRFToken',
        'truncateText',
        'categories',
        'currCategoryID',
        'currSubformID',
        'ajaxSelectedCategoryStapled',
        'getStapledFormsByCurrentCategory',
        'setCurrCategoryStaples',
        'closeFormDialog',
        'updateFormsStapledCatIDs'
    ],
    mounted() {
        document.getElementById('select-form-to-staple').focus();
    },
    computed: {
        mergeableForms() {
            let mergeable = [];
            for (let c in this.categories) {
                const WF_ID = parseInt(this.categories[c].workflowID);
                const catID = this.categories[c].categoryID;
                const parID = this.categories[c].parentID;
                const isNotAlreadyMerged = this.ajaxSelectedCategoryStapled.every(form => form.stapledCategoryID !== catID)
                if (WF_ID===0 && catID !== this.formID && parID === '' && isNotAlreadyMerged) {
                    mergeable.push({...this.categories[c]});
                }
            }
            return mergeable;
        }
    },
    methods: {
        unmergeForm(stapledCatID) {
            $.ajax({
                type: 'DELETE',
                url: `${this.APIroot}formEditor/_${this.formID}/stapled/_${stapledCatID}?` + $.param({CSRFToken:this.CSRFToken}),
                success: res => {
                    this.getStapledFormsByCurrentCategory(this.formID).then(res => this.setCurrCategoryStaples(res));
                    this.updateFormsStapledCatIDs(stapledCatID, true);
                },
                error: err => console.log(err)
            });
        },
        onSave() {
            if(this.catIDtoStaple !== '') {
                $.ajax({
                    type: 'POST',
                    url: `${this.APIroot}formEditor/_${this.formID}/stapled`,
                    data: {
                        CSRFToken: this.CSRFToken,
                        stapledCategoryID: this.catIDtoStaple
                    },
                    success: res => {
                        this.getStapledFormsByCurrentCategory(this.formID).then(res => {
                            this.setCurrCategoryStaples(res);
                            this.updateFormsStapledCatIDs(this.catIDtoStaple);
                            this.closeFormDialog();
                        });
                        if(res !== 1) {
                            alert(res);
                        }
                    },
                    error: err => console.log(err),
                    cache: false
                });
            } else {
                this.closeFormDialog();
            }
        }
    },
    template:`<div>
        <p>Stapled forms will show up on the same page as the primary form</p>
        <div id="mergedForms">
            <ul style="list-style-type:none; padding: 0; min-height: 50px;">
                <li v-for="s in ajaxSelectedCategoryStapled">
                    {{truncateText(s.categoryName) || 'Untitled'}}
                    <button 
                        style="margin-left: 0.25em; background-color: transparent; color:#a00; padding: 0.1em 0.2em; border: 0; border-radius:3px;" 
                        @click="unmergeForm(s.categoryID)" :title="'remove ' + s.categoryName || 'Untitled'">
                        <b>[ Remove ]</b>
                    </button>
                </li>
            </ul>
        </div><hr/>
        <div style="min-height: 50px; margin: 1em 0;">
            <div style="margin-bottom: 0.2em;">Select a form to merge</div>
            <template v-if="mergeableForms.length > 0">
            <select v-model="catIDtoStaple" title="select a form to merge" id="select-form-to-staple">
                <option value="">Select a Form</option>
                <option v-for="f in mergeableForms" :value="f.categoryID" :key="'staple_'+f.categoryID">{{truncateText(f.categoryName) || 'Untitled'}}</option>
            </select>
            </template>
            <div v-else>There are no available forms to merge</div>
        </div>
    </div>`
}