<div id="xhrDialog" style="visibility: hidden; display: none; background-color: white; padding: 4px">

    <form id="record" enctype="multipart/form-data" action="javascript:void(0);">
        
        <div>
            <button id="button_cancelchange" class="usa-button usa-button--outline leaf-btn-med leaf-float-left">
                <i class="fas fa-ban leaf-btn-icon"></i>Cancel
            </button>
            <button id="button_save" class="usa-button leaf-btn-med leaf-float-right">
                <i class="fas fa-save leaf-btn-icon"></i>Save Change
            </button>
        </div>

        <div class="leaf-row-space"></div>

        <div>

            <div id="loadIndicator" style="visibility: hidden; z-index: 9000; position: absolute; text-align: center; font-weight: bold; background-color: #f2f5f7; padding: 16px; height: 400px; width: 526px">
                <img src="../images/largespinner.gif" alt="loading..." />
            </div>
            
            <div id="xhr" style="min-width: 540px; min-height: 380px; padding: 8px; overflow: auto;"></div>

        </div>

    </form>

</div>
