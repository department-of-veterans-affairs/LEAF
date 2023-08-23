export default {
    name: 'confirm-publish-dialog',
    mounted() {
        this.setDialogSaveFunction(this.onSave);
    },
    inject: [
        'closeFormDialog',
        'setDialogSaveFunction',

        'publishTemplate',
        'currentDesignID',
        'currentView',
        'currentViewEnabledDesignID'
    ],
    methods:{
        onSave() {
            const id = this.currentDesignID === this.currentViewEnabledDesignID ? 0 : this.currentDesignID;
            this.publishTemplate(id, this.currentView, true);
            this.closeFormDialog();
        }
    },
    template:`<div style="min-height: 60px; max-width: 500px;">
        <!-- warn if activating and another page is already active -->
        <div v-if="currentViewEnabledDesignID !== 0 && currentViewEnabledDesignID !== currentDesignID">
            <div role="img" aria="" style="display: flex; justify-content: center; margin-bottom: 0.5rem;">⚠️</div>
            Another setting is active. &nbsp;Choose confirm to replace it.
        </div>
        <!-- warn if disabling an active page -->
        <div v-else-if="currentViewEnabledDesignID === currentDesignID">
            <div role="img" aria="" style="display: flex; justify-content: center; margin-bottom: 0.5rem;">⚠️</div>
            <p>Disabling this page will show the normal LEAF {{ currentView }}.</p>
        </div>
        <div v-else>This page will be shown instead of the normal LEAF {{ currentView }}.</div>
    </div>`
}