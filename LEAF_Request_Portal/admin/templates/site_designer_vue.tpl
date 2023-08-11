<!--{if true}-->
<div id="site-designer-app">
    <main>
        <section :class="{editMode: isEditingMode}">
            <div id="page_select_area">
                <h2 style="margin-right: auto;">
                    <a href="../admin" class="leaf-crumb-link">Admin</a>
                    <i class="fas fa-caret-right leaf-crumb-caret"></i>Site Designer
                </h2>
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
<!--{else}-->
    <div class="lf-alert">The page you are looking for does not exist or may have been moved. Please update your bookmarks.</div>
<!--{/if}-->