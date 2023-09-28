export default {
    name: 'mod-form-menu',
    inject: [
        'APIroot',
        'truncateText',
        'decodeAndStripHTML',
        'categories',
        'focusedFormRecord',
        'internalFormRecords',
        'focusedFormTree',
        'allStapledFormCatIDs',
        'openNewFormDialog',
        'openImportFormDialog',
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
        },
        /**
         * //NOTE: uses XSSHelpers.js
         * @param {string} categoryID 
         * @param {number} len 
         * @returns 
         */
        shortFormNameStripped(catID = '', len = 21) {
            const form = this.categories[catID] || '';
            const name = this.decodeAndStripHTML(form?.categoryName || 'Untitled');
            return this.truncateText(name, len).trim();
        },
    },
    template: `<nav id="top-menu-nav">
            <!-- FORM BROWSER AND RESTORE FIELDS MENU -->
            <ul v-if="$route.name === 'browser' || $route.name === 'restore'" id="page-menu">
                <li v-if="$route.name === 'restore'">
                    <router-link :to="{ name: 'browser' }" class="router-link">
                        Form Browser
                    </router-link>                
                </li>
                <li>
                    <button type="button" id="createFormButton" @click="openNewFormDialog($event)">
                        Create Form<span role="img" aria="">📄</span>
                    </button>
                </li>
                <li>
                    <a href="./?a=formLibrary" class="router-link">LEAF Library<span role="img" aria="">📘</span></a>
                </li>
                <li>
                    <button type="button" @click="openImportFormDialog">
                        Import Form<span role="img" aria="">📦</span>
                    </button>
                </li>
                <li v-if="$route.name === 'browser'">
                    <router-link :to="{ name: 'restore' }" class="router-link" >
                        Restore Fields<span role="img" aria="">♻️</span>
                    </router-link>
                </li>
            </ul>
            <!-- FORM EDITOR VIEW MENU -->
            <ul v-if="$route.name === 'category'" id="page-menu">
                <li v-if="!allStapledFormCatIDs.includes(mainFormID) && !subformID && focusedFormTree.length > 0">
                    <button type="button" @click="openStapleFormsDialog" title="Manage Stapled Forms">
                        Manage Stapled Forms <span role="img" aria="">📌</span>
                    </button>
                </li>
                <li>
                    <button type="button" @click="openFormHistoryDialog" title="view form history">
                        View History<span role="img" aria="">🕗</span>
                    </button>
                </li>
                <li>
                    <button type="button" @click="exportForm" title="export form">
                        Export Form<span role="img" aria="">💾</span>
                    </button>
                </li>
                <li>
                    <button type="button" @click="openConfirmDeleteFormDialog" title="delete this form">
                        Delete this form<span role="img" aria="">❌</span>
                    </button>
                </li>
                <li v-if="$route.name !== 'restore'">
                    <router-link :to="{ name: 'restore' }" class="router-link" >
                        Restore Fields<span role="img" aria="">♻️</span>
                    </router-link>
                </li>
            </ul>
        </nav>`
};