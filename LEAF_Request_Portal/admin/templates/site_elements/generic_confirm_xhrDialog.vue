<modal id="confirm_xhrDialog" name="confirm_xhrDialog" role="dialog" :height="this.height" :minWidth="this.minWidth" :adaptive="true">
    
    <form id="confirm_record" enctype="multipart/form-data" action="javascript:void(0);">
        
        <div role="document">
            
             <div id="confirm_loadIndicator" class="leaf-dialog-loader">
                Loading...<img src="../images/largespinner.gif" alt="loading..." />
            </div>

            <div class="vue-dialog-content-title" id="vue-title">
                {{ this.title }}
                <span style="padding: 10px; float: right;"><button @click="this.hide">X</button></span>
            </div>

            <main id="confirm_xhr" class="leaf-dialog-content" role="main" v-html="this.content"></main>

            <aside class="leaf-buttonBar" role="complementary">
                <div class="leaf-float-right">
                    <button class="usa-button usa-button--outline" id="confirm_button_cancelchange" @click="this.hide">No</button>
                </div>

                <div class="leaf-float-left">
                    <button class="usa-button" id="confirm_button_save" @click="this.clickSave"><span id="confirm_saveBtnText">Yes</span></button>
                </div>
            </aside>
        
        </div>

    </form>

</modal>