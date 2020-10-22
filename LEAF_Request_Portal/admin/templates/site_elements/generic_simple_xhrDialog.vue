<modal id="simplexhrDialog" name="simplexhrDialog" role="dialog" :resizable="true" :height="this.height" :minWidth="this.minWidth" :adaptive="true" :scrollable="true">
    
    <div role="document">
        
        <div id="simpleloadIndicator" class="leaf-dialog-loader">
            Loading...<img src="../images/largespinner.gif" alt="loading..." />
        </div>

        <div class="vue-dialog-content-title" id="vue-title">
            {{ this.title }}
            <span style="padding: 10px; float: right;"><button @click="this.hide">X</button></span>
        </div>

        <main id="simplexhr" class="leaf-dialog-content" role="main" v-html="this.content"></main>
        
        <aside class="leaf-buttonBar" role="complementary">
            <div class="leaf-float-right">
                <button id="simplebutton_cancelchange" class="usa-button usa-button--outline" style="display: none;" @click="this.hide">
                    Cancel
                </button>
            </div>

            <div class="leaf-float-left">
                <button id="simplebutton_save" class="usa-button" style="display: none" @click="this.clickSave">
                    Save
                </button>
            </div>
        </aside>
        
    </div>

</modal>