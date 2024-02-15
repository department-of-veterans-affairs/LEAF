export default {
    name: 'browser-menu',
    inject: [
        'siteSettings',
        'openNewFormDialog',
        'openImportFormDialog'
    ],
    template: `<div><nav id="top-menu-nav">
        <!-- FORM BROWSER AND RESTORE FIELDS MENU -->
        <ul>
            <li v-if="$route.name === 'restore'">
                <router-link :to="{ name: 'browser' }" class="router-link">
                    Form Browser
                </router-link>                
            </li>
            <li>
                <button type="button" id="createFormButton" @click="openNewFormDialog()">
                    <span role="img" aria="">📄&nbsp;</span>Create Form
                </button>
            </li>
            <li>
                <a href="./?a=formLibrary" class="router-link"><span role="img" aria="">📘&nbsp;</span>LEAF Library</a>
            </li>
            <li>
                <button type="button" @click="openImportFormDialog">
                    <span role="img" aria="">📦&nbsp;</span>Import Form
                </button>
            </li>
            <li v-if="$route.name === 'browser'">
                <router-link :to="{ name: 'restore' }" class="router-link" >
                    <span role="img" aria="">♻️&nbsp;</span>Restore Fields
                </router-link>
            </li>
        </ul>
    </nav>
    <div v-if="siteSettings?.siteType==='national_subordinate'" id="subordinate_site_warning" style="padding: 0.5rem; margin: 0.5rem 0;" >
        <h3 style="margin: 0 0 0.5rem 0; color: #a00;">This is a Nationally Standardized Subordinate Site</h3>
        <span><b>Do not make modifications!</b> &nbsp;Synchronization problems will occur. &nbsp;Please contact your process POC if modifications need to be made.</span>
    </div></div>`
};