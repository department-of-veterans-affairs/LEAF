<div id="vue-formeditor-app" v-cloak>
    <main v-if="ajaxResponseMessage===''">
        <router-view></router-view>
    </main>
    <response-message v-else :message="ajaxResponseMessage"></response-message>
</div>

<script type="text/javascript" src="<!--{$app_js_path}-->/vue-dest/form_editor/LEAF_FormEditor.js" defer></script>

<script>
    const CSRFToken = '<!--{$CSRFToken}-->';
    const APIroot = '<!--{$APIroot}-->';
    const libsPath = '<!--{$libsPath}-->';
    const orgchartPath = '<!--{$orgchartPath}-->';

    const hasDevConsoleAccess = '<!--{$hasDevConsoleAccess}-->';
    
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
