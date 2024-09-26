export default {
    name: 'staple-form-dialog',
    data() {
        return {
            requiredDataProperties: ['mainFormID'],
            mainFormID: this.dialogData?.mainFormID || '',
            catIDtoStaple: '',
            ariaStatus: '',
        }
    },
    inject: [
        'APIroot',
        'CSRFToken',
        'setDialogSaveFunction',
        'truncateText',
        'decodeAndStripHTML',
        'categories',
        'dialogData',
        'checkRequiredData',
        'closeFormDialog',
        'updateStapledFormsInfo'
    ],
    created() {
        this.setDialogSaveFunction(this.onSave);
        this.checkRequiredData(this.requiredDataProperties);
    },
    mounted() {
        if (this.isSubform) {
            this.closeFormDialog();
        }
        if(this.mergeableForms.length > 0) {
            const focusEl = document.getElementById('select-form-to-staple');
            if(focusEl !== null) focusEl.focus();
        } else {
            const btnAdd = document.getElementById('button_save');
            if(btnAdd !== null) {
                btnAdd.style.display = 'none';
            }
        }
    },
    computed: {
        isSubform () {
            return this.categories[this.mainFormID]?.parentID !== '';
        },
        currentStapleIDs() {
            return this.categories[this.mainFormID]?.stapledFormIDs || [];
        },
        mergeableForms() {
            let mergeable = [];
            for (let c in this.categories) {
                const WF_ID = parseInt(this.categories[c].workflowID);
                const catID = this.categories[c].categoryID;
                const parID = this.categories[c].parentID;
                const isNotAlreadyMerged = this.currentStapleIDs.every(id => id !== catID)
                if (WF_ID === 0 && parID === '' && catID !== this.mainFormID && isNotAlreadyMerged) {
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
                url: `${this.APIroot}formEditor/_${this.mainFormID}/stapled/_${stapledCatID}?` + $.param({CSRFToken:this.CSRFToken}),
                success: () => {
                    this.ariaStatus = `Removed stapled form ${this.categories[stapledCatID]?.categoryName || ''}`;
                    this.updateStapledFormsInfo(this.mainFormID, stapledCatID, true);
                },
                error: err => console.log(err)
            });
        },
        onSave() {
            if(this.catIDtoStaple !== '') {
                $.ajax({
                    type: 'POST',
                    url: `${this.APIroot}formEditor/_${this.mainFormID}/stapled`,
                    data: {
                        CSRFToken: this.CSRFToken,
                        stapledCategoryID: this.catIDtoStaple
                    },
                    success: res => {
                        if(+res !== 1) {
                            alert(res);
                        } else {
                            this.ariaStatus = `Added stapled form ${this.categories[this.catIDtoStaple]?.categoryName || ''}`;
                            this.updateStapledFormsInfo(this.mainFormID, this.catIDtoStaple);
                            this.catIDtoStaple = '';
                        }
                    },
                    error: err => console.log(err),
                    cache: false
                });
            }
        }
    },
    watch: {
        mergeableForms(newVal, oldVal) {
            const newLen = newVal.length;
            const oldLen = oldVal.length;
            if (newLen === 0 || oldLen === 0 && newLen > 0) {
                const btnAdd = document.getElementById('button_save');
                if(btnAdd !== null) {
                    btnAdd.style.display = newLen === 0 ? 'none' : 'flex';
                }
            }
        }
    },
    template:`<div>
        <div id="status_form_staple" role="status" aria-live="assertive" :aria-label="ariaStatus" style="opacity:0;position:absolute;"></div>
        <p>Stapled forms will show up on the same page as the primary form.</p>
        <p>The order of the forms will be determined by the forms' assigned sort values.</p>
        <div id="mergedForms" style="margin-top: 1rem;">
            <ul style="list-style-type:none; padding: 0; min-height: 50px;">
                <li v-for="id in currentStapleIDs" :key="'staple_list_' + id">
                    {{truncateText(decodeAndStripHTML(categories[id]?.categoryName || 'Untitled')) }}
                    <button type="button"
                        style="margin-left: 0.25em; background-color: transparent; color:#a00; padding: 0.1em 0.2em; border: 0; border-radius:3px;" 
                        @click="unmergeForm(id)"
                        :title="'remove ' + categories[id]?.categoryName || 'Untitled'"
                        :aria-label="'remove ' + categories[id]?.categoryName || 'Untitled'">
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