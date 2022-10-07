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
        'ajaxSelectedCategoryStapled',
        'restoringFields',
        'showRestoreFields',
        'openNewFormDialog',
        'openImportFormDialog',
        'openFormHistoryDialog',
        'openStapleFormsDialog',
        'openConfirmDeleteFormDialog',
    ],
    computed: {
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
        //export the main form along with its internals
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
                console.log('promise all:', exportCalls);
                let outPacket = {};
                outPacket.version = 1;
                outPacket.name = this.categories[catID].categoryName + ' (Copy)';
                outPacket.description = this.categories[catID].categoryDescription;
                outPacket.packet = packet;

                let outBlob = new Blob([JSON.stringify(outPacket).replace(/[^ -~]/g,'')], {type : 'text/plain'}); // Regex replace needed to workaround IE11 encoding issue
                saveAs(outBlob, 'LEAF_FormPacket_'+ catID +'.txt');
            });
        },
        selectMainForm() {
            console.log('clicked main form', this.currCategoryID);
            this.selectNewCategory(this.currCategoryID, false);
        },
        selectSubform(subformID){
            console.log('clicked subform', 'sub', subformID, 'main', this.currCategoryID);
            this.selectNewCategory(subformID, true);
        },
        formName(catName, len = 16) {
            let elFilter = document.createElement('div')
            elFilter.innerHTML = catName || 'untitled';
            const name = this.truncateText(elFilter.innerText, len);
            return name;
        },
        shortFormNameStripped(formName, len) { //NOTE: XSSHelpers global
            let name = formName || 'Untitled';
            name = XSSHelpers.stripAllTags(name);
            return this.truncateText(name, len).trim();
        },
    },
    template: `<header id="form-editor-header">
        <button type="button"
            :title="(menuPinned ? 'close ' : 'pin ') + 'menu'"
            id="form-editor-menu-toggle" 
            @click="toggleMenu" @mouseenter="showMenu">
            <span>{{menuPinned ? '↡' : menuOpen ? '⭱' : '⭳'}}</span>menu
        </button>
        
        <button type="button" @click="selectNewCategory(null)" title="View All Forms">
            <h2><span class="header-icon">🗃️</span>Form Editor</h2>
        </button>
        
        <template v-if="currCategoryID!==null">
            <span style="font-size: 1.5rem; margin: 0 1rem; font-weight:bold;">❯</span>
        
            <button type="button" :id="currCategoryID" @click="selectMainForm" title="main form">
                <h2><span class="header-icon">📂</span>{{shortFormNameStripped(categories[currCategoryID].categoryName, 26)}}</h2>
            </button>
        </template>
        
        <template v-if="internalForms.length > 0">
            <span style="font-size: 1.5rem; margin: 0 1rem; font-weight:bold;">❯</span>
            <div style="display: flex; position: relative;">
                <button type="button"><h2><span class="header-icon">📋</span>Internal Forms</h2></button>
                <ul id="internalForms">
                    <li v-for="i in internalForms" :key="i.categoryID">
                        <a href="#" :id="i.categoryID" @click="selectSubform(i.categoryID)" title="select internal form">
                        {{formName(i.categoryName, 28)}}
                        </a>
                    </li>
                </ul>
            </div>
        </template>
        
        <nav v-if="menuOpen" id="form-editor-nav">
            <ul v-if="currCategoryID===null" @mouseenter="showMenu" @mouseleave="hideMenu">
                <li>
                    <a href="#" id="createFormButton" @click="openNewFormDialog">
                    Create Form<span>📄</span>
                    </a>
                </li>
                <li>
                    <a href="#" @click="openImportFormDialog">
                    Import Form<span>📦</span>
                    </a>
                </li>
                <li>
                    <a href="#" @click="showRestoreFields">
                    Restore Fields<span>♻️</span>
                    </a>
                </li>
                <li>
                    <a href="./?a=formLibrary">
                    LEAF Library<span>📘</span>
                    </a>
                </li>
            </ul>
            <ul v-else @mouseenter="showMenu" @mouseleave="hideMenu">
                <li>
                    <a href="#" @click="openNewFormDialog" title="add new internal use form">
                    Add Internal-Use<span>➕</span>
                    </a>
                </li>
                <li>
                    <a href="#" @click="openStapleFormsDialog" title="staple another form">
                    Edit Stapled Forms<span>📌</span>
                    </a>
                    <ul v-if="ajaxSelectedCategoryStapled.length > 0">
                        <li v-for="s in ajaxSelectedCategoryStapled" :key="'staple_' + s.stapledCategoryID">
                        {{s.categoryName || 'Untitled'}}
                        </li>
                    </ul>
                </li>
                <li>
                    <a href="#" @click="openFormHistoryDialog" title="view form history">
                    View History<span>🕗</span>
                    </a>
                </li>
                <li>
                    <a href="#" @click="exportForm" title="export form">
                    Export Form<span>💾</span>
                    </a>
                </li>
                <li>
                    <a href="#" @click="openConfirmDeleteFormDialog" title="delete this form">
                    Delete this form<span>❌</span>
                    </a>
                </li>
            </ul>
        </nav>
    </header>`
};