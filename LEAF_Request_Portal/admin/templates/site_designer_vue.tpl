<!--{if true}-->
<div id="site-designer-app" v-cloak>
    <main>
        <section :class="{editMode: isEditingMode}">
            <div id="page_select_area">
                <h2 style="margin-right: auto;">
                    <a href="../admin" class="leaf-crumb-link">Admin</a>
                    <i class="fas fa-caret-right leaf-crumb-caret"></i>Site Designer - 
                    {{ currentView }}
                        <span v-show="currentDesignID!==0">
                            (<span :style="{color: enabled ? '#008060' : '#b00000'}">{{ enabled ? 'active' : 'draft'}}</span>)
                        </span>
                </h2>
                <label v-if="customizablePages.length > 1" for="current_view_select" style="display:block; margin: 0;">Select a Page&nbsp;
                    <select id="current_view_select" style="width:120px; height: 25px;" v-model="currentView">
                        <option v-if="currentView===''" value="">Select a Page</option>
                        <option v-for="view in customizablePages" :key="'view_option_' + view" :value="view">{{ view }}</option>
                    </select>
                </label>
                <div v-show="currentDesignID !== 0" style="display:flex; gap: 1rem;">
                    <button type="button" class="btn-general" style="width: 130px; height: 1.75rem;" @click="setEditMode(!isEditingMode)">
                        {{isEditingMode ? 'Preview ' : 'Edit '}} Page
                    </button>
                    <button type="button" @click="publishTemplate(enabled ? 0 : currentDesignID, currentView)"
                        class="btn-confirm" :class="{enabled: enabled}" 
                        style="width: 130px;" :disabled="appIsUpdating">
                        {{ enabled ? 'Disable Page' : 'Publish Page'}}
                    </button>
                </div>
            </div>
            <template v-if="allDesignData !== null && currentViewDesigns?.length > 0">
                <label for="saved_settings_select">Saved Settings</label>
                <select id="saved_settings_select" v-model.number="currentDesignID">
                    <option value="0">Select an Option</option>
                    <option v-for="d in currentViewDesigns" :value="d.designID" :key="'design_' + d.designID">
                        {{ d.designID }} {{ d.designID === currentViewEnabledDesignID ? '(active)' : '(draft)'}}
                    </option>
                </select>
            </template>
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