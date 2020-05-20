<div class="leaf-center-content">

    <h2>File Manager</h2>

    <p>Note: File uploads are intended to be used for custom branding assets. Uploaded files have no access restrictions, and are public.</p>
    
    <div id="sideBar" style="float: left; width: 150px">
        <button id="btn_uploadFile" class="usa-button" onclick="uploadFile();">
            <i class="fas fa-upload leaf-btn-icon"></i>Upload File
        </button>
    </div>

    <div class="leaf-row-space"></div>

    <div id="fileList" style="background-color: white; margin-left: 160px"></div>

    <div class="leaf-row-space"></div>

</div>

<!--{include file="site_elements/generic_xhrDialog.tpl"}-->
<!--{include file="site_elements/generic_confirm_xhrDialog.tpl"}-->

<script type="text/javascript">
var CSRFToken = '<!--{$CSRFToken}-->';

function showFiles() {
    $.ajax({
        type: 'GET',
        url: '../api/?a=system/files',
        success: function(res) {
        	var output = '<table class="table">';
            for(var i in res) {
            	output += '<tr><td><a href="../files/'+ res[i] +'">../files/'+ res[i] +'</a></td><td><a href="#" onclick="deleteFile(\''+ res[i] +'\')">Delete</a></td></tr>';
            }
            output += '</table>';
            $('#fileList').html(output);
        },
        cache: false
    });
}

function uploadFile() {
	window.location.href = './?a=uploadFile';
}

function deleteFile(file) {
    dialog_confirm.setTitle('Confirmation required');
    dialog_confirm.setContent('Are you sure you want to delete this file?');
    dialog_confirm.setSaveHandler(function() {
        $.ajax({
            type: 'DELETE',
            url: '../api/?a=system/files/_'+ file + '&CSRFToken=' + CSRFToken,
            success: function() {
                showFiles();
                dialog_confirm.hide();
            }
        });
    });
    dialog_confirm.show();
}


var dialog, dialog_confirm;
$(function() {
    dialog = new dialogController('xhrDialog', 'xhr', 'loadIndicator', 'button_save', 'button_cancelchange');
    dialog_confirm = new dialogController('confirm_xhrDialog', 'confirm_xhr', 'confirm_loadIndicator', 'confirm_button_save', 'confirm_button_cancelchange');

    showFiles();
});

</script>
