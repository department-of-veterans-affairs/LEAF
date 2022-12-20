export default {
    data() {
        return {
            catIDtoStaple: '',
            formID: this.currCategoryID  //staples are added to the main form.

        }
    },
    inject: [
        'APIroot',
        'CSRFToken',
        'truncateText',
        'stripAndDecodeHTML',
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
        if(this.mergeableForms.length > 0) {
            const focusEl = document.getElementById('select-form-to-staple');
            if(focusEl !== null) focusEl.focus();
        }
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
        unmergeForm(stapledCatID = '') {
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
                        if(res !== 1) {
                            alert(res);
                        } else {
                            this.getStapledFormsByCurrentCategory(this.formID).then(res => {
                                this.setCurrCategoryStaples(res);
                                this.updateFormsStapledCatIDs(this.catIDtoStaple);
                                this.catIDtoStaple = '';
                            });
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
                <li v-for="s in ajaxSelectedCategoryStapled" :key="'staple_list_' + s.categoryID">
                    {{truncateText(stripAndDecodeHTML(s.categoryName)) || 'Untitled'}}
                    <button 
                        style="margin-left: 0.25em; background-color: transparent; color:#a00; padding: 0.1em 0.2em; border: 0; border-radius:3px;" 
                        @click="unmergeForm(s.categoryID)" :title="'remove ' + s.categoryName || 'Untitled'">
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
                        :key="'merge_'+f.categoryID">{{truncateText(stripAndDecodeHTML(f.categoryName)) || 'Untitled'}}</option>
                </select>
            </template>
            <div v-else>There are no available forms to merge</div>
        </div>
    </div>`
}