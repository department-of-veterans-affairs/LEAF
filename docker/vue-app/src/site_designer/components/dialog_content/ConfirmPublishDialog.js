export default {
    name: 'confirm-publish-dialog',
    mounted() {
        this.setDialogSaveFunction(this.onSave);
    },
    inject: [
        'APIroot',
        'CSRFToken',
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
        <div v-if="currentViewEnabledDesignID !== 0 && currentViewEnabledDesignID !== currentDesignID">
            <div role="img" aria="" style="display: flex; justify-content: center; margin-bottom: 0.5rem;">⚠️</div>
            Another setting is active. &nbsp;Choose confirm to replace it.
        </div>
        <div v-else-if="currentViewEnabledDesignID === currentDesignID">
            <div role="img" aria="" style="display: flex; justify-content: center; margin-bottom: 0.5rem;">⚠️</div>
            <p>Choose confirm to deactivate this page and show the normal LEAF {{ currentView }}.</p>
        </div>
        <div v-else>Choose confirm to publish this page.</div>
    </div>`
}