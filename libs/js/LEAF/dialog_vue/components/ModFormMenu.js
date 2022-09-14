export default {
    inject: [
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
        'openStapleFormsDialog'
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
        deleteForm() {
            console.log('clicked app menu nav deleteForm', this.currCategoryID);
        },
        exportForm() {
            console.log('clicked app menu nav exportForm', this.currCategoryID);
        },
        selectMainForm() {
            console.log('clicked main form', this.currCategoryID);
            this.selectNewCategory(this.currCategoryID);
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
        }
    },
    template: `
        <div id="menu" class="mod-form-menu-nav">
            <ul v-if="currCategoryID===null || restoringFields===true">
                <li>
                    <a href="#" id="createFormButton" @click="openNewFormDialog">
                    Create Form<span>📄</span>
                    </a>
                </li>
                <li>
                    <a href="./?a=formLibrary">
                    LEAF Library<span>📘</span>
                    </a>
                </li>
                <li>
                    <a href="#" @click="openImportFormDialog">
                    Import Form<span>📦</span>
                    </a>
                </li>
                <li v-if="!restoringFields">
                    <a href="#" @click="showRestoreFields">
                    Restore Fields<span>♻️</span>
                    </a>
                </li>
                <li v-else>
                    <a href="#" @click="selectNewCategory(null)">
                    View All Forms<span>💼</span>
                    </a>
                </li>
            </ul>
            <ul v-else>
                <li>
                    <a href="#" @click="selectNewCategory(null)">
                    View All Forms<span>💼</span>
                    </a>
                </li>
                <ul><!-- MAIN AND INTERNAL FORMS -->
                    <li style="margin-bottom:0.1em">
                        <a href="#" :id="currCategoryID" @click="selectMainForm" title="select form">
                        {{formName(categories[currCategoryID].categoryName)}}<span>📂</span>
                        </a>
                    </li>
                    <li v-for="i in internalForms" style="margin-bottom:0.1em">
                        <a href="#" :id="i.categoryID" :key="i.categoryID" @click="selectSubform(i.categoryID)" title="select internal form">
                        {{formName(i.categoryName, 20)}}<span>📋</span>
                        </a>
                    </li>
                    <li>
                        <a href="#" @click="openNewFormDialog" title="add new internal use form">
                        Add Internal-Use<span>➕</span>
                        </a>
                    </li>
                </ul>
                <li>
                    <a href="#" @click="openStapleFormsDialog" title="staple another form">
                    Stapled Forms<span>📌</span>
                    </a>
                </li>
                <div id="stapledArea">
                    <ul v-if="ajaxSelectedCategoryStapled.length > 0" style="margin-top: -0.5em;">
                        <li v-for="s in ajaxSelectedCategoryStapled" style="margin-bottom:0.2em;">
                        {{s.categoryName || 'Untitled'}}
                        </li>
                    </ul>
                </div>
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
                    <a href="#" @click="deleteForm" title="delete form">
                    Delete this form<span>❌</span>
                    </a>
                </li>
                <li>
                    <a href="#" @click="showRestoreFields">
                    Restore Fields<span>♻️</span>
                    </a>
                </li>
            </ul>
        </div>`
};