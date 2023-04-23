<div id="site-designer-app">
    <main>
        <section>
            <h2 style="margin: 1rem 0;">Site Designer</h2>
            <mod-home-menu></mod-home-menu>
        </section>
    </main>
    <!-- DIALOGS -->
    <leaf-form-dialog v-if="showFormDialog" :has-dev-console-access='<!--{$hasDevConsoleAccess}-->'>
        <template #dialog-content-slot>
            <component :is="dialogFormContent" :ref="dialogFormContent"></component>
        </template>
    </leaf-form-dialog>
</div>

<script>
    const CSRFToken = '<!--{$CSRFToken}-->';
    const APIroot = '<!--{$APIroot}-->';
    const libsPath = '<!--{$libsPath}-->';
</script>

<script type="text/javascript" src="<!--{$libsPath}-->js/vue-dest/site_designer/LEAF_designer.js" defer></script>