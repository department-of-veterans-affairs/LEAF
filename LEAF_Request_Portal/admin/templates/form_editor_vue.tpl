<div id="vue-formeditor-app">
    <div v-if="siteSettings.siteType === 'national_subordinate'" id="subordinate_site_warning">
        <h3>This is a Nationally Standardized Subordinate Site</h3>
        <span>Do not make modifications! &nbsp;Synchronization problems will occur. &nbsp;Please contact your process POC if modifications need to be made.</span>
    </div>
    <mod-form-menu></mod-form-menu>
    <div style="display:flex; max-width: 2000px; margin: auto;">
        <!-- CATEGORY BROWSER / RESTORE FIELDS -->
        <template v-if="restoringFields===false">
            <div v-if="currCategoryID===null && appIsLoadingCategoryList === false" id="formEditor_content">
                <!-- secure form section -->
                <div v-if="showCertificationStatus" id="secure_forms_info" style="padding: 8px; background-color: #cb0000; margin-bottom:1em;">
                    <span id="secureStatus" style="font-size: 120%; padding: 4px; color: white; font-weight: bold;">LEAF-Secure Certified</span>
                    <a id="secureBtn" class="buttonNorm">View Details</a>
                </div>
                <!-- form broswer -->
                <div id="forms" style="display:flex; flex-wrap:wrap">
                    <category-card v-for="c in activeCategories" :categories-record="c" :key="'card_' + c.categoryID"></category-card>
                </div>
                <hr style="margin-top: 32px; border-top:1px solid #556;" aria-label="Not associated with a workflow" />
                <p>Not associated with a workflow:</p>
                <div id="forms_inactive" style="display:flex; flex-wrap:wrap">
                    <category-card v-for="c in inactiveCategories" :categories-record="c" :key="'card_' + c.categoryID"></category-card>
                </div>
            </div>
            <!-- SPECIFIC CATEGORY / FORM CONTENT -->
            <div v-else id="form_content_view">
                <form-view-controller v-if="currCategoryID !== null && appIsLoadingCategoryList === false"
                    :key="currentCategorySelection.categoryID + String(indicatorCountSwitch)"
                    orgchart-path='<!--{$orgchartPath}-->'>
                </form-view-controller>
            </div>
        </template>
        <restore-fields v-else></restore-fields>
    </div>
    <!-- DIALOGS -->
    <leaf-form-dialog v-if="showFormDialog" :has-dev-console-access='<!--{$hasDevConsoleAccess}-->'>  
        <template #dialog-content-slot>
        <component :is="dialogFormContent" :ref="dialogFormContent"></component>
        </template>
    </leaf-form-dialog>
</div>

<script type="text/javascript" src="../../libs/js/vue-dest/LEAF_FormEditor_main_build.js" defer></script>

<script>
    const CSRFToken = '<!--{$CSRFToken}-->';
    let postRenderFormBrowser;

    $(function() {
        <!--{if $referFormLibraryID != ''}-->
            postRenderFormBrowser = function() { 
                $('.formLibraryID_<!--{$referFormLibraryID}-->')
                .animate({'background-color': 'yellow'}, 1000)
                .animate({'background-color': 'white'}, 1000)
                .animate({'background-color': 'yellow'}, 1000);
            };
        <!--{/if}-->
    });
</script>