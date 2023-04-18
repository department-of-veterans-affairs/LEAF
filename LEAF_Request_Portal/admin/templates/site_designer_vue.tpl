<div id="site-designer-app">
    <main>
        <section>
            <h2>TEST designer page load</h2>
            <p>{{ CSRFToken }}</p>
            <button @click="testShowDialog">Test Modal</button>
            <p>{{ test }}</p>
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

<script type="text/javascript" src="<!--{$libsPath}-->js/vue-dest/site_designer/LEAF_designer_main_build.js" defer></script>

<script>
    const CSRFToken = '<!--{$CSRFToken}-->';
</script>