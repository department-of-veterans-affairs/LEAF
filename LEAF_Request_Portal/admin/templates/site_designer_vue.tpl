<!--{if true}-->
<div id="site-designer-app">
    <main>
        <section>
            <h2 style="margin: 1rem 0;">Site Designer</h2>
            <mod-home-menu></mod-home-menu>
            <hr style="margin: 2rem 0; border-bottom: 1px solid black;" />
            <h3 style="margin: 0.5rem 0;">This page is {{ home_enabled ? '' : 'not'}} enabled</h3>
            <button v-if="home_enabled !== null" class="btn-confirm" @click="postCustomHomeEnabled">
                {{ home_enabled ? 'Click to disable' : 'Click to enable'}}
            </button>

            <p class="test">test <a href="https://localhost/LEAF_Request_Portal/" target="_blank">home link</a></p>
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
<!--{/if}-->