<div id="confirm_xhrDialog" style="visibility: hidden; display: none">
    
    <form id="confirm_record" enctype="multipart/form-data" action="javascript:void(0);">
        
        <div>

            <div id="confirm_loadIndicator" style="visibility: hidden; position: absolute; text-align: center; background: white; padding: 16px; height: 100px; width: 360px">
                Loading... <img src="../images/largespinner.gif" alt="loading..." />
            </div>

            <div id="confirm_xhr" style="width: 400px; height: 120px; padding: 16px; overflow: auto"></div>

            <div class="leaf-float-left">
                <button class="usa-button usa-button--outline" id="confirm_button_cancelchange">No</button>
            </div>

            <div class="leaf-float-right">
                <button class="usa-button" id="confirm_button_save"><span id="confirm_saveBtnText">Yes</span></button>
            </div>
        
        </div>

    </form>

</div>