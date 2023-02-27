export default {
    data() {
        return {
            staplesMenuOpen: false,
            staplesMenuPinned: false,
            buttonHeight: 32
        }
    },
    inject: [
        'APIroot',
        'truncateText',
        'stripAndDecodeHTML',
        'selectNewCategory',
        'categories',
        'currCategoryID',
        'currSubformID',
        'internalFormRecords',
        'selectedFormTree',
        'stapledFormsCatIDs',
        'openNewFormDialog',
        'openImportFormDialog',
        'openFormHistoryDialog',
        'openStapleFormsDialog',
        'openConfirmDeleteFormDialog',
    ],
    computed: {
        currentStapleIDs() {
            return this.categories[this.currCategoryID]?.stapledFormIDs || [];
        },
    },
    methods: {
        /**
         * resolve main form, internal form, and workflow info, then export
         */
        exportForm() {
            const catID = this.currCategoryID;

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
            <ul v-if="currCategoryID === null" id="form-editor-menu">
                <li v-if="$route.name === 'restore'">
                    <router-link :to="{ name: 'category' }" class="router-link" @click="selectNewCategory(null)">
                        Form Browser
                    </router-link>                
                </li>
                <li>
                    <button type="button" id="createFormButton" @click="openNewFormDialog">
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
                <template v-if="selectedFormTree.length !== 0">
                    <li>
                        <button type="button" @click="openNewFormDialog" title="New Internal-Use Form">
                            Add New Internal-Use
                            <span role="img" aria="">➕</span>
                        </button>
                    </li>
                    <li v-if="!stapledFormsCatIDs.includes(currCategoryID)">
                        <button type="button" @click="openStapleFormsDialog" title="Manage Stapled Forms">
                            Manage Stapled Forms <span role="img" aria="">📌</span>
                        </button>
                    </li>
                    <li v-else>
                        <button type="button">This form is merged</button>
                    </li>
                </template>
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
            <ul v-if="currCategoryID !== null" id="form-breadcrumb-menu">
                <li>
                    <router-link :to="{ name: 'category', query: { formID: ''}}">
                        <h2>Form Editor</h2>
                    </router-link>
                    <span v-if="currCategoryID !== null" class="header-arrow" role="img" aria="">❯</span>
                </li>
                <li>
                    <router-link v-if="$route.query.formID !== currCategoryID" 
                        :to="{ name: 'category', query: { formID: currCategoryID }}"
                        class="router-link" title="to primary form">
                        <h2>{{shortFormNameStripped(currCategoryID, 50)}}</h2>
                    </router-link>
                    <button v-else type="button" :title="'viewing form ' + currCategoryID" disabled>
                        <h2>{{shortFormNameStripped(currCategoryID, 50)}}</h2>
                    </button>
                    <span v-if="currSubformID !== null" class="header-arrow" role="img" aria="">❯</span>
                </li>
                <li v-if="currSubformID !== null">
                    <button type="button" :id="'header_' + currSubformID" 
                        :title="'viewing internal form ' + currSubformID" disabled>
                        <h2>{{shortFormNameStripped(currSubformID, 50)}}</h2>
                    </button>
                </li>
            </ul>
        </nav>`
};