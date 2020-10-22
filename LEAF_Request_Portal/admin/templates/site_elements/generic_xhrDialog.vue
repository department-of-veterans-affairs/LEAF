<modal id="xhrDialog" name="xhrDialog" role="dialog" :resizable="true" :height="this.height" :minWidth="this.minWidth" :adaptive="true" scrollable="true">
    
    <form id="record" enctype="multipart/form-data" action="javascript:void(0);">

        <div role="document">
            
            <div id="loadIndicator" class="leaf-dialog-loader">
                Loading...<img src="../images/largespinner.gif" alt="loading..." />
            </div>
            
            <div class="vue-dialog-content-title" id="vue-title">
                {{ this.title }}
                <span style="padding: 10px; float: right;"><button @click="this.hide">X</button></span>
            </div>
 
            <main id="xhr"role="main" class="leaf-dialog-content" role="main" v-html="this.content"></main>

            <aside class="leaf-buttonBar" role="complementary">
                <div class="leaf-float-right">
                    <button id="button_cancelchange" class="usa-button usa-button--outline leaf-btn-med leaf-float-left" @click="this.hide">
                        Cancel
                    </button>
                </div>

                <div class="leaf-float-left">
                    <button id="button_save" class="usa-button leaf-btn-med leaf-float-right" @click="this.clickSave">
                        Save
                    </button>
                </div>
            </aside>

        </div>

    </form>

</modal>