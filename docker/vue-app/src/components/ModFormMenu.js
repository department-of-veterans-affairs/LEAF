export default {
    inject: [
        'APIroot',
        'truncateText',
        'stripAndDecodeHTML',
        'selectNewCategory',
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
        },
        currentStapleIDs() {
            return this.categories[this.mainFormID]?.stapledFormIDs || [];
        },
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
            const name = this.stripAndDecodeHTML(form?.categoryName) || 'Untitled';
            return this.truncateText(name, len).trim();
        },
    },
    template: `<nav id="form-editor-nav">
            <!-- FORM BROWSER AND RESTORE FIELDS MENU -->
            <ul v-if="mainFormID === ''" id="form-editor-menu">
                <li v-if="$route.name === 'restore'">
                    <router-link :to="{ name: 'category' }" class="router-link" @click="selectNewCategory()">
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
                <li v-if="$route.name === 'category'">
                    <router-link :to="{ name: 'restore' }" class="router-link" >
                        Restore Fields<span role="img" aria="">♻️</span>
                    </router-link>
                </li>
            </ul>
            <!-- FORM EDITING MENU -->
            <ul v-else id="form-editor-menu">
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
            </ul>

            <!-- FORM EDITING BREADCRUMBS -->
            <ul v-if="mainFormID !== ''" id="form-breadcrumb-menu">
                <li>
                    <router-link :to="{ name: 'category', query: { formID: ''}}" title="to Form Browser">
                        <h2>Form Editor</h2>
                    </router-link>
                    <span v-if="mainFormID !== ''" class="header-arrow" role="img" aria="">❯</span>
                </li>
                <li>
                    <button type="button" v-if="mainFormID !== ''" 
                        @click="selectNewCategory(mainFormID)" :title="'to parent form ' + mainFormID" :disabled="subformID === ''">
                        <h2>{{shortFormNameStripped(mainFormID, 50)}}</h2>
                    </button>
                    <span v-if="subformID !== ''" class="header-arrow" role="img" aria="">❯</span>
                </li>
                <li v-if="subformID !== ''">
                    <button type="button" :id="'header_' + subformID" 
                        :title="'viewing internal form ' + subformID" disabled>
                        <h2>{{shortFormNameStripped(subformID, 50)}}</h2>
                    </button>
                </li>
            </ul>
        </nav>`
};