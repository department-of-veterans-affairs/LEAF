export default {
    data() {
        return {
            menuOpen: false,
            clickedOn: false
        }
    },
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
            this.clickedOn = !this.clickedOn;
            this.menuOpen = this.clickedOn;
        },
        showMenu() {
            this.menuOpen = true;
        },
        hideMenu() {
            if (!this.clickedOn) {
                this.menuOpen = false;
            }
        },
        exportForm() {
            console.log('clicked app menu nav exportForm', this.currCategoryID);
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
            :title="(clickedOn ? 'close ' : 'pin ') + 'menu'"
            id="form-editor-menu-toggle" 
            @click="toggleMenu" @mouseenter="showMenu">
            <span>{{clickedOn ? '↡' : menuOpen ? '⭱' : '⭳'}}</span>menu
        </button>
        
            <button type="button" @click="selectNewCategory(null)" title="View All Forms">
                <h2><span class="nav-icon">🗃️</span>Form Editor</h2>
            </button>
        
        <div v-if="currCategoryID!==null" style="display:flex; align-items:center;">
            <span style="font-size: 1.5rem; margin: 0 1rem; font-weight:bold;">❯</span>
        
            <button type="button" :id="currCategoryID" @click="selectMainForm" title="main form">
                <h2><span class="nav-icon">📂</span>{{shortFormNameStripped(categories[currCategoryID].categoryName, 26)}}
                </h2>
            </button>
        </div>
        
        <!--<template v-if="internalForms.length > 0">
            <div style="font-size: 1.5rem; margin: 0 1rem; font-weight:bold;">❯</div>
            <ul><span class="nav-icon">📋</span>Internal Forms</ul>
        </template>-->

        <nav v-if="menuOpen" id="form-editor-nav" class="mod-form-menu-nav">
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
                    <ul><!-- MAIN AND INTERNAL FORMS -->
                        <li v-for="i in internalForms" :key="i.categoryID">
                            <a href="#" :id="i.categoryID" @click="selectSubform(i.categoryID)" title="select internal form">
                            {{formName(i.categoryName, 20)}}<span>📋</span>
                            </a>
                        </li>
                        <li>
                            <a href="#" @click="openNewFormDialog" title="add new internal use form">
                            Add Internal-Use<span>➕</span>
                            </a>
                        </li>
                    </ul>
                </li>
                <li>
                    <a href="#" @click="openStapleFormsDialog" title="staple another form">
                    Stapled Forms<span>📌</span>
                    </a>
                </li>
                <div id="stapledArea">
                    <ul v-if="ajaxSelectedCategoryStapled.length > 0">
                        <li v-for="s in ajaxSelectedCategoryStapled" :key="'staple_' + s.stapledCategoryID">
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
                    <a href="#" @click="openConfirmDeleteFormDialog" title="delete this form">
                    Delete this form<span>❌</span>
                    </a>
                </li>
            </ul>
        </nav>
    </header>`
};