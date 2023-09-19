<div id="vue-formeditor-app">
    <main v-if="ajaxResponseMessage===''">
        <mod-form-menu></mod-form-menu>
        <div style="display:none; padding: 0.5rem; margin: 0.5rem 0;" id="subordinate_site_warning">
            <h3 style="margin: 0 0 0.5rem 0; color: #a00;">This is a Nationally Standardized Subordinate Site</h3>
            <span><b>Do not make modifications!</b> &nbsp;Synchronization problems will occur. &nbsp;Please contact your process POC if modifications need to be made.</span>
        </div>

        <section>
            <router-view></router-view>
        </section>
    </main>
    <response-message v-else :message="ajaxResponseMessage"></response-message>
    <!-- DIALOGS -->
    <leaf-form-dialog v-if="showFormDialog" :has-dev-console-access='<!--{$hasDevConsoleAccess}-->'>
        <template #dialog-content-slot>
            <component :is="dialogFormContent" :ref="dialogFormContent"></component>
        </template>
    </leaf-form-dialog>
</div>

<script type="text/javascript" src="<!--{$app_js_path}-->/vue-dest/form_editor/LEAF_FormEditor.js" defer></script>

<script>
    const CSRFToken = '<!--{$CSRFToken}-->';
    const APIroot = '<!--{$APIroot}-->';
    const libsPath = '<!--{$libsPath}-->';
    const orgchartPath = '<!--{$orgchartPath}-->';

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
