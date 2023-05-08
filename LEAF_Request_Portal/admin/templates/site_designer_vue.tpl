<!--{if true}-->
<div id="site-designer-app">
    <main>
        <h2 style="margin: 1rem;">Site Designer</h2>

        <!-- NOTE: routes -->
        <section>
            <div style="display:flex; justify-content: space-between;">
                <label v-if="views.length > 1" for="custom_page_select">Select a Page&nbsp;
                    <select id="custom_page_select" style="width:150px;" v-model="custom_page_select">
                        <option value="homepage">homepage</option>
                    </select>
                </label>
                <button type="button" class="btn-general" style="width: 145px" @click="setEditMode(!isEditingMode)">
                    {{isEditingMode ? 'Preview ' : 'Edit '}}this page
                </button>
            </div>
            <router-view></router-view>
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