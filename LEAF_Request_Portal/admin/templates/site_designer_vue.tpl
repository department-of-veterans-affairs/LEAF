<!--{if false}-->
<div id="site-designer-app">
    <main>
        <section>
            <div style="display:flex; gap: 1rem; align-items: center;">
                <h2 style="margin-right: auto;">Site Designer</h2>
                <label v-if="views.length > 1" for="custom_page_select" style="display:block; margin: 0;">Select a Page&nbsp;
                    <select id="custom_page_select" style="width:150px;" v-model="custom_page_select">
                        <option v-if="custom_page_select===''" value="">Select a Page</option>
                        <option v-for="view in views" :key="'view_option_' + view" :value="view">{{ view }}</option>
                    </select>
                </label>
                <button type="button" class="btn-general" style="width: 145px; height: 1.75rem;" @click="setEditMode(!isEditingMode)">
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

<script type="text/javascript" src="<!--{$app_js_path}-->/vue-dest/site_designer/LEAF_designer.js" defer></script>
<!--{else}-->
    <div class="lf-alert">The page you are looking for does not exist or may have been moved. Please update your bookmarks.</div>
<!--{/if}-->