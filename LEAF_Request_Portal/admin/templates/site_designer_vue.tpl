<!--{if true}-->
<div id="site-designer-app" v-cloak>
    <nav id="general_options" style="display: flex;">
        <button @click="openHistoryDialog">{{ currentView }} history<span role="img" aria="">🕒</span></button>
        <button type="button" 
            :title="'create a new design for the '+ currentView"
            @click="openNewDesignDialog">New Design<span role="img" aria="">➕</span>
        </button>
        <button v-if="currentDesignID > 0" type="button" 
            :title="'create a draft version of '+ currentDesignName"
            @click="openNewDesignDialog(true)">Copy Draft<span role="img" aria=""></span>
        </button>
        <button v-if="currentDesignID > 0" type="button"
            class="delete" :title="currentDesignID===currentViewEnabledDesignID ?
                'This page must be unpublished before it can be deleted' : 'Delete this design'"
            :disabled="currentDesignID===currentViewEnabledDesignID"
            @click="openDeleteDesignDialog">Delete Design<span role="img" aria="">❌</span>
        </button>
        <button v-show="currentDesignID > 0" type="button"
            @click="setEditMode(!isEditingMode)">
            {{isEditingMode ? 'Preview ' : 'Edit '}} Page <span role="img" aria="">{{isEditingMode ? '👁️‍🗨️' : '📝'}}</span>
        </button>
        <button v-show="currentDesignID > 0" type="button"
            style="color: white; margin-left: auto;"
            :style="{backgroundColor: !selectedMenuValid ? 'gray' : isPublished ? '#A02020' : '#005EA2'}" @click="publishTemplate"
            :disabled="appIsUpdating || !selectedMenuValid">
            {{ isPublished ? 'Disable Page' : 'Publish Page'}}<span role="img" aria="">{{ isPublished ? '⚠' : '▶'}}</span>
        </button>
    </nav>
    <main :class="{editMode: isEditingMode}">
        <div id="page_info_area">
            <!-- admin home link, page and name info -->
            <h2 v-show="isEditingMode" style="min-width: 250px;">
                <a href="../admin" class="leaf-crumb-link">Admin</a>
                <i class="fas fa-caret-right leaf-crumb-caret"></i>Site Designer
            </h2>
            <label v-show="isEditingMode && currentDesignID > 0" for="edit_design_name_input">title
                <input type="text" id="edit_design_name_input" maxlength="50" v-model.lazy="currentDesignName" />
                <span :style="{color: isPublished ? '#AA0000' : '#3D4551'}">{{ isPublished ? '(active)' : '(draft)'}}</span>
            </label>
        </div>
        <!-- view selection (if/when there's more than one view), saved designs for the current view -->
        <div v-show="isEditingMode" id="view_and_design_selectors">
            <label v-if="customizableViews.length > 1" for="current_view_select">Page Selection
                <select id="current_view_select" style="width:100px;" @change="setView">
                    <option v-if="currentView===''" value="">Select a Page</option>
                    <option v-for="view in customizableViews" :key="'view_option_' + view"
                    :value="view" :selected="currentView===view">{{ view }}</option>
                </select>
            </label>
            <label v-if="currentViewDesigns?.length > 0" for="saved_settings_select">Saved {{ currentView }} Settings
                <select id="saved_settings_select" v-model.number="currentDesignID">
                    <option value="0">Select an Option</option>
                    <option v-for="d in currentViewDesigns" :value="d.designID" :key="'design_' + d.designID">
                        #{{ d.designID }} {{ truncateText(d.designName, 30) }} {{ d.designID === currentViewEnabledDesignID ? '(active)' : '(draft)'}}
                    </option>
                </select>
            </label>
        </div>

        <!-- TODO: TESTING SELECT FOR CARD IMPORTS -->
        <!-- <select v-if="cardVault.length > 0" style="width: 280px;">
            <option value=''>Select a Card</option>
            <option v-for="c in cardVault" value="c.designName" :key="'card_select_' + c.designName">{{ getCardTitle(c.designContent)}}</option>
        </select> -->

        <!-- NOTE: routes -->
        <div id="current_view" :class="{editMode: isEditingMode}">
            <router-view></router-view>
        </div>
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