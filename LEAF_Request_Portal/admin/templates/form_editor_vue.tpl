<div class="leaf-width-100pct" id="vue-formeditor-app">
    <h2 style="margin: 1em 0.1em 0.75em 0.1em;" >Form Editor</h2>
    <div style="display:flex;">
        <mod-form-menu></mod-form-menu>
        <!-- CATEGORY BROWSER WITH CARDS / RESTORE FIELDS -->
        <template v-if="restoringFields===false">
        <div v-if="currCategoryID===null && appIsLoadingCategoryList === false" id="formEditor_content"
            style="width: 100%; margin: 0 auto;">
            <div id="forms" style="display:flex; flex-wrap:wrap">
                <category-card v-for="c in activeCategories" :category="c" :key="c.categoryID"></category-card>
            </div>
            <hr style="margin-top: 32px; border-top:1px solid #556;" aria-label="Not associated with a workflow" />
            <p>Not associated with a workflow:</p>
            <div id="forms_inactive" style="display:flex; flex-wrap:wrap">
                <category-card v-for="c in inactiveCategories" :category="c" :key="c.categoryID"></category-card>
            </div>
        </div>
        <!-- SPECIFIC CATEGORY / FORM CONTENT -->
        <div v-if="currCategoryID !== null && appIsLoadingCategoryList === false" 
            style="width: 100%; margin: 0 auto;">
            <form-content></form-content>
        </div>
        </template>

        <template v-if="restoringFields===true">
        <restore-fields></restore-fields>
        </template>
    </div>

    <!-- DIALOGS -->
    <leaf-form-dialog v-if="showFormDialog" :has-dev-console-access='<!--{$hasDevConsoleAccess}-->'>  
        <template #dialog-content-slot>
        <component v-if="dialogContentIsComponent" :is="dialogFormContent" :ref="dialogFormContent"></component>
        <div v-else v-html="dialogFormContent"></div>
        </template>
    </leaf-form-dialog>
</div>

<div id="LEAF_conditions_editor"></div><!-- vue IFTHEN app mount -->

<script>
//variables used within this scope, type, and approx. locations of def/redef (if applicable)
const CSRFToken = '<!--{$CSRFToken}-->';
const gridBodyElement = 'div#container_indicatorGrid > div';
let currCategoryID = '';            //string, def @ ~1762, 1774, 1818, 1864, 2055
let indicatorEditing = {}           //object, def @ ~1261
let gridJSON = [];                  //array of objects, def @ ~1267
let postRenderFormBrowser;          //func @ ~2104
let categories = {};                //object, def @ ~1853
let dialog, dialog_confirm, dialog_simple;   //dialogController instances, @ready
let portalAPI;                      //@ready
let columns = 0;                    //number, def @ ~1268

let vueData = {
    formID: 0,
    indicatorID: 0,
    updateIndicatorList: false
}
</script>

<script src="https://unpkg.com/vue@3"></script> <!-- DEV -->
<!--<script src="../../libs/js/vue3/vue.global.prod.js"></script>-->
<script src="../js/vue_conditions_editor/LEAF_conditions_editor.js"></script>
<script type="module" src="../../libs/js/LEAF/dialog_vue/LEAF_FormEditor_main.js" defer></script>
<link rel="stylesheet" href="../js/vue_conditions_editor/LEAF_conditions_editor.css" />
<link rel="stylesheet" href="../../libs/js/LEAF/dialog_vue/LEAF_FormEditor.css" />


<script>

/**
 * Purpose: Add Permissions to Form
 * @param categoryID
 */
function addPermission(categoryID) {
    let formTitle = categories[categoryID].categoryName == '' ? 'Untitled' : categories[categoryID].categoryName;
    dialog.setTitle('Edit Collaborators');
    dialog.setContent('Add collaborators to the <b>'+ formTitle +'</b> form:<div id="groups"></div>');
    dialog.indicateBusy();

    $.ajax({
        type: 'GET',
        url: '../api/?a=system/groups',
        success: function(res) {
            let buffer = '<select id="groupID">';
            for(let i in res) {
                buffer += '<option value="'+ res[i].groupID +'">'+ res[i].name +'</option>';
            }
            buffer += '</select>';
            $('#groups').html(buffer);
            dialog.indicateIdle();
        },
        cache: false
    });

    dialog.setSaveHandler(function() {
        $.ajax({
            type: 'POST',
            url: '../api/?a=formEditor/_'+ categoryID +'/privileges',
            data: {CSRFToken: '<!--{$CSRFToken}-->',
            	   groupID: $('#groupID').val(),
                   read: 1,
                   write: 1},
            success: function(res) {
            	dialog.hide();
                editPermissions();
            },
            cache: false
        });
    });

    //ie11 fix
    setTimeout(function () {
        dialog.show();
    }, 0);

}

/**
 * Purpose: Remove Permissions from Form
 * @param groupID
 */
function removePermission(groupID) {
    $.ajax({
        type: 'POST',
        url: '../api/?a=formEditor/_'+ currCategoryID +'/privileges',
        data: {CSRFToken: '<!--{$CSRFToken}-->',
        	   groupID: groupID,
        	   read: 0,
        	   write: 0},
        success: function(res) {
            editPermissions();
        }
    });
}

/**
 * Purpose: Edit existing Permissions
 */
function editPermissions() {
	let formTitle = categories[currCategoryID].categoryName == '' ? 'Untitled' : categories[currCategoryID].categoryName;

	dialog_simple.setTitle('Edit Collaborators - ' + formTitle);
	dialog_simple.setContent('<h2>Collaborators have access to fill out data fields at any time in the workflow.</h2><br />'
	                             + 'This is typically used to give groups access to fill out internal-use fields.<br />'
	                             + '<div id="formPrivs"></div>');
	dialog_simple.indicateBusy();

	$.ajax({
		type: 'GET',
		url: '../api/?a=formEditor/_'+ currCategoryID +'/privileges',
		success: function(res) {
			let buffer = '<ul>';
			for(let i in res) {
				buffer += '<li>' + res[i].name + ' [ <a href="#" tabindex="0" onkeypress="onKeyPressClick(event);" onclick="removePermission(\''+ res[i].groupID +'\');">Remove</a> ]</li>';
			}
			buffer += '</ul>';
			buffer += '<span tabindex="0" class="buttonNorm" onkeypress="onKeyPressClick(event)" onclick="addPermission(currCategoryID);" role="button">Add Group</span>';
			$('#formPrivs').html(buffer);
			dialog_simple.indicateIdle();
		},
		cache: false
	});
	//ie11 fix
	setTimeout(function () {
		dialog_simple.show();
	}, 0);

}

/**
 * Purpose: Remove specific Indicator Privileges
 * @param indicatorID
 * @param groupID
 */
function removeIndicatorPrivilege(indicatorID, groupID) {
    portalAPI.FormEditor.removeIndicatorPrivilege(
        indicatorID,
        groupID,
        function (success) {
            editIndicatorPrivileges(indicatorID);
        },
        function (error) {
            editIndicatorPrivileges(indicatorID);
            console.log(error);
        }
    );
}

/**
 * Purpose: Add specific Indicator Privileges
 * @param indicatorID
 */
function addIndicatorPrivilege(indicatorID, indicatorName = '') {
    dialog.setTitle('Edit Privileges');
    dialog.setContent('Add privileges to the <b>'+ indicatorName +'</b> form:<div id="groups"></div>');
    dialog.indicateBusy();

    $.ajax({
        type: 'GET',
        url: '../api/?a=system/groups',
        success: function(res) {
            let buffer = '<select id="groupID">';
            buffer += '<option value="1">System Administrators</option>';
            for(let i in res) {
                buffer += '<option value="'+ res[i].groupID +'">'+ res[i].name +'</option>';
            }
            buffer += '</select>';
            $('#groups').html(buffer);
            dialog.indicateIdle();
        },
        cache: false
    });

    dialog.setSaveHandler(function() {
        portalAPI.FormEditor.setIndicatorPrivileges(
            indicatorID,
            [$('#groupID').val()],
            function(results) {
                dialog.hide();
                editIndicatorPrivileges(indicatorID);
            },
            function (error) {
                console.log('an error has occurred: ', error);
                dialog.hide();
                editIndicatorPrivileges(indicatorID);
            }
        );
    });

    dialog.show();
}


/**
 * Purpose: Edit exisitng Indicator Privileges
 * @param indicatorID
 */
function editIndicatorPrivileges(indicatorID) {
    dialog_simple.setContent('<h2>Special access restrictions for this field</h2>'
                            + '<p>These restrictions will limit view access to the request initiator and members of any groups you specify.</p>'
                            + '<p>Additionally, these restrictions will only allow the groups specified below to apply search filters for this field.</p>'
                            + 'All others will see "[protected data]".<br /><div id="indicatorPrivs"></div>');

    dialog_simple.indicateBusy();

    portalAPI.FormEditor.getIndicator(
        indicatorID,
        function(indicator) {
            const indicatorName= indicator[indicatorID]?.name;

            dialog_simple.setTitle('Edit Indicator Read Privileges - ' + indicatorID);

            portalAPI.FormEditor.getIndicatorPrivileges(indicatorID,
                function (groups) {
                    let buffer = '<ul>';
                    let count = 0;
                    for (let group in groups) {
                        if (groups[group].id !== undefined) {
                            buffer += '<li>' + groups[group].name + ' [ <a href="#" tabindex="0" onkeypress="onKeyPressClick(event);" onclick="removeIndicatorPrivilege(' + indicatorID + ',' + groups[group].id + ');">Remove</a> ]</li>';
                            count++;
                        }
                    }
                    buffer += '</ul>';
                    buffer += `<span tabindex="0" class="buttonNorm" onkeypress="onKeyPressClick(event)" onclick="addIndicatorPrivilege(${indicatorID},'${indicatorName}');">Add Group</span>`;
                    let statusMessage = "Special access restrictions are not enabled. Normal access rules apply.";
                    if(count > 0) {
                        statusMessage = "Special access restrictions are enabled!";
                    }
                    buffer += '<p>'+ statusMessage +'</p>';
                    $('#indicatorPrivs').html(buffer);
                    dialog_simple.indicateIdle();
                    dialog_simple.show();
                },
                function (error) {
                    $('#indicatorPrivs').html("There was an error retrieving the Indicator Privileges. Please try again.");
                    console.log(error);
                }
            );
        },
        function(err) {

        }
    );
}

//TODO: GRID STUFF
/**
 * Purpose: Generates Unique ID to track columns to update user input with grid format
 * @returns {string}
 */
function makeColumnID(){
    return "col_" + (((1+Math.random())*0x10000)|0).toString(16).substring(1);
}
/**
 * Purpose: Update Input Name for grid formats
 */
function updateNames(){
    $(gridBodyElement).children('div').each(function(i) {
        if (gridJSON[i] === undefined) {
            gridJSON.push(new Object);
        }
        gridJSON[i].name = $(this).children('input').val();
        gridJSON[i].id = gridJSON[i].id === undefined ? makeColumnID() : gridJSON[i].id;
    });
}
/**
 * Purpose: Make Grid for Input Option
 * @param columns
 */
function makeGrid(columns) {
    $(gridBodyElement).html('');
    if(columns === 0){
        gridJSON = [];
        columns = 1;
    }
    for (let i = 0; i < columns; i++) {
        if(gridJSON[i] === undefined){
            gridJSON.push(new Object());
        }
        let name = gridJSON[i].name === undefined ? 'No title' : gridJSON[i].name;
        let id = gridJSON[i].id === undefined ? makeColumnID() : gridJSON[i].id;
        $(gridBodyElement).append(
            '<div tabindex="0" id="' + id + '" class="cell"><img role="button" tabindex="0" onkeydown="onKeyPressClick(event);" onclick="moveLeft(event)" src="../../libs/dynicons/?img=go-previous.svg&w=16" title="Move column left" alt="Move column left" style="cursor: pointer" />' +
            '<img role="button" tabindex="0" onkeydown="onKeyPressClick(event);" onclick="moveRight(event)" src="../../libs/dynicons/?img=go-next.svg&w=16" title="Move column right" alt="Move column right" style="cursor: pointer" /></br>' +
            '<span class="columnNumber">Column #' + (i + 1) + ': </span><img role="button" tabindex="0" onkeydown="onKeyPressClick(event);" onclick="deleteColumn(event)" src="../../libs/dynicons/?img=process-stop.svg&w=16" title="Delete column" alt="Delete column" style="cursor: pointer; vertical-align: middle;" />' +
            '</br>&nbsp;<input type="text" value="' + name + '" onchange="updateNames();"></input></br>&nbsp;</br>Type:<select onchange="toggleDropDown(this.value, this);">' +
            '<option value="text">Single line input</option><option value="date">Date</option><option value="dropdown">Drop Down</option><option value="textarea">Multi-line text</option></select>'
        );
        if(columns === 1){
            rightArrows($(gridBodyElement + ' > div:last'), false);
            leftArrows($(gridBodyElement + ' > div:last'), false);
        } else {
            switch (i) {
                case 0:
                    leftArrows($(gridBodyElement + ' > div:last'), false);
                    break;
                case columns - 1:
                    rightArrows($(gridBodyElement + ' > div:last'), false);
                    break;
                default:
                    break;
            }
        }
        if(gridJSON[i].type !== undefined){
            $(gridBodyElement + '> div:eq(' + i + ') > select option[value="' + gridJSON[i].type + '"]').attr('selected', 'selected');
            if(gridJSON[i].type.toString() === 'dropdown'){
                if(gridJSON[i].options !== ""){
                    var options = gridJSON[i].options.join("\n").toString();
                } else {
                    var options = "";
                }
                $(gridBodyElement + ' > div:eq(' + i + ')').css('padding-bottom', '11px');
                if($(gridBodyElement + ' > div:eq(' + i + ') > span.dropdown').length === 0){
                    $(gridBodyElement + ' > div:eq(' + i + ')').append('<span class="dropdown"><div>One option per line</div><textarea aria-label="Dropdown options, one option per line" style="width: 153px; resize: none;"value="">' + options + '</textarea></span>');
                }
            }
        }
    }
}
/**
 * Purpose: Dropdown for Grid Options
 * @param type
 * @param cell
 */
function toggleDropDown(type, cell){
    if(type === 'dropdown'){
        $(cell).parent().append('<span class="dropdown"><div>One option per line</div><textarea aria-label="Dropdown options, one option per line" value="" style="width: 153px; resize:none"></textarea></span>');
        $('#tableStatus').attr('aria-label', 'Make drop options in the space below, one option per line.');
    } else {
        $(cell).parent().find('span.dropdown').remove();
        $('#tableStatus').attr('aria-label', 'Dropdown options box removed');
    }
}
/**
 * Purpose: Left arrow for Grid
 * @param cell
 * @param toggle
 */
function leftArrows(cell, toggle){
    if(toggle){
        cell.find('[title="Move column left"]').css('display', 'inline');
    } else {
        cell.find('[title="Move column left"]').css('display', 'none');
    }
}
/**
 * Purpose: Right arrow for Grid
 * @param cell
 * @param toggle
 */
function rightArrows(cell, toggle){
    if(toggle){
        cell.find('[title="Move column right"]').css('display', 'inline');
    } else {
        cell.find('[title="Move column right"]').css('display', 'none');
    }
}
/**
 * Purpose: Add Cells for Grid Input Option
 */
function addCells(){
    columns = columns + 1;
    rightArrows($(gridBodyElement + ' > div:last'), true);
    $(gridBodyElement).append(
        '<div tabindex="0" id="' + makeColumnID() + '" class="cell"><img role="button" tabindex="0" onkeydown="onKeyPressClick(event);" onclick="moveLeft(event)" src="../../libs/dynicons/?img=go-previous.svg&w=16" title="Move column left" alt="Move column left" style="cursor: pointer; display: inline" />' +
        '<img role="button" tabindex="0" onkeydown="onKeyPressClick(event);" onclick="moveRight(event)" src="../../libs/dynicons/?img=go-next.svg&w=16" title="Move column right" alt="Move column right" style="cursor: pointer; display: none" /></br>' +
        '<span class="columnNumber"></span><img role="button" tabindex="0" onkeydown="onKeyPressClick(event);" onclick="deleteColumn(event)" src="../../libs/dynicons/?img=process-stop.svg&w=16" title="Delete column" alt="Delete column" style="cursor: pointer; vertical-align: middle;" />' +
        '</br>&nbsp;<input type="text" value="No title" onchange="updateNames();"></input></br>&nbsp;</br>Type:<select onchange="toggleDropDown(this.value, this);">' +
        '<option value="text">Single line input</option><option value="date">Date</option><option value="dropdown">Drop Down</option><option value="textarea">Multi-line text</option></select>'
    );
    $('#tableStatus').attr('aria-label', 'Column added, ' + $(gridBodyElement).children().length + ' total.');
    $(gridBodyElement + ' > div:last').focus();
    updateColumnNumbers();
}
/**
 * Purpose: Update the number of columns
 */
function updateColumnNumbers(){
    $(gridBodyElement).find('span.columnNumber').each(function(index) {
        $(this).html('Column #' + (index + 1) +':&nbsp;');
    });
}
/**
 * Purpose: Delete a column from Grid
 * @param event
 */
function deleteColumn(event){
    let column = $(event.target).closest('div');
    let tbody = $(event.target).closest('div').parent('div');
    let columnDeleted = parseInt($(column).index()) + 1;
    let focus;
    switch(tbody.find('div').length){
        case 1:
            alert('Cannot remove initial column.');
            break;
        case 2:
            column.remove();
            focus = $('div.cell:first');
            rightArrows(tbody.find('div'), false);
            leftArrows(tbody.find('div'), false);
            break;
        default:
            focus = column.next().find('[title="Delete column"]');
            if(column.find('[title="Move column right"]').css('display') === 'none'){
                rightArrows(column.prev(), false);
                leftArrows(column.prev(), true);
                focus = column.prev().find('[title="Delete column"]');
            }
            if(column.find('[title="Move column left"]').css('display') === 'none'){
                leftArrows(column.next(), false);
                rightArrows(column.next(), true);
            }
            column.remove();
            break;
    }
    columns = columns - 1;
    $('#tableStatus').attr('aria-label', 'Row ' + columnDeleted + ' removed, ' + $(tbody).children().length + ' total.');

    //ie11 fix
    setTimeout(function () {
        focus.focus();
    }, 0);
    updateColumnNumbers();
}
/**
 * Purpose: Move Column Right
 * @param event
 */
function moveRight(event){
    let column = $(event.target).closest('div');
    let nextColumnLast = column.next().find('[title="Move column right"]').css('display') === 'none';
    let first = column.find('[title="Move column left"]').css('display') === 'none';
    leftArrows(column, true);
    if(first){
        leftArrows(column.next(), false);
    }
    if(nextColumnLast){
        rightArrows(column, false);
        rightArrows(column.next(), true);
    }
    column.insertAfter(column.next());
    if(nextColumnLast){
        column.find('[title="Move column left"]').focus();
    } else {
        column.find('[title="Move column right"]').focus();
    }
    $('#tableStatus').attr('aria-label', 'Moved right to column ' + (parseInt($(column).index()) + 1) + ' of ' + column.parent().children().length);
    updateColumnNumbers();
}
/**
 * Purpose: Move Column Left
 * @param event
 */
function moveLeft(event){
    let column = $(event.target).closest('div.cell');
    let nextColumnFirst = column.prev().find('[title="Move column left"]').css('display') === 'none';
    let last = column.find('[title="Move column right"]').css('display') === 'none';
    rightArrows(column, true);
    if(last){
        rightArrows(column.prev(), false);
    }
    if(nextColumnFirst){
        leftArrows(column, false);
        leftArrows(column.prev(), true);
    }
    column.insertBefore(column.prev());
    if(nextColumnFirst){
        column.find('[title="Move column right"]').focus();
    } else {
        column.find('[title="Move column left"]').focus();
    }
    $('#tableStatus').attr('aria-label', 'Moved left to column ' + (parseInt($(column).index()) + 1) + ' of ' + column.parent().children().length);
    updateColumnNumbers();
}
/**
 * Purpose: Create Array for Dropdown Options
 * @param dropDownOptions
 * @returns {[]|*}
 */
function gridDropdown(dropDownOptions){
    if(dropDownOptions == null || dropDownOptions.length === 0){
        return dropDownOptions;
    }
    let uniqueNames = dropDownOptions.split("\n");
    let returnArray = [];
    uniqueNames = uniqueNames.filter(function(elem, index, self) {
        return index == self.indexOf(elem);
    });

    $.each(uniqueNames, function(i, el){
        if(el === "no") {
            uniqueNames[i] = "No";
        }
        returnArray.push(uniqueNames[i]);
    });

    return returnArray;
}
/**
 * Purpose: Create Array for Multi-Select Options
 * @param multiSelectOptions
 * @returns {[]|*}
 */
function gridMultiselect(multiSelectOptions){
    if(multiSelectOptions == null || multiSelectOptions.length === 0){
        return multiSelectOptions;
    }
    let uniqueNames = multiSelectOptions.split("\n");
    let returnArray = [];
    uniqueNames = uniqueNames.filter(function(elem, index, self) {
        return index == self.indexOf(elem);
    });

    $.each(uniqueNames, function(i, el){
        if(el === "no") {
            uniqueNames[i] = "No";
        }
        returnArray.push(uniqueNames[i]);
    });

    return returnArray;
}


/**
 * Purpose: Merge Stapled Forms
 * @param categoryID
 */
function mergeForm(categoryID) {
    dialog.setTitle('Staple other form');
    dialog.setContent('Select a form to staple: <div id="formOptions"></div>');
    dialog.indicateBusy();

    $.ajax({
        type: 'GET',
        url: '../api/formStack/categoryList/all',
        success: function(res) {
            let buffer = '<select id="stapledCategoryID">';
            for(let i in res) {
            	if(res[i].workflowID == 0
            		&& res[i].categoryID != categoryID
            		&& res[i].parentID == '') {
            		buffer += '<option value="'+ res[i].categoryID +'">'+ res[i].categoryName +'</option>';
            	}
            }
            buffer += '</select>';
            $('#formOptions').html(buffer);
            dialog.indicateIdle();
        },
        cache: false
    });

    dialog.setSaveHandler(function() {
        $.ajax({
            type: 'POST',
            url: '../api/formEditor/_'+ categoryID +'/stapled',
            data: {CSRFToken: '<!--{$CSRFToken}-->',
                   stapledCategoryID: $('#stapledCategoryID').val()},
            success: function(res) {
            	if(res == 1) {
                    dialog.hide();
                    mergeFormDialog(categoryID);
            	}
            	else {
            		alert(res);
            	}
            },
            cache: false
        });
    });

    dialog.show();

}
/**
 * Purpose: Remove Stapled Form
 * @param categoryID
 * @param stapledCategoryID
 */
function unmergeForm(categoryID, stapledCategoryID) {
    $.ajax({
        type: 'DELETE',
        url: '../api/formEditor/_'+ categoryID +'/stapled/_'+ stapledCategoryID + '&CSRFToken=<!--{$CSRFToken}-->',
        success: function() {
        	mergeFormDialog(categoryID);
        }
    });
}
/**
 * Purpose: Merge another Form Dialog Box
 * @param categoryID
 */
function mergeFormDialog(categoryID) {
    dialog_simple.setTitle('Staple other form');
    dialog_simple.setContent('Stapled forms will show up on the same page as the primary form.<div id="mergedForms"></div>');
    dialog_simple.indicateBusy();

    $.ajax({
        type: 'GET',
        url: '../api/?a=formEditor/_'+ categoryID +'/stapled',
        success: function(res) {
            let buffer = '<ul>';
            for(let i in res) {
                buffer += '<li>' + res[i].categoryName + ' [ <a href="#" onkeypress="onKeyPressClick(event)" onclick="unmergeForm(\''+ categoryID +'\', \''+ res[i].stapledCategoryID +'\');">Remove</a> ]</li>';
            }
            buffer += '</ul>';
            buffer += '<span class="buttonNorm" onkeypress="onKeyPressClick(event)" onclick="mergeForm(\''+ categoryID +'\');" tabindex="0" role="button">Select a form to merge</span>';
            $('#mergedForms').html(buffer);
            dialog_simple.indicateIdle();
        },
        cache: false
    });
		//ie11 fix
		setTimeout(function () {
				dialog_simple.show();
		}, 0);

}


/**
 * Purpose: Export Form
 * @param categoryID
 */
function exportForm(categoryID) {
	let packet = {};
	packet.form = {};
	packet.subforms = {};

	let defer = $.Deferred();
	let promise = defer.promise();
	promise = promise.then(function() {
		return $.ajax({
	        type: 'GET',
	        url: '../api/?a=form/_' + categoryID + '/export',
	        success: function(res) {
	            packet.form = res;
	            packet.categoryID = categoryID;
	        }
	    });
	});

    promise = promise.then(function() {
        return $.ajax({
            type: 'GET',
            url: '../api/?a=form/_' + categoryID + '/workflow',
            success: function(res) {
                packet.workflowID = res[0].workflowID;
            }
        });
    });

	for(let i in categories) {
        if(categories[i].parentID == categoryID) {
        	promise = promise.then(
            	function(subCategoryID) {
                    return $.ajax({
                        type: 'GET',
                        url: '../api/?a=form/_' + subCategoryID + '/export',
                        success: function(res) {
                        	packet.subforms[subCategoryID] = {};
                        	packet.subforms[subCategoryID].name = categories[subCategoryID].categoryName;
                        	packet.subforms[subCategoryID].description = categories[subCategoryID].categoryDescription;
                            packet.subforms[subCategoryID].packet = res;
                        }
                    });
                }(categories[i].categoryID)
            );
        }
	}
	defer.resolve();

	promise.done(function() {
		let outPacket = {};
		outPacket.version = 1;
		outPacket.name = categories[categoryID].categoryName + ' (Copy)';
		outPacket.description = categories[categoryID].categoryDescription;
		outPacket.packet = packet;

		let outBlob = new Blob([JSON.stringify(outPacket).replace(/[^ -~]/g,'')], {type : 'text/plain'}); // Regex replace needed to workaround IE11 encoding issue
		saveAs(outBlob, 'LEAF_FormPacket_'+ categoryID +'.txt');
	});
}




/**
 * Purpose: Delete Form
 */
function deleteForm() {
	let formTitle = categories[currCategoryID].categoryName == '' ? 'Untitled' : categories[currCategoryID].categoryName;
	dialog_confirm.setTitle('Delete Form?');
	dialog_confirm.setContent('Are you sure you want to delete the <b>'+ formTitle +'</b> form?');

	dialog_confirm.setSaveHandler(function() {
		$.ajax({
			type: 'DELETE',
			url: '../api/?a=formStack/_' + currCategoryID + '&CSRFToken=<!--{$CSRFToken}-->',
			success: function(res) {
			    if(res != true) {
			        alert(res);
			    }
		        window.location.reload();
			}
		});
	});

	dialog_confirm.show();

}




/**
 * Purpose: Show Secure Form Info
 * @param res
 */
function renderSecureFormsInfo(res) {
    $('#formEditor_content').prepend('<div id="secure_forms_info" style="padding: 8px; background-color: red; display:none; margin-bottom:1em;" ></div>');
    $('#secure_forms_info').append('<span id="secureStatus" style="font-size: 120%; padding: 4px; color: white; font-weight: bold;">LEAF-Secure Certified</span> ');
    $('#secure_forms_info').append('<a id="secureBtn" class="buttonNorm">View Details</a>');

    if(res['leafSecure'] >= 1) { // Certified
        $.when(fetchIndicators(), fetchLEAFSRequests(true)).then(function(indicators, leafSRequests) {
            let mostRecentID = null;
            let newIndicator = false;
            let mostRecentDate = 0;

            for(let i in leafSRequests) {
                if(leafSRequests[i].recordResolutionData.lastStatus === 'Approved'
                    && leafSRequests[i].recordResolutionData.fulfillmentTime > mostRecentDate) {
                    mostRecentDate = leafSRequests[i].recordResolutionData.fulfillmentTime;
                    mostRecentID = i;
                }
            }
            $('#secureBtn').attr('href', '../index.php?a=printview&recordID='+ mostRecentID);
            let mostRecentTimestamp = new Date(parseInt(mostRecentDate)*1000); // converts epoch secs to ms
            // check for new indicators since certification
            for(let i in indicators) {
                if(new Date(indicators[i].timeAdded).getTime() > mostRecentTimestamp.getTime()) {
                    newIndicator = true;
                    break;
                }
            }
            // if newIndicator found, look for existing leaf-s request and assign proper next step
            if (newIndicator) {
                fetchLEAFSRequests(false).then(function(unresolvedLeafSRequests) {
                    if (unresolvedLeafSRequests.length == 0) { // if no new request, create one
                        $('#secureStatus').text('Forms have been modified.');
                        $('#secureBtn').text('Please Recertify Your Site');
                        $('#secureBtn').attr('href', '../report.php?a=LEAF_start_leaf_secure_certification');
                    } else {
                        let recordID = unresolvedLeafSRequests[Object.keys(unresolvedLeafSRequests)[0]].recordID;
                        $('#secureStatus').text('Re-certification in progress.');
                        $('#secureBtn').text('Check Certification Progress');
                        $('#secureBtn').attr('href', '../index.php?a=printview&recordID='+ recordID);
                    }
                    $('#secure_forms_info').show();
                });
            }
        });
    }
}
/**
 * Purpose: Check for Secure Form Certifcation
 * @param searchResolved
 * @returns { *|jQuery}
 */
function fetchLEAFSRequests(searchResolved) {
    let deferred = $.Deferred();
    let query = new LeafFormQuery();
    query.setRootURL('../');
    query.addTerm('categoryID', '=', 'leaf_secure');

    if (searchResolved) {
        query.addTerm('stepID', '=', 'resolved');
        query.join('recordResolutionData');
    } else {
        query.addTerm('stepID', '!=', 'resolved');
    }
    query.onSuccess(function(data) {
        deferred.resolve(data);
    });
    query.execute();
    return deferred.promise();
}
/**
 * Purpose: Get all Indicators on Form
 * @returns { *|jQuery}
 */
function fetchIndicators() {
    let deferred = $.Deferred();
    $.ajax({
        type: 'GET',
        url: '../api/form/indicator/list',
        cache: false,
        success: function(resp) {
            deferred.resolve(resp);
        }
    });
    return deferred.promise();
}
/**
 * Purpose: Get Form Secure Information
 */
function fetchFormSecureInfo() {
    $.ajax({
        type: 'GET',
        url: '../api/system/settings',
        cache: false
    })
    .then(function(res) {
        renderSecureFormsInfo(res)
    });
}








$(function() {
    portalAPI = LEAFRequestPortalAPI();
    portalAPI.setBaseURL('../api/');
    portalAPI.setCSRFToken('<!--{$CSRFToken}-->');

    //showFormBrowser();
    fetchFormSecureInfo();

    <!--{if $form != ''}-->
    //postRenderFormBrowser = function() { 
    //    selectForm('<!--{$form}-->');
   //};
    <!--{/if}-->

    <!--{if $referFormLibraryID != ''}-->
    //postRenderFormBrowser = function() { 
    //    $('.formLibraryID_<!--{$referFormLibraryID}-->')
    //    .animate({'background-color': 'yellow'}, 1000)
    //    .animate({'background-color': 'white'}, 1000)
    //    .animate({'background-color': 'yellow'}, 1000);
    //};
    <!--{/if}-->
});

</script>