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
        'openFormHistoryDialog'
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
        mergeFormDialog() {
            console.log('clicked app menu nav mergeFormDialog');
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
                    <img src="../../libs/dynicons/?img=document-new.svg&w=32" alt="" />
                    <div>Create Form</div>
                    </a>
                </li>
                <li>
                    <a href="./?a=formLibrary">
                    <img src="../../libs/dynicons/?img=x-office-address-book.svg&w=32" alt="" />
                    <div>LEAF Library</div>
                    </a>
                </li>
                <li>
                    <a href="#" @click="openImportFormDialog">
                    <img src="../../libs/dynicons/?img=package-x-generic.svg&w=32" alt="" />
                    <div>Import Form</div>
                    </a>
                </li>
                <li v-if="!restoringFields">
                    <a href="#" @click="showRestoreFields">
                    <img src="../../libs/dynicons/?img=user-trash-full.svg&w=32" alt="" />
                    <div>Restore Fields</div>
                    </a>
                </li>
                <li v-else>
                    <a href="#" @click="selectNewCategory(null)">
                    <img src="../../libs/dynicons/?img=system-file-manager.svg&w=32" alt="" />
                    <div>View All Forms</div>
                    </a>
                </li>
            </ul>
            <ul v-else>
                <li>
                    <a href="#" @click="selectNewCategory(null)">
                    <img src="../../libs/dynicons/?img=system-file-manager.svg&w=32" alt="" />
                    <div>View All Forms</div>
                    </a>
                </li>
                <ul><!-- MAIN AND INTERNAL FORMS -->
                    <li style="margin-bottom:0.1em">
                        <a href="#" :id="currCategoryID" @click="selectMainForm">
                        <img src="../../libs/dynicons/?img=document-open.svg&w=32" alt="" />
                        <div>{{ formName(categories[currCategoryID].categoryName) }}</div>
                        </a>
                    </li>
                    <li v-for="i in internalForms" style="margin-bottom:0.1em">
                        <a href="#" :id="i.categoryID" :key="i.categoryID" @click="selectSubform(i.categoryID)">
                        <div>{{ formName(i.categoryName, 24) }}</div>
                        </a>
                    </li>
                    <li>
                        <a href="#" @click="openNewFormDialog">
                        <img src="../../libs/dynicons/?img=list-add.svg&w=32" alt="" />
                        <div>Add Internal-Use</div>
                        </a>
                    </li>
                </ul>
                <li>
                    <a href="#" @click="mergeFormDialog">
                    <img src="../../libs/dynicons/?img=tab-new.svg&w=32" alt="" />
                    <div>Staple other form</div>
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
                    <a href="#" @click="openFormHistoryDialog">
                    <img src="../../libs/dynicons/?img=appointment.svg&amp;w=32" alt="" />
                    <div>View History</div>
                    </a>
                </li>
                <li>
                    <a href="#" @click="exportForm">
                    <img src="../../libs/dynicons/?img=network-wireless.svg&w=32" alt="" />
                    <div>Export Form</div>
                    </a>
                </li>
                <li>
                    <a href="#" @click="deleteForm">
                    <img src="../../libs/dynicons/?img=user-trash.svg&w=32" alt="" />
                    <div>Delete this form</div>
                    </a>
                </li>
                <li>
                    <a href="#" @click="showRestoreFields">
                    <img src="../../libs/dynicons/?img=user-trash-full.svg&w=32" alt="" />
                    <div>Restore Fields</div>
                    </a>
                </li>
            </ul>
        </div>`
};