<div id="xhrDialog" style="visibility: hidden; display: none; background-color: white; border-style: none solid solid; border-width: 0 1px 1px; border-color: #e0e0e0; padding: 4px">
<form id="record" enctype="multipart/form-data" action="javascript:void(0);">
    <div>
        <button type="button" id="button_cancelchange" class="buttonNorm" style="position: absolute; left: 10px" disabled><img src="dynicons/?img=process-stop.svg&amp;w=16" alt="" /> Cancel</button>
        <button type="button" id="button_save" class="buttonNorm" style="position: absolute; right: 10px" disabled><img src="dynicons/?img=media-floppy.svg&amp;w=16" alt="" /> Save Change</button>
        <div style="border-bottom: 2px solid black; line-height: 30px"><br /></div>
        <div id="loadIndicator" style="visibility: hidden; z-index: 9000; position: absolute; text-align: center; font-size: 24px; font-weight: bold; background-color: #f2f5f7; padding: 16px; height: 400px; width: 526px"><img src="images/largespinner.gif" alt="" /></div>
        <div id="xhr" style="min-width: 540px; min-height: 420px; padding: 8px; overflow: auto; font-size: 12px"></div>
    </div>
</form>
</div>
