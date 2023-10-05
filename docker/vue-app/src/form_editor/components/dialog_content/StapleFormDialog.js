export default {
    name: 'staple-form-dialog',
    data() {
        return {
            catIDtoStaple: '',
        }
    },
    inject: [
        'APIroot',
        'CSRFToken',
        'setDialogSaveFunction',
        'truncateText',
        'decodeAndStripHTML',
        'categories',
        'focusedFormRecord',
        'closeFormDialog',
        'updateStapledFormsInfo'
    ],
    created() {
        this.setDialogSaveFunction(this.onSave);
    },
    mounted() {
        if (this.isSubform) {
            this.closeFormDialog();
        }
        if(this.mergeableForms.length > 0) {
            const focusEl = document.getElementById('select-form-to-staple');
            if(focusEl !== null) focusEl.focus();
        }
    },
    computed: {
        isSubform () {
            return this.focusedFormRecord?.parentID !== '';
        },
        formID () {
            return this.focusedFormRecord?.categoryID || '';
        },
        currentStapleIDs() {
            return this.categories[this.formID]?.stapledFormIDs || [];
        },
        mergeableForms() {
            let mergeable = [];
            for (let c in this.categories) {
                const WF_ID = parseInt(this.categories[c].workflowID);
                const catID = this.categories[c].categoryID;
                const parID = this.categories[c].parentID;
                const isNotAlreadyMerged = this.currentStapleIDs.every(id => id !== catID)
                if (WF_ID === 0 && parID === '' && catID !== this.formID && isNotAlreadyMerged) {
                    mergeable.push({...this.categories[c]});
                }
            }
            return mergeable;
        }
    },
    methods: {
        unmergeForm(stapledCatID = '') {
            $.ajax({
                type: 'DELETE',
                url: `${this.APIroot}formEditor/_${this.formID}/stapled/_${stapledCatID}?` + $.param({CSRFToken:this.CSRFToken}),
                success: res => {
                    this.updateStapledFormsInfo(this.formID, stapledCatID, true);
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
                        if(+res !== 1) {
                            alert(res);
                        } else {
                            this.updateStapledFormsInfo(this.formID, this.catIDtoStaple);
                            this.catIDtoStaple = '';
                        }
                    },
                    error: err => console.log(err),
                    cache: false
                });
            }
        }
    },
    template:`<div>
        <p>Stapled forms will show up on the same page as the primary form.</p>
        <p>The order of the forms will be determined by the forms' assigned sort values.</p>
        <div id="mergedForms" style="margin-top: 1rem;">
            <ul style="list-style-type:none; padding: 0; min-height: 50px;">
                <li v-for="id in currentStapleIDs" :key="'staple_list_' + id">
                    {{truncateText(decodeAndStripHTML(categories[id]?.categoryName || 'Untitled')) }}
                    <button type="button"
                        style="margin-left: 0.25em; background-color: transparent; color:#a00; padding: 0.1em 0.2em; border: 0; border-radius:3px;" 
                        @click="unmergeForm(id)" :title="'remove ' + categories[id]?.categoryName || 'Untitled'">
                        <b>[ Remove ]</b>
                    </button>
                </li>
            </ul>
        </div><hr/>
        <div style="min-height: 50px; margin: 1em 0;">
            <template v-if="mergeableForms.length > 0">
                <label for="select-form-to-staple" style="padding-right: 0.3em;">Select a form to merge</label>
                <select v-model="catIDtoStaple" title="select a form to merge" id="select-form-to-staple" style="width:100%;">
                    <option value="">Select a Form</option>
                    <option v-for="f in mergeableForms" 
                        :value="f.categoryID" 
                        :key="'merge_'+f.categoryID">{{truncateText(decodeAndStripHTML(f.categoryName)) || 'Untitled'}}</option>
                </select>
            </template>
            <div v-else>There are no available forms to merge</div>
        </div>
    </div>`
}