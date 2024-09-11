<div id="vue-formeditor-app" v-cloak>
    <div id="vue_app_main" v-if="ajaxResponseMessage===''">
        <router-view></router-view>
    </div>
    <response-message v-else :message="ajaxResponseMessage"></response-message>
</div>

<script type="text/javascript" src="<!--{$app_js_path}-->/vue-dest/form_editor/LEAF_FormEditor.js" defer></script>

<script>
    const CSRFToken = '<!--{$CSRFToken}-->';
    const APIroot = '<!--{$APIroot}-->';
    const libsPath = '<!--{$libsPath}-->';
    const orgchartPath = '<!--{$orgchartPath}-->';

    const hasDevConsoleAccess = Number('<!--{$hasDevConsoleAccess}-->') > 0 ? true : false;
</script>
