export default {
    name: 'form-editor-menu',
    inject: [
        'APIroot',
        'categories',
        'focusedFormRecord',
        'internalFormRecords',
        'focusedFormTree',
        'allStapledFormCatIDs',
        'siteSettings',
        'noForm',

        'openFormHistoryDialog',
        'openStapleFormsDialog',
        'openConfirmDeleteFormDialog',
    ],
    computed: {
        mainFormID() {
            return this.focusedFormRecord?.parentID === '' ?
                this.focusedFormRecord.categoryID : this.focusedFormRecord?.parentID || '';
        },
        subformID() {
            return this.focusedFormRecord?.parentID ?
                this.focusedFormRecord.categoryID : '';
        }
    },
    methods: {
        /**
         * resolve main form, internal form, and workflow info, then export
         */
        exportForm() {
            const catID = this.mainFormID;

            let packet = {};
            packet.form = {};
            packet.subforms = {};

            let exportCalls = [];

            exportCalls.push(
                $.ajax({
                    type: 'GET',
                    url: `${this.APIroot}form/_${catID}/export`,
                    success: res => {
                        packet.form = res;
                        packet.categoryID = catID;
                    },
                    error: err => console.log(err)
                })
            );
            this.internalFormRecords.forEach(f => {
                const subID = f.categoryID;
                exportCalls.push(
                    $.ajax({
                        type: 'GET',
                        url: `${this.APIroot}form/_${subID}/export`,
                        success: res => {
                            packet.subforms[subID] = {};
                            packet.subforms[subID].name = f.categoryName;
                            packet.subforms[subID].description = f.categoryDescription;
                            packet.subforms[subID].packet = res;
                        },
                        error: err => console.log('an error has occurred', err)
                    })
                );
            });

            exportCalls.push(
                $.ajax({
                    type: 'GET',
                    url: `${this.APIroot}form/_${catID}/workflow`,
                    success: res => {
                        packet.workflowID = res[0].workflowID;
                    },
                    error: err => console.log('an error has occurred', err)
                })
            );

            Promise.all(exportCalls)
            .then(()=> {
                let outPacket = {};
                outPacket.version = 1;
                outPacket.name = this.categories[catID].categoryName + ' (Copy)';
                outPacket.description = this.categories[catID].categoryDescription;
                outPacket.packet = packet;

                let outBlob = new Blob([JSON.stringify(outPacket).replace(/[^ -~]/g,'')], {type : 'text/plain'}); // Regex replace needed to workaround IE11 encoding issue
                saveAs(outBlob, 'LEAF_FormPacket_'+ catID +'.txt'); //FileSaver.js method
            }).catch(err => console.log('an error has occurred', err));
        }
    },
    template: `<div><nav id="top-menu-nav">
        <!-- FORM EDITOR VIEW MENU -->
        <ul>
            <li v-if="!noForm">
                <button type="button" @click="openFormHistoryDialog(this.focusedFormRecord.categoryID)" title="view form history">
                    View History<span role="img" aria="">🕗</span>
                </button>
            </li>
            <li v-if="!noForm">
                <button type="button" @click="exportForm" title="export form">
                    Export Form<span role="img" aria="">💾</span>
                </button>
            </li>
            <li v-if="!noForm">
                <button type="button" @click="openConfirmDeleteFormDialog" title="delete this form">
                    Delete this form<span role="img" aria="">❌</span>
                </button>
            </li>
            <li v-if="!allStapledFormCatIDs.includes(mainFormID) && !subformID && focusedFormTree.length > 0">
                <button type="button" @click="openStapleFormsDialog" title="Manage Stapled Forms">
                    Manage Stapled Forms <span role="img" aria="">📌</span>
                </button>
            </li>
            <li>
                <router-link :to="{ name: 'restore' }" class="router-link" >
                    Restore Fields<span role="img" aria="">♻️</span>
                </router-link>
            </li>
        </ul>
    </nav>
    <div v-if="siteSettings?.siteType==='national_subordinate'" id="subordinate_site_warning" style="padding: 0.5rem; margin: 0.5rem 0;" >
        <h3 style="margin: 0 0 0.5rem 0; color: #a00;">This is a Nationally Standardized Subordinate Site</h3>
        <span><b>Do not make modifications!</b> &nbsp;Synchronization problems will occur. &nbsp;Please contact your process POC if modifications need to be made.</span>
    </div></div>`
};