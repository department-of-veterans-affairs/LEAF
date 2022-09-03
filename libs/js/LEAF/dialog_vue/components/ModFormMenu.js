export default { 
    inject: [
        'selectNewCategory',
        'categories',
        'currCategoryID',
        'ajaxSelectedCategoryStapled',
        'restoringFields',
        'showRestoreFields'
    ],
    computed: {
        internalForms() {
            return 1; //TODO:
        },
        formName() {
            const maxlen = 16;
            const name = this.categories[this.currCategoryID]?.categoryName || 'untitled';
            return name <= maxlen ? name : name.slice(0, maxlen) + '...'
        }
    },
    methods: {
        createForm(event, catID = null) {
            console.log('clicked app menu nav createForm', catID);
        },
        deleteForm() {
            console.log('clicked app menu nav deleteForm', this.currCategoryID);
        },
        exportForm() {
            console.log('clicked app menu nav exportForm', this.currCategoryID);
        },
        viewHistory() {
            console.log('clicked app menu nav viewHistory', this.currCategoryID);
        },
        mergeFormDialog() {
            console.log('clicked app menu nav mergeFormDialog');
        }
    },
    template: `
        <div id="menu2" class="mod-form-menu-nav">
            <ul v-if="currCategoryID===null || restoringFields===true">
                <li><a href="#" id="createFormButton" @click="createForm"><img src="../../libs/dynicons/?img=document-new.svg&w=32" alt="" />Create Form</a></li>
                <li><a href="./?a=formLibrary"><img src="../../libs/dynicons/?img=system-file-manager.svg&w=32" alt="" />LEAF Library</a></li>
                <li><a href="./?a=importForm"><img src="../../libs/dynicons/?img=package-x-generic.svg&w=32" alt="" />Import Form</a></li>
                <li v-if="!restoringFields"><a href="#" @click="showRestoreFields"><img src="../../libs/dynicons/?img=user-trash-full.svg&w=32" alt="" />Restore Fields</a></li>
                <li v-else><a href="#" @click="selectNewCategory(null)"><img src="../../libs/dynicons/?img=system-file-manager.svg&w=32" alt="" />View All Forms</a></li>
            </ul>
            <ul v-else>
                <li><a href="#" @click="selectNewCategory(null)"><img src="../../libs/dynicons/?img=system-file-manager.svg&w=32" alt="" />View All Forms</a></li>
                <ul>
                    <li style="margin-bottom:0.1em"><a href="#" :id="currCategoryID"><img src="../../libs/dynicons/?img=document-open.svg&w=32" alt="" />{{ formName }}</a></li>
                    <li><a href="#" @click="createForm(event, currCategoryID)"><img src="../../libs/dynicons/?img=list-add.svg&w=32" alt="" />Add Internal-Use</a></li>
                </ul>
                <li><a href="#" @click="mergeFormDialog"><img src="../../libs/dynicons/?img=tab-new.svg&w=32" alt="" />Staple other form</a></li>
                <div id="stapledArea">
                    <ul v-if="ajaxSelectedCategoryStapled.length > 0">
                        <li v-for="s in ajaxSelectedCategoryStapled">&nbsp;{{s.categoryName}}</li>
                    </ul>
                </div>
                <li><a href="#" @click="viewHistory"><img src="../../libs/dynicons/?img=appointment.svg&amp;w=32" alt="" />View History</a></li>
                <li><a href="#" @click="exportForm"><img src="../../libs/dynicons/?img=network-wireless.svg&w=32" alt="" />Export Form</a></li>
                <li><a href="#" @click="deleteForm"><img src="../../libs/dynicons/?img=user-trash.svg&w=32" alt="" />Delete this form</a></li>
                <li><a href="#" @click="showRestoreFields"><img src="../../libs/dynicons/?img=user-trash-full.svg&w=32" alt="" />Restore Fields</a></li>
            </ul>
        </div>`
};