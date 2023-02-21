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
        'stripAndDecodeHTML',
        'selectNewCategory',
        'categories',
        'currCategoryID',
        'currSubformID',
        'internalForms',
        'selectedFormTree',
        'selectedCategoryStapledForms',
        'stapledFormsCatIDs',
        'openNewFormDialog',
        'openImportFormDialog',
        'openFormHistoryDialog',
        'openStapleFormsDialog',
        'openConfirmDeleteFormDialog',
    ],
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
                saveAs(outBlob, 'LEAF_FormPacket_'+ catID +'.txt');
            }).catch(err => console.log('an error has occurred', err));
        },
        selectMainForm(catID = this.currCategoryID) {
            this.selectNewCategory(catID, false);
        },
        selectSubform(subformID = ''){
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
            const name = this.stripAndDecodeHTML(form?.categoryName) || 'Untitled';
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
                        <span role="img" aria="">{{menuPinned ? '↡' : menuOpen ? '⭱' : '⭳'}}</span>menu
                    </button>
                
                    <template v-if="menuOpen">
                        <ul v-if="currCategoryID === null" id="form-editor-menu"
                            @mouseenter="showMenu" @mouseleave="hideMenu">
                            <li>
                                <button id="createFormButton" @click="openNewFormDialog">
                                Create Form<span role="img" aria="">📄</span>
                                </button>
                            </li>
                            <li>
                                <a href="./?a=formLibrary">
                                LEAF Library<span role="img" aria="">📘</span>
                                </a>
                            </li>
                            <li>
                                <button @click="openImportFormDialog">
                                Import Form<span role="img" aria="">📦</span>
                                </button>
                            </li>
                            <li>
                                <router-link :to="{ name: 'restore' }" class="router-link">
                                <button>
                                Restore Fields<span role="img" aria="">♻️</span>
                                </button>
                                </router-link>
                            </li>
                        </ul>
                        <ul v-else id="form-editor-menu"
                            @mouseenter="showMenu" 
                            @mouseleave="hideMenu">
                            <li v-if="selectedFormTree.length !== 0">
                                <button @click="openNewFormDialog" title="add new internal use form">
                                Add Internal-Use<span role="img" aria="">➕</span>
                                </button>
                                <ul v-if="internalForms.length > 0" id="internalForms">
                                    <li v-for="i in internalForms" :key="'internal_' + i.categoryID">
                                        <button :id="i.categoryID" @click="selectSubform(i.categoryID)" title="select internal form">
                                        {{shortFormNameStripped(i.categoryID, 22)}}
                                        </button>
                                    </li>
                                </ul>
                            </li>
                            <li v-if="!stapledFormsCatIDs.includes(currCategoryID)">
                                <button @click="openStapleFormsDialog" title="staple another form">
                                    <div>
                                        Edit Main Form Staples<br/>
                                        <span class="staple-sort-info">form sort value: {{categories[currCategoryID].sort}}</span>
                                    </div><span role="img" aria="">📌</span>
                                </button>
                                <ul v-if="selectedCategoryStapledForms.length > 0" id="stapledForms">
                                    <li v-for="s in selectedCategoryStapledForms" 
                                        :key="'staple_' + s.stapledCategoryID">
                                        <button @click="selectMainForm(s.categoryID)">
                                            <div>
                                                {{shortFormNameStripped(s.categoryID, 20) || 'Untitled'}}<br/>
                                                <span class="staple-sort-info">staple sort value: {{s.sort}}</span>
                                            </div><span role="img" aria="">📑</span>
                                        </button>
                                    </li>
                                </ul>
                            </li>
                            <li>
                                <button @click="openFormHistoryDialog" title="view form history">
                                View History<span role="img" aria="">🕗</span>
                                </button>
                            </li>
                            <li>
                                <button @click="exportForm" title="export form">
                                Export Form<span role="img" aria="">💾</span>
                                </button>
                            </li>
                            <li>
                                <button @click="openConfirmDeleteFormDialog" title="delete this form">
                                Delete this form<span role="img" aria="">❌</span>
                                </button>
                            </li>
                        </ul>
                    </template>
                </li>
                
                <li>
                    <router-link :to="{ name: 'category' }" class="router-link">
                    <button type="button" @click="selectNewCategory(null)" title="View All Forms">
                        <h2>Form Editor</h2>
                    </button>
                    </router-link>
                    <span v-if="currCategoryID !== null" class="header-arrow" role="img" aria="">❯</span>
                </li>
                <li v-if="currCategoryID !== null">
                    <button type="button" :id="'header_'+currCategoryID" @click="selectMainForm(currCategoryID)" title="main form">
                        <h2>{{shortFormNameStripped(currCategoryID, 50)}}</h2>
                    </button>
                    <span v-if="currSubformID !== null" class="header-arrow" role="img" aria="">❯</span>
                </li>
                <li v-if="currSubformID !== null">
                    <button :id="'header_' + currSubformID" @click="selectSubform(currSubformID)" title="select internal form">
                        <h2>{{shortFormNameStripped(currSubformID, 50)}}</h2>
                    </button>
                </li>

            </ul>
        </nav>
        
    </header>`
};