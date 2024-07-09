<script src="../js/formGrid.js"></script>
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

        <p style="line-height:1.4;">Note: File uploads are intended to be used for custom branding assets. Uploaded files have no access restrictions, and are public.</p>
        
        <div id="fileList"></div>
        <div id="fileFormContext" style="margin-top: 1rem;">
            Loading Form Information... <img src="../images/largespinner.gif" alt="" />
        </div>

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
    let grid = new LeafFormGrid('fileList', true);
    grid.setRootURL('../');
    grid.enableToolbar();
    grid.hideIndex();

    $.ajax({
        type: 'GET',
        url: '../api/system/files?getLastModified=1',
        success: function(res) {
            grid.setData(Object.keys(res).map(key => {
                res[key].recordID = key; // formGrid expects there to be a recordID property that contains unique integers
                return res[key];
            }));
            grid.setDataBlob(res);
            
            grid.setHeaders([
                {name: 'Filename', indicatorID: 'file', editable: false, callback: function(data, blob) {
                    let filePath = `../files/${blob[data.recordID].file}`;
                    $('#'+data.cellContainerID).html(`<a href="${filePath}">${filePath}</a>`);
                }},
                {name: 'Last Modified', indicatorID: 'lastModified', editable: false, callback: function(data, blob) {
                    let modTime = new Date(blob[data.recordID].modifiedTime * 1000);
                    $('#'+data.cellContainerID).html(modTime.toLocaleDateString());
                }},
                {name: '', indicatorID: 'delete', editable: false, callback: function(data, blob) {
                    $('#'+data.cellContainerID).html(`<a href="#" onclick="deleteFile('${blob[data.recordID].file}')">Delete</a>`);
                }}
            ]);

            grid.renderBody();
        },
        error: function(err) {
            console.error(err?.responseText);
        }
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

function addIndicatorContext() {
    let fileContext = {};
    const mutateFileContext = (fileKey, formKey, indicator ) => {
        const label = indicator.description ?
            XSSHelpers.stripAllTags(indicator.description) : XSSHelpers.stripAllTags(indicator.name).slice(0, 30);
        const indInfo = {
            indicatorID: indicator.indicatorID,
            description: label
        };
        if(fileContext[fileKey] === undefined) {
            fileContext[fileKey] = {
                [formKey]: [ indInfo ]
            };
        } else {
            fileContext[fileKey][formKey] === undefined ?
                fileContext[fileKey][formKey] = [ indInfo ] : fileContext[fileKey][formKey].push(indInfo);
        }
        fileContext[fileKey][formKey] = fileContext[fileKey][formKey].sort((a, b) => b.indicatorID - a.indicatorID);
    }
    $.ajax({
        type: "GET",
        url: "../api/form/indicator/list/unabridged",
        success: (res) => {
            const enabledIndicators = res.filter(i => parseInt(i.isDisabled) === 0);
            enabledIndicators.forEach(i => {
                const baseFormat = i.format.split('\n')[0].toLowerCase().trim();
                const formKey = `${i.categoryName} (${i.categoryID})`;
                //current multiselect and dropdown format option loading
                if(baseFormat === 'dropdown' || baseFormat === 'multiselect') {
                    if(isJSON(i.conditions)) {
                        const conditions = JSON.parse(i.conditions) || [];
                        const crosswalkConditions = conditions.filter(
                            c => c.selectedOutcome.toLowerCase() === 'crosswalk'
                        );
                        crosswalkConditions.forEach(cond => {
                            mutateFileContext(cond.crosswalkFile, formKey, i);
                        });

                    } else {
                        console.log('unexpected conditions content', i.indicatorID, i.conditions)
                    }
                //grid format option loading
                } else if (baseFormat === 'grid') {
                    let gridJSON = (i.format.split('\n')[1] || '').trim();
                    if(isJSON(gridJSON)) {
                        gridJSON = JSON.parse(gridJSON) || [];
                        const file_dropdowns = gridJSON.filter(
                            gridInfo => gridInfo.type === "dropdown_file"
                        );
                        file_dropdowns.forEach(dd => {
                            mutateFileContext(dd.file, formKey, i);
                        });

                    } else {
                        console.log('unexpected grid JSON', i.indicatorID)
                    }
                }
            });
            if (Object.keys(fileContext).length > 0) {
                document.getElementById('fileFormContext').style.display = 'block';
                let output = `<p style="margin-top: 2rem; max-width:650px; line-height:1.4;">
                    The table below lists files used for loading form options.&nbsp; This includes those
                    added in the Form Editor with 'ifthen', or Dropdown From File grid format cell types.&nbsp; 
                    It does not include custom code.</p>`;

                output += `<table style="margin: 0; line-height:1.4" class="table">
                    <tr style="background-color:#252f3e;color:white;">
                        <th>File Name</th>
                        <th>Form Info</th>
                    </tr>`;
                for(let file in fileContext) {
                    output += `<tr><td>${file}</td><td>`
                    for(let form in fileContext[file]) {
                        const pl = fileContext[file][form].length > 1 ? 's' : '';
                        output += `<div><b>Form</b>: ${form}</div>`;
                        output += `<div><b>Question${pl}</b>:</div>`;
                        const indInfo = fileContext[file][form];
                        indInfo.forEach((ind, index) => {
                            output += `<div>${ind.description} (#${ind.indicatorID})</div>`;
                        });
                        output += '<br/>'
                    }
                    output = output.slice(0,-5); //rm last break
                    output += `</td></tr>`;
                }
                output += '</table>';
                $('#fileFormContext').html(output);
            } else {
                $('#fileFormContext').html('');
            }
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
    addIndicatorContext();
});

</script>
