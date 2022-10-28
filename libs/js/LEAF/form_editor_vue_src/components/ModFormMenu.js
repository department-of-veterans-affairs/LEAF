export default {
    data() {
        return {
            menuOpen: false,
            menuPinned: false
        }
    },
    inject: [
        'APIroot',
        'truncateText',
        'selectNewCategory',
        'categories',
        'currCategoryID',
        'currSubformID',
        'ajaxSelectedCategoryStapled',
        'formsStapledCatIDs',
        'restoringFields',
        'showRestoreFields',
        'openNewFormDialog',
        'openImportFormDialog',
        'openFormHistoryDialog',
        'openStapleFormsDialog',
        'openConfirmDeleteFormDialog',
    ],
    computed: {
        /**
         * 
         * @returns {array} of internal forms associated with the main form
         */
        internalForms() {
            let internalForms = [];
            for(let c in this.categories){
                if (this.categories[c].parentID===this.currCategoryID) {
                    const internal = {...this.categories[c]};
                    internalForms.push(internal);
                }
            }
            return internalForms;
        }
    },
    methods: {
        toggleMenu() {
            this.menuPinned = !this.menuPinned;
            this.menuOpen = this.menuPinned;
        },
        showMenu() {
            this.menuOpen = true;
        },
        hideMenu() {
            if (!this.menuPinned) {
                this.menuOpen = false;
            }
        },
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
            this.internalForms.forEach(f => {
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
                        }
                    })
                );
            });

            exportCalls.push(
                $.ajax({
                    type: 'GET',
                    url: `${this.APIroot}form/_${catID}/workflow`,
                    success: res => {
                        packet.workflowID = res[0].workflowID;
                    }
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
                saveAs(outBlob, 'LEAF_FormPacket_'+ catID +'.txt');
            });
        },
        selectMainForm(catID = this.currCategoryID) {
            console.log('clicked a main form or main form staple', catID);
            this.selectNewCategory(catID, false);
        },
        selectSubform(subformID = ''){
            console.log('clicked a subform', 'sub', subformID, 'main', this.currCategoryID);
            this.selectNewCategory(subformID, true);
        },
        /**
         * //NOTE: uses XSSHelpers.js
         * @param {string} categoryID 
         * @param {number} len 
         * @returns 
         */
        shortFormNameStripped(catID = '', len = 21) {
            const form = this.categories[catID] || '';
            let name = form.categoryName || 'Untitled';
            name = XSSHelpers.stripAllTags(name);
            return this.truncateText(name, len).trim();
        },
    },
    template: `<header id="form-editor-header">
        <nav>
            <ul>
                <li>
                    <button type="button"
                        :title="(menuPinned ? 'close ' : 'pin ') + 'menu'"
                        id="form-editor-menu-toggle" 
                        @click="toggleMenu" @mouseenter="showMenu">
                        <span>{{menuPinned ? '↡' : menuOpen ? '⭱' : '⭳'}}</span>menu
                    </button>
                
                    <template v-if="menuOpen">
                        <ul v-if="currCategoryID===null" id="form-editor-menu"
                            @mouseenter="showMenu" @mouseleave="hideMenu">
                            <li>
                                <button id="createFormButton" @click="openNewFormDialog">
                                Create Form<span>📄</span>
                                </button>
                            </li>
                            <li>
                                <button @click="openImportFormDialog">
                                Import Form<span>📦</span>
                                </button>
                            </li>
                            <li>
                                <button @click="showRestoreFields">
                                Restore Fields<span>♻️</span>
                                </button>
                            </li>
                            <li>
                                <a href="./?a=formLibrary">
                                LEAF Library<span>📘</span>
                                </a>
                            </li>
                        </ul>
                        <ul v-else id="form-editor-menu"
                            @mouseenter="showMenu" 
                            @mouseleave="hideMenu">
                            <li>
                                <button @click="openNewFormDialog" title="add new internal use form">
                                Add Internal-Use<span>➕</span>
                                </button>
                                <ul v-if="internalForms.length > 0" id="internalForms">
                                    <li v-for="i in internalForms" :key="i.categoryID">
                                        <button :id="i.categoryID" @click="selectSubform(i.categoryID)" title="select internal form">
                                        {{shortFormNameStripped(i.categoryID, 28)}}
                                        </button>
                                    </li>
                                </ul>
                            </li>
                            <li v-if="!formsStapledCatIDs.includes(currCategoryID)">
                                <button @click="openStapleFormsDialog" title="staple another form">
                                    <div>
                                        Edit Main Form Staples<br/>
                                        <span class="staple-sort-info">form sort value: {{categories[currCategoryID].sort}}</span>
                                    </div><span>📌</span>
                                </button>
                                <ul v-if="ajaxSelectedCategoryStapled.length > 0" id="stapledForms">
                                    <li v-for="s in ajaxSelectedCategoryStapled" 
                                        :key="'staple_' + s.stapledCategoryID">
                                        <button @click="selectMainForm(s.categoryID)">
                                            <div>
                                                {{shortFormNameStripped(s.categoryID, 20) || 'Untitled'}}<br/>
                                                <span class="staple-sort-info">staple sort value: {{s.sort}}</span>
                                            </div><span>📑</span>
                                        </button>
                                    </li>
                                </ul>
                            </li>
                            <li>
                                <button @click="openFormHistoryDialog" title="view form history">
                                View History<span>🕗</span>
                                </button>
                            </li>
                            <li>
                                <button @click="exportForm" title="export form">
                                Export Form<span>💾</span>
                                </button>
                            </li>
                            <li>
                                <button @click="openConfirmDeleteFormDialog" title="delete this form">
                                Delete this form<span>❌</span>
                                </button>
                            </li>
                        </ul>
                    </template>
                </li>
                
                <li>
                    <button type="button" @click="selectNewCategory(null)" title="View All Forms">
                        <h2>Form Editor</h2>
                    </button>
                    <span v-if="currCategoryID!==null" class="header-arrow">❯</span>
                </li>
                <li v-if="currCategoryID!==null">
                    <button type="button" :id="'header_'+currCategoryID" @click="selectMainForm(currCategoryID)" title="main form">
                        <h2>{{shortFormNameStripped(currCategoryID, 22)}}</h2>
                    </button>
                    <span v-if="currSubformID!==null" class="header-arrow">❯</span>
                </li>
                <li v-if="currSubformID!==null">
                    <button :id="'header_' + currSubformID" @click="selectSubform(currSubformID)" title="select internal form">
                        <h2>{{shortFormNameStripped(currSubformID, 28)}}</h2>
                    </button>
                </li>

            </ul>
        </nav>
        
    </header>`
};