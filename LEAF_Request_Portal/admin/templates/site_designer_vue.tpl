<!--{if true}-->
<div id="site-designer-app">
    <main>
        <section>
            <h2 style="margin: 1rem 0;">Site Designer</h2>
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
            <hr />
            <!-- NOTE: routes -->
            <router-view></router-view>
        </section>
    </main>
</div>

<script>
    const CSRFToken = '<!--{$CSRFToken}-->';
    const orgchartPath = '<!--{$orgchartPath}-->';
    const APIroot = '<!--{$APIroot}-->';
    const libsPath = '<!--{$libsPath}-->';
    const userID = '<!--{$userID}-->';
</script>

<script type="text/javascript" src="<!--{$libsPath}-->js/vue-dest/site_designer/LEAF_designer.js" defer></script>
<!--{/if}-->