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
                    <span>📄</span>Create Form
                    </a>
                </li>
                <li>
                    <a href="./?a=formLibrary">
                    <span>📘</span>LEAF Library
                    </a>
                </li>
                <li>
                    <a href="#" @click="openImportFormDialog">
                    <span>📦</span>Import Form
                    </a>
                </li>
                <li v-if="!restoringFields">
                    <a href="#" @click="showRestoreFields">
                    <span>♻️</span>Restore Fields
                    </a>
                </li>
                <li v-else>
                    <a href="#" @click="selectNewCategory(null)">
                    <span>💼</span>View All Forms
                    </a>
                </li>
            </ul>
            <ul v-else>
                <li>
                    <a href="#" @click="selectNewCategory(null)">
                    <span>💼</span> View All Forms
                    </a>
                </li>
                <ul><!-- MAIN AND INTERNAL FORMS -->
                    <li style="margin-bottom:0.1em">
                        <a href="#" :id="currCategoryID" @click="selectMainForm" title="select form">
                        <span>📂</span>{{formName(categories[currCategoryID].categoryName) }}
                        </a>
                    </li>
                    <li v-for="i in internalForms" style="margin-bottom:0.1em">
                        <a href="#" :id="i.categoryID" :key="i.categoryID" @click="selectSubform(i.categoryID)" title="select internal form">
                        <span>📋</span>{{formName(i.categoryName, 20) }}
                        </a>
                    </li>
                    <li>
                        <a href="#" @click="openNewFormDialog" title="add new internal use form">
                        <span>➕</span>Add Internal-Use
                        </a>
                    </li>
                </ul>
                <li>
                    <a href="#" @click="openStapleFormsDialog" title="staple another form">
                    <span>📌</span>Stapled Forms
                    </a>
                </li>
                <div id="stapledArea">
                    <ul v-if="ajaxSelectedCategoryStapled.length > 0">
                        <li v-for="s in ajaxSelectedCategoryStapled">
                        {{s.categoryName}}
                        </li>
                    </ul>
                </div>
                <li>
                    <a href="#" @click="openFormHistoryDialog" title="view form history">
                    <span>🕗</span>View History
                    </a>
                </li>
                <li>
                    <a href="#" @click="exportForm" title="export form">
                    <span>💾</span>Export Form
                    </a>
                </li>
                <li>
                    <a href="#" @click="deleteForm" title="delete form">
                    <span>❌</span>Delete this form
                    </a>
                </li>
                <li>
                    <a href="#" @click="showRestoreFields">
                    <span>♻️</span>Restore Fields
                    </a>
                </li>
            </ul>
        </div>`
};