<!--{if true}-->
<div id="site-designer-app" v-cloak>
    <main>
        <section :class="{editMode: isEditingMode}">
            <div id="page_info_area">
                <!-- admin nav, page and name info, preview and publication options -->
                <div v-show="isEditingMode">
                    <h2 style="min-width: 250px;">
                        <a href="../admin" class="leaf-crumb-link">Admin</a>
                        <i class="fas fa-caret-right leaf-crumb-caret"></i>Site Designer
                    </h2>
                </div>
                <label v-show="isEditingMode && currentDesignID > 0" for="edit_design_name_input"
                    style="margin: 0; font-size: 1.25rem;">title&nbsp;
                    <input type="text" id="edit_design_name_input" maxlength="50" v-model.lazy="currentDesignName" />
                    &nbsp;(<span :style="{color: enabled ? '#AA0000' : '#000000'}">{{ enabled ? 'active' : 'draft'}}</span>)
                </label>
                <div v-show="currentDesignID > 0" style="gap: 1rem;">
                    <button type="button" class="btn-general" style="margin-left:auto;" @click="setEditMode(!isEditingMode)">
                        {{isEditingMode ? 'Preview ' : 'Edit '}} Page
                    </button>
                    <button type="button" @click="publishTemplate(enabled ? 0 : currentDesignID, currentView)"
                        class="btn-confirm" :class="{delete: enabled}" :disabled="appIsUpdating">
                        {{ enabled ? 'Disable Page' : 'Publish Page'}}
                    </button>
                </div>
            </div>
            <!-- menu for saved designs for the current view, edit, new, delete design options -->
            <div v-show="isEditingMode" id="design_menu">
                <label v-if="customizableViews.length > 1" for="current_view_select">Select a Page
                    <select id="current_view_select" style="width:100px;" @change="setView">
                        <option v-if="currentView===''" value="">Select a Page</option>
                        <option v-for="view in customizableViews" :key="'view_option_' + view"
                        :value="view" :selected="currentView===view">{{ view }}</option>
                    </select>
                </label>
                <label v-if="currentViewDesigns?.length > 0" for="saved_settings_select">Saved Settings
                    <select id="saved_settings_select" style="width:180px;" v-model.number="currentDesignID">
                        <option value="0">Select an Option</option>
                        <option v-for="d in currentViewDesigns" :value="d.designID" :key="'design_' + d.designID" style="max-width:200px;" >
                            #{{ d.designID }} {{ truncateText(d.designName, 30) }} {{ d.designID === currentViewEnabledDesignID ? '(active)' : '(draft)'}}
                        </option>
                    </select>
                </label>
                <button type="button" class="btn-general" @click="openNewDesignDialog"
                    :title="'create a new setting for the '+ currentView">+ New
                </button>
                <button v-if="currentDesignID!==currentViewEnabledDesignID" type="button"
                    class="btn-confirm delete" title="Delete this design"
                    @click="openDeleteDesignDialog">Delete
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