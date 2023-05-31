<div class="leaf-center-content">

    

    <!-- LEFT SIDE NAV -->
    <!--{assign var=left_nav_content value="
        <aside id='sideBar' class='sidenav'>
        <button id='btn_uploadFile' class='usa-button' onclick='uploadFile();'>
            Upload File
        </button>
    </aside>
    "}-->
    <!--{include file="partial_layouts/left_side_nav.tpl" contentLeft="$left_nav_content"}-->
    
    <main class="main-content">
    
        <h2>File Manager</h2>

        <p>Note: File uploads are intended to be used for custom branding assets. Uploaded files have no access restrictions, and are public.</p>
        
        <div id="fileList"></div>

        <div class="leaf-row-space"></div>

    </main>

    <!-- RIGHT SIDE NAV -->
    <!--{assign var=right_nav_content value="
        <aside class='sidenav-right'></aside>
    "}-->
    <!--{include file="partial_layouts/right_side_nav.tpl" contentRight="$right_nav_content"}-->

</div>

<!--{include file="site_elements/generic_xhrDialog.tpl"}-->
<!--{include file="site_elements/generic_confirm_xhrDialog.tpl"}-->

<script type="text/javascript">
var CSRFToken = '<!--{$CSRFToken}-->';

function showFiles() {
    $.ajax({
        type: 'GET',
        url: '../api/system/files',
        success: function(res) {
            const files = [...res];
        	let output = '<table class="table">';
            output += `<tr style="background-color:#252f3e; color: white;">
                <th style="width:250px">File Name</th>
                <th style="width:100px">Action</th>
                <th style="width:200px">Context</th>
            </tr>`;
            for(let i in res) {
            	output += `<tr>
                    <td><a href="../files/${res[i]}">../files/${res[i]}</a></td>
                    <td><a href="#" onclick="deleteFile('${res[i]}')">Delete</a></td>
                    <td id="${res[i]}_context"></td>
                </tr>`;
            }
            output += '</table>';
            $('#fileList').html(output);
            getIndicatorContext();
        },
        error: function(err) {
            console.error(err?.responseText);
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
            url: '../api/system/files/delete?' +
                $.param({'CSRFToken': CSRFToken, 'file': file}),
            success: function() {
                showFiles();
                dialog_confirm.hide();
            },
            error: function(err) {
                console.log('an error occurred during file deletion', err)
            },
        });
    });
    dialog_confirm.show();
}

function isJSON(input = '') {
    try {
        JSON.parse(input);
    } catch (e) {
        return false;
    }
    return true;
}

function getIndicatorContext() {
    $.ajax({
        type: "GET",
        url: "../api/form/indicator/list/unabridged",
        success: (res) => {
            let fileContext = {};
            res.forEach(i => {
                const baseFormat = i.format.split('\n')[0].trim();
                if(isJSON(i.conditions)) {
                    const conditions = JSON.parse(i.conditions) || [];
                    console.log(i.indicatorID, baseFormat, conditions);
                } else {
                    console.log(i.indicatorID)
                }
            });
        },
        error: function(err) {
            console.error(err?.responseText);
        },
    });
}

var dialog, dialog_confirm;
$(function() {
    dialog = new dialogController('xhrDialog', 'xhr', 'loadIndicator', 'button_save', 'button_cancelchange');
    dialog_confirm = new dialogController('confirm_xhrDialog', 'confirm_xhr', 'confirm_loadIndicator', 'confirm_button_save', 'confirm_button_cancelchange');

    showFiles();
});

</script>
