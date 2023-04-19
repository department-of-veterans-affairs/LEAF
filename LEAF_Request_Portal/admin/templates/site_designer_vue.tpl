<div id="site-designer-app">
    <main>
        <section>
            <h2>Site Designer</h2>
            <button class="btn-general" @click="openDesignButtonDialog">Test Modal</button>
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

<script type="text/javascript" src="<!--{$libsPath}-->js/vue-dest/site_designer/LEAF_designer.js" defer></script>

<script>
    const CSRFToken = '<!--{$CSRFToken}-->';
    const APIroot = '<!--{$APIroot}-->';
</script>