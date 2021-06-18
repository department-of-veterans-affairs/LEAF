<style>
/* 3 column grid */
.group:after,.section{clear:both}.section{padding:0;margin:0}.col{display:block;float:left;margin:1% 0 1% 1.6%}.col:first-child{margin-left:0}.group:after,.group:before{content:"";display:table}.group{zoom:1}.span_3_of_3{width:100%}.span_2_of_3{width:66.13%}.span_1_of_3{width:32.26%}@media only screen and (max-width:480px){.col{margin:1% 0}.span_1_of_3,.span_2_of_3,.span_3_of_3{width:100%}}
</style>

<div id="step_1" style="<!--{if $query != '' && $indicators != ''}-->display: none; <!--{/if}-->width: 70%; background-color: white; border: 1px solid black; margin: auto; padding: 0px">
    <div style="background-color: #003a6b; color: white; padding: 4px; font-size: 22px; font-weight: bold">
        Step 1: Develop search filter
    </div>
    <div style="padding: 8px">
        <div id="searchContainer"></div>
    </div>
</div>

<div id="step_2" style="display: none; width: 95%; background-color: white; border: 1px solid black; margin: auto; padding: 0px">
    <div style="background-color: #0059a4; color: white; padding: 4px; font-size: 22px; font-weight: bold">
        Step 2: Select Data Columns
    </div>
    <div style="padding: 8px">
        <div id="indicatorList" class="section group" style="padding: 8px">Loading...</div>
        <br style="clear: both" />
        <button id="generateReport" class="buttonNorm" style="position: fixed; bottom: 14px; margin: auto; left: 0; right: 0; font-size: 140%; height: 52px; padding-top: 8px; padding-bottom: 4px; width: 70%; margin: auto; text-align: center; box-shadow: 0 0 20px black">Generate Report <img src="../libs/dynicons/?img=x-office-spreadsheet-template.svg&w=32" alt="generate report" /></button>
    </div>
</div>

<div id="saveLinkContainer" style="display: none">
    <div id="reportTitleDisplay" style="font-size: 200%"></div>
    <input id="reportTitle" type="text" aria-label="Text" style="font-size: 200%; width: 50%" placeholder="Untitled Report" />
</div>
<div id="results" style="display: none">Loading...</div>

<!--{include file="site_elements/generic_dialog.tpl"}-->
<!--{include file="site_elements/generic_xhrDialog.tpl"}-->
<script>
var CSRFToken = '<!--{$CSRFToken}-->';

function loadWorkflow(recordID, prefixID) {
    dialog_message.setTitle('Apply Action to #' + recordID);

    currRecordID = recordID;
    dialog_message.setContent('<div id="workflowcontent"></div><div id="currItem"></div>');
    workflow = new LeafWorkflow('workflowcontent', '<!--{$CSRFToken}-->');
    workflow.setActionSuccessCallback(function() {
        dialog_message.hide();
        $('#' + prefixID + 'tbody_tr' + recordID).fadeOut(1300);
    });
    workflow.getWorkflow(recordID);
    dialog_message.show();
}

function prepareEmail(link) {
	mailtoHref = 'mailto:?subject=Report%20for&body=Report%20Link:%20'+ encodeURIComponent(link) +'%0A%0A';
    $('body').append($('<iframe id="ie9workaround" style="display:none;" src="' + mailtoHref + '"/>'));
}

var delim = '<span class="nodisplay">^;</span>'; // invisible delimiters to help Excel users
var delimLF = "\r\n";
var tDepHeader = [];
var tStepHeader = [];
function addHeader(column) {
    var today = new Date();
	switch(column) {
	    case 'title':
	    	headers.push({name: 'Title', indicatorID: 'title', callback: function(data, blob) {
                            $('#'+data.cellContainerID).html(blob[data.recordID].title);
                            $('#'+data.cellContainerID).on('click', function() {
                                window.open('index.php?a=printview&recordID='+data.recordID, 'LEAF', 'width=800,resizable=yes,scrollbars=yes,menubar=yes');
                            });
                         }});
		    break;
	    case 'service':
            headers.push({name: 'Service', indicatorID: 'service', editable: false, callback: function(data, blob) {
                             $('#'+data.cellContainerID).html(blob[data.recordID].service);
                         }});
            break;
	    case 'type':
	    	leafSearch.getLeafFormQuery().join('categoryName');
            headers.push({name: 'Type', indicatorID: 'type', editable: false, callback: function(data, blob) {
                             var types = '';
                             for(var i in blob[data.recordID].categoryNames) {
                                 types += blob[data.recordID].categoryNames[i] + ' | ';
                             }
                             types = types.substr(0, types.length - 3);
                             $('#'+data.cellContainerID).html(types);
                         }});
            break;
	    case 'status':
	    	leafSearch.getLeafFormQuery().join('status');
            headers.push({name: 'Current Status', indicatorID: 'status', editable: false, callback: function(data, blob) {
                             var status = blob[data.recordID].stepTitle == null ? blob[data.recordID].lastStatus : 'Pending ' + blob[data.recordID].stepTitle;
                             status = status == 'null' ? 'Not Submitted' : status;
                             if(blob[data.recordID].deleted > 0) {
                            	 status += ', Cancelled';
                             }
                             $('#'+data.cellContainerID).html(status);
                         }});
            break;
        case 'initiator':
        	leafSearch.getLeafFormQuery().join('initiatorName');
            headers.push({name: 'Initiator', indicatorID: 'initiator', editable: false, callback: function(data, blob) {
            	$('#'+data.cellContainerID).html(blob[data.recordID].lastName + ', ' + blob[data.recordID].firstName);
            }});
            break;
        case 'dateCancelled':
            leafSearch.getLeafFormQuery().join('action_history');
            headers.push({name: 'Date Cancelled', indicatorID: 'dateCancelled', editable: false, callback: function(data, blob) {
                if(blob[data.recordID].deleted > 0) {
                    var date = new Date(blob[data.recordID].deleted * 1000);
                    $('#'+data.cellContainerID).html(date.toLocaleDateString().replace(/[^ -~]/g,'')); // IE11 encoding workaround: need regex replacement
                }
            }});
            headers.push({name: 'Cancelled By', indicatorID: 'cancelledBy', editable: false, callback: function(data, blob) {
                if(blob[data.recordID].action_history != undefined) {
                    var cancelData = blob[data.recordID].action_history.pop();
                    if(cancelData.actionType == 'deleted') {
                        $('#'+data.cellContainerID).html(cancelData.approverName);
                    }
                }
            }});
            break;
        case 'dateInitiated':
            headers.push({name: 'Date Initiated', indicatorID: 'dateInitiated', editable: false, callback: function(data, blob) {
                var date = new Date(blob[data.recordID].date * 1000);
                $('#'+data.cellContainerID).html(date.toLocaleDateString().replace(/[^ -~]/g,'')); // IE11 encoding workaround: need regex replacement
            }});
            break;
        case 'dateResolved':
            leafSearch.getLeafFormQuery().join('recordResolutionData');
            headers.push({name: 'Date Resolved', indicatorID: 'dateResolved', editable: false, callback: function(data, blob) {
                if(blob[data.recordID].recordResolutionData != undefined) {
                    var date = new Date(blob[data.recordID].recordResolutionData.fulfillmentTime * 1000);
                    $('#'+data.cellContainerID).html(date.toLocaleDateString().replace(/[^ -~]/g,'')); // IE11 encoding workaround: need regex replacement
                }
            }});
            headers.push({name: 'Action Taken', indicatorID: 'typeResolved', editable: false, callback: function(data, blob) {
                if(blob[data.recordID].recordResolutionData != undefined) {
                    $('#'+data.cellContainerID).html(blob[data.recordID].recordResolutionData.lastStatus);
                }
            }});
        break;
        case 'resolvedBy':
            leafSearch.getLeafFormQuery().join('recordResolutionBy');
            headers.push({name: 'Resolved By', indicatorID: 'resolvedBy', editable: false, callback: function(data, blob) {
                if(blob[data.recordID].recordResolutionBy != undefined) {
                    $('#'+data.cellContainerID).html(blob[data.recordID].recordResolutionBy.resolvedBy);
                }
            }});
        break;
        case 'actionButton':
        	headers.unshift({name: 'Action', indicatorID: 'actionButton', editable: false, callback: function(data, blob) {
                $('#'+data.cellContainerID).html('<div class="buttonNorm">Take Action</div>');
                $('#'+data.cellContainerID).on('click', function() {
                    loadWorkflow(data.recordID, grid.getPrefixID());
                });
        	}});
        	break;
        case 'action_history':
            leafSearch.getLeafFormQuery().join('action_history');
            headers.push({name: 'Comment History', indicatorID: 'action_history', editable: false, callback: function(data, blob) {
                             var buffer = '<table style="min-width: 300px">';
                             var now = new Date();

                             for(var i in blob[data.recordID].action_history) {
                            	 var date = new Date(blob[data.recordID].action_history[i]['time'] * 1000);
                                 var formattedDate = date.toLocaleDateString();
                                 if(blob[data.recordID].action_history[i]['comment'] != '') {
                                     buffer += '<tr><td style="border-right: 1px solid black; padding-right: 4px; text-align: right">'
                                        + formattedDate + delim + '</td><td style="padding-left: 4px">' + blob[data.recordID].action_history[i]['comment'] + '.</td>'
                                        + delimLF + '</tr>';
                                 }
                             }
                             buffer += '</table>';
                             $('#'+data.cellContainerID).html(buffer);
                         }});
            break;
        case 'approval_history':
            leafSearch.getLeafFormQuery().join('action_history');
            headers.push({name: 'Approval History', indicatorID: 'approval_history', editable: false, callback: function(data, blob) {
                             var buffer = '<table class="table" style="min-width: 300px">';
                             var now = new Date();

                             for(var i in blob[data.recordID].action_history) {
                                 var date = new Date(blob[data.recordID].action_history[i]['time'] * 1000);
                                 var formattedDate = date.toLocaleDateString();
                                 var actionDescription = blob[data.recordID].action_history[i]['description'] != null ? blob[data.recordID].action_history[i]['description'] : '';
                                 buffer += '<tr><td>'
                                       + formattedDate + delim + '</td>'
                                       + '<td>' + actionDescription + delim  + '</td>'
                                       + '<td>' + blob[data.recordID].action_history[i]['actionTextPasttense'] + delim + '</td>'
                                       + '<td>' + blob[data.recordID].action_history[i]['approverName'] + '</td>'
                                	   + delimLF + '</tr>';
                             }
                             buffer += '</table>';
                             $('#'+data.cellContainerID).html(buffer);
                         }});
            break;
        case 'days_since_last_action':
            leafSearch.getLeafFormQuery().join('action_history');
            headers.push({name: 'Days since last action', indicatorID: 'daysSinceLastAction', editable: false, callback: function(data, blob) {
                var daysSinceAction;
                if(blob[data.recordID].action_history != undefined) {
                    var lastAction = blob[data.recordID].action_history[blob[data.recordID].action_history.length - 1];
                    var date = new Date(lastAction.time * 1000);
                    daysSinceAction = Math.round((today.getTime() - date.getTime()) / 86400000);
                    if(blob[data.recordID].submitted == 0) {
                        daysSinceAction = "Not Submitted";
                    }
                }
                else {
                    daysSinceAction = "Not Submitted";
                }
                $('#'+data.cellContainerID).html(daysSinceAction);
            }});
            break;
	    default:
	    	if(column.substr(0, 6) == 'depID_') { // backwards compatibility for LEAF workflow requirement based approval dates
	    		depID = column.substr(6);
	    		tDepHeader[depID] = 0;
	    		leafSearch.getLeafFormQuery().join('recordsDependencies');

	            headers.push({name: 'Checkpoint Date', indicatorID: column, editable: false, callback: function(depID) {
	            	return function(data, blob) {
	                    if(blob[data.recordID].recordsDependencies != undefined
	                    	&& blob[data.recordID].recordsDependencies[depID] != undefined) {
	                        var date = new Date(blob[data.recordID].recordsDependencies[depID].time * 1000);
	                        $('#'+data.cellContainerID).html(date.toLocaleDateString().replace(/[^ -~]/g,'')); // IE11 encoding workaround: need regex replacement

	                        if(tDepHeader[depID] == 0) {
	                        	headerID = data.cellContainerID.substr(0, data.cellContainerID.indexOf('_') + 1) + 'header_' + column;
	                            $('#' + headerID).html(blob[data.recordID].recordsDependencies[depID].description);
	                            $('#Vheader_' + column).html(blob[data.recordID].recordsDependencies[depID].description);
	                        	tDepHeader[depID] = 1;
	                        }
	                    }
	            	}
                }(depID)});
	    	}
            if(column.substr(0, 7) == 'stepID_') { // approval dates based on workflow steps
                stepID = column.substr(7);
                tStepHeader[stepID] = 0;
                leafSearch.getLeafFormQuery().join('stepFulfillment');

                headers.push({name: 'Checkpoint Date', indicatorID: column, editable: false, callback: function(stepID) {
                    return function(data, blob) {
                        if(blob[data.recordID].stepFulfillment != undefined
                            && blob[data.recordID].stepFulfillment[stepID] != undefined) {
                            var date = new Date(blob[data.recordID].stepFulfillment[stepID].time * 1000);
                            $('#'+data.cellContainerID).html(date.toLocaleDateString().replace(/[^ -~]/g,'')); // IE11 encoding workaround: need regex replacement

                            if(tStepHeader[stepID] == 0) {
                                headerID = data.cellContainerID.substr(0, data.cellContainerID.indexOf('_') + 1) + 'header_' + column;
                                $('#' + headerID).html(blob[data.recordID].stepFulfillment[stepID].step);
                                $('#Vheader_' + column).html(blob[data.recordID].stepFulfillment[stepID].step);
                                tStepHeader[stepID] = 1;
                            }
                        }
                    }
                }(stepID)});
            }
	    	break;
	}
}

var resIndicatorList = {};
var searchPrereqsLoaded = false;
function loadSearchPrereqs() {
	if(searchPrereqsLoaded == true) {
		return;
	}
	searchPrereqsLoaded = true;
    $.ajax({
        type: 'GET',
        url: './api/?a=form/indicator/list',
        dataType: 'json',
        success: function(res) {
            var buffer = '';

            // special columns
            buffer += '<div class="col span_1_of_3">';
            buffer += '<div class="indicatorOption"><input type="checkbox" class="icheck" id="indicators_title" name="indicators[title]" value="title" />';
            buffer += '<label class="checkable" style="width: 100px" for="indicators_title"> Title of Request</label></div>';
            buffer += '<div class="indicatorOption"><input type="checkbox" class="icheck" id="indicators_service" name="indicators[service]" value="service" />';
            buffer += '<label class="checkable" style="width: 100px" for="indicators_service"> Service</label></div>';
            buffer += '<div class="indicatorOption"><input type="checkbox" class="icheck" id="indicators_type" name="indicators[type]" value="type" />';
            buffer += '<label class="checkable" style="width: 100px" for="indicators_type"> Type of Request</label></div>';
            buffer += '<div class="indicatorOption"><input type="checkbox" class="icheck" id="indicators_status" name="indicators[status]" value="status" />';
            buffer += '<label class="checkable" style="width: 100px" for="indicators_status"> Current Status</label></div>';
            buffer += '<div class="indicatorOption"><input type="checkbox" class="icheck" id="indicators_initiator" name="indicators[initiator]" value="initiator" />';
            buffer += '<label class="checkable" style="width: 100px" for="indicators_initiator"> Initiator</label></div>';
            buffer += '<div class="indicatorOption"><input type="checkbox" class="icheck" id="indicators_actionButton" name="indicators[actionButton]" value="actionButton" />';
            buffer += '<label class="checkable" style="width: 100px" for="indicators_actionButton"> Action Button</label></div>';
            buffer += '<div class="indicatorOption"><input type="checkbox" class="icheck" id="indicators_action_history" name="indicators[action_history]" value="action_history" />';
            buffer += '<label class="checkable" style="width: 100px" for="indicators_action_history"> Comment History</label></div>';
            buffer += '<div class="indicatorOption"><input type="checkbox" class="icheck" id="indicators_approval_history" name="indicators[approval_history]" value="approval_history" />';
            buffer += '<label class="checkable" style="width: 100px" for="indicators_approval_history"> Approval History</label></div>';
            buffer += '<div class="indicatorOption"><input type="checkbox" class="icheck" id="indicators_days_since_last_action" name="indicators[days_since_last_action]" value="days_since_last_action" />';
            buffer += '<label class="checkable" style="width: 100px" for="indicators_days_since_last_action"> Days since last action</label></div>';
            buffer += '</div>';
            var groupList = {};
            var groupNames = [];
            var groupIDmap = {};
            var tmp = document.createElement('div');
            var temp;
            for(var i in res) {
                temp = res[i].name;
                tmp.innerHTML = temp;
                temp = tmp.textContent || tmp.innerText || '';
                temp = temp.replace(/[^\040-\176]/g, '');

                resIndicatorList[res[i].indicatorID] = temp;

                if(groupList[res[i].categoryID] == undefined) {
                    groupList[res[i].categoryID] = [];
                }
                groupList[res[i].categoryID].push(res[i].indicatorID);
                if(groupIDmap[res[i].categoryID] == undefined) {
                    groupNames.push({categoryID: res[i].categoryID,
                                                    categoryName: res[i].categoryName});
                    groupIDmap[res[i].categoryID] = {};
                    groupIDmap[res[i].categoryID].categoryName = res[i].categoryName;
                    groupIDmap[res[i].categoryID].categoryID = res[i].categoryID;
                    groupIDmap[res[i].categoryID].parentCategoryID = res[i].parentCategoryID;
                    groupIDmap[res[i].categoryID].parentStaples = res[i].parentStaples;
                }
            }

            buffer += '<div class="col span_1_of_3">';

            groupNames.sort(function(a, b) {
                a = a.categoryName.toLowerCase();
                b = b.categoryName.toLowerCase();
                if(a < b) {
                    return -1;
                }
                if(a > b) {
                    return 1;
                }
                return 0;
            });

            for(var k in groupNames) {
                var i = groupNames[k].categoryID;
                var associatedCategories = groupIDmap[i].categoryID;
                if(groupIDmap[i].parentCategoryID != '') {
                    associatedCategories += ' ' + groupIDmap[i].parentCategoryID;
                }
                if(groupIDmap[i].parentStaples != null) {
                    for(var j in groupIDmap[i].parentStaples) {
                        associatedCategories += ' ' + groupIDmap[i].parentStaples[j];
                    }
                }

                var categoryLabel = groupNames[k].categoryName;
                if(groupIDmap[i].parentCategoryID != '' && groupIDmap[groupIDmap[i].parentCategoryID]) {
                    categoryLabel += "<br />" + groupIDmap[groupIDmap[i].parentCategoryID].categoryName;
                }
                buffer += '<div class="form category '+ associatedCategories +'" style="width: 250px; float: left; min-height: 30px; margin-bottom: 4px"><div class="formLabel buttonNorm"><img src="../libs/dynicons/?img=gnome-zoom-in.svg&w=32" alt="Icon to expand section"/> ' + categoryLabel + '</div>';
                for(var j in groupList[i]) {
                    buffer += '<div class="indicatorOption" style="display: none"><input type="checkbox" class="icheck" id="indicators_'+ groupList[i][j] +'" name="indicators['+ groupList[i][j] +']" value="'+ groupList[i][j] +'" />';
                    buffer += '<label class="checkable" style="width: 100px" for="indicators_'+ groupList[i][j] +'" title="indicatorID: '+ groupList[i][j] +'\n'+ resIndicatorList[groupList[i][j]] +'" alt="indicatorID: '+ groupList[i][j] +'"> ' + resIndicatorList[groupList[i][j]] +'</label></div>';
                }
                buffer += '</div>';
            }

            buffer += '</div>';

            $('#indicatorList').html(buffer);

            $('#indicatorList').css('height', $(window).height() - 240);
            $('.form').on('click', function() {
            	$(this).children('.formLabel').removeClass('buttonNorm');
            	$(this).find('.formLabel>img').css('display', 'none');
            	$(this).css({width: '100%'});
            	$(this).children('div').css('display', 'block');
            	$(this).children('.formLabel').css({'border-bottom': '1px solid #e0e0e0',
            		'font-weight': 'bold'});
            });

            $.ajax({
            	type: 'GET',
            	url: './api/workflow/steps',
            	dataType: 'json',
            	success: function(res) {
                    buffer = '';
                    buffer += '<div class="form col span_1_of_3" style="min-height: 30px; margin: 4px"><div class="formLabel" style="border-bottom: 1px solid #e0e0e0; font-weight: bold">Checkpoint Dates<br />(Data only available from May 3, 2017)</div>';
                    for(var i in res) {
                        buffer += '<div class="indicatorOption"><input type="checkbox" class="icheck" id="indicators_stepID_'+ res[i].stepID +'" name="indicators[stepID'+ res[i].stepID +']" value="stepID_'+ res[i].stepID +'" />';
                        buffer += '<label class="checkable" style="width: 100px" for="indicators_stepID_'+ res[i].stepID +'" title="'+ res[i].stepTitle +'"> '+ res[i].description + ' - ' + res[i].stepTitle +'</label></div>';
                    }
                    buffer += '<div id="legacyDependencies"></div>'; // backwards compat
                    buffer += '</div>';

                    $('#indicatorList').append(buffer);

                    $.ajax({
                        type: 'GET',
                        url: './api/?a=workflow/dependencies',
                        dataType: 'json',
                        success: function(res) {
                            buffer2 = '';
                            buffer2 += '<div><br /><br /><div class="formLabel" style="border-bottom: 1px solid #e0e0e0; font-weight: bold">Action Dates (step requirements)</div>';

                            // Option to retrieve Date Request Initiated / Resolved
                            buffer2 += '<div id="option_dateCancelled" class="indicatorOption"><input type="checkbox" class="icheck" id="indicators_dateCancelled" name="indicators[dateCancelled]" value="dateCancelled" />';
                            buffer2 += '<label class="checkable" style="width: 100px" for="indicators_dateCancelled" title="Date request Cancelled"> Date Request Cancelled</label></div>';
                            buffer2 += '<div class="indicatorOption"><input type="checkbox" class="icheck" id="indicators_dateInitiated" name="indicators[dateInitiated]" value="dateInitiated" />';
                            buffer2 += '<label class="checkable" style="width: 100px" for="indicators_dateInitiated" title="Date request initiated"> Date Request Initiated</label></div>';
                            buffer2 += '<div class="indicatorOption"><input type="checkbox" class="icheck" id="indicators_dateResolved" name="indicators[dateResolved]" value="dateResolved" />';
                            buffer2 += '<label class="checkable" style="width: 100px" for="indicators_dateResolved" title="Date request resolved"> Date Request Resolved</label></div>';
                            buffer2 += '<div class="indicatorOption"><input type="checkbox" class="icheck" id="indicators_resolvedBy" name="indicators[resolvedBy]" value="resolvedBy" />';
                            buffer2 += '<label class="checkable" style="width: 100px" for="indicators_resolvedBy" title="Resolved By"> Resolved By</label></div>';

                            for(var i in res) {
                                buffer2 += '<div class="indicatorOption"><input type="checkbox" class="icheck" id="indicators_depID_'+ res[i].dependencyID +'" name="indicators[depID_'+ res[i].dependencyID +']" value="depID_'+ res[i].dependencyID +'" />';
                                buffer2 += '<label class="checkable" style="width: 100px" for="indicators_depID_'+ res[i].dependencyID +'"> ' + res[i].description +'</label></div>';
                            }
                            buffer2 += '</div>';

                            $('#legacyDependencies').append(buffer2);

                            // write buffer and finalize view
                            //$('#indicatorList').append(buffer);

                            // set user selections
                            if(t_inIndicators != undefined) {
                                for(var i in t_inIndicators) {
                                    $('#indicators_' + t_inIndicators[i].indicatorID).prop('checked', true);
                                }
                            }
                            else {
                                // pre-select defaults
                                $('#indicators_title').prop('checked', true);
                            }

                            $('.icheck').icheck({checkboxClass: 'icheckbox_square-blue', radioClass: 'iradio_square-blue'});
                        }
                    });
            	}
            });
        },
        cache: false
    });
}

function editLabels_down(id) {
    var row = $('#sortID_' + id);
    row.next().after(row);
}

function editLabels_up(id) {
    var row = $('#sortID_' + id);
    row.prev().before(row);
}

function editLabels() {
	dialog.setTitle('Edit Labels');

	var buffer = '<table id="labelSorter">';

	if (Object.keys(indicatorSort).length !== 0) {
		resSelectList.sort(function(a, b) {
			var sortA = indicatorSort[a] == undefined ? 0 : indicatorSort[a];
			var sortB = indicatorSort[b] == undefined ? 0 : indicatorSort[b];

		    if(sortA < sortB) {
		        return -1
		    }
		    if(sortB < sortA) {
		        return 1;
		    }
		    return 0;
		});
	}

	for(var i in resSelectList) {
		if(resIndicatorList[resSelectList[i]] != undefined) {
			buffer += '<tr id="sortID_'+ resSelectList[i] +'"><td><input type="text" style="min-width: 400px" id="id_'+ resSelectList[i] +'" value="'+ resIndicatorList[resSelectList[i]] +'"></input></td>';
			buffer += '<td><button class="buttonNorm" onclick="editLabels_down('+ resSelectList[i] +');"><img src="../libs/dynicons/?img=go-down_red.svg&w=16" /></button> ';
			buffer += '<button class="buttonNorm" onclick="editLabels_up('+ resSelectList[i] +');"><img src="../libs/dynicons/?img=go-up.svg&w=16" /></button></td></tr>';
		}
	}
	buffer += '</table>';
    dialog.setContent(buffer);
    dialog.show();

    dialog.setSaveHandler(function() {
    	$('#labelSorter tr').each(function(i) {
    		var curID = this.id.substr(7);
    		indicatorSort[curID] = i + 1;
    	});
        var tmp = document.createElement('div');
        var temp;
        for(var i in resSelectList) {
            if(resIndicatorList[resSelectList[i]] != undefined) {
                temp = $('#id_' + resSelectList[i]).val();
                tmp.innerHTML = temp;
                temp = tmp.textContent || tmp.innerText || '';
                temp = temp.replace(/[^\040-\176]/g, '');
            	resIndicatorList[resSelectList[i]] = temp;
            }
        }
        $('#generateReport').click();
        dialog.hide();
    });
}

function isSearchingDeleted(searchObj) {
    // check if the user explicitly wants to find deleted requests
    var t = searchObj.getLeafFormQuery().getQuery();
    var searchDeleted = false;
    for(var i in t.terms) {
        if(t.terms[i].id == 'stepID'
            && t.terms[i].match == 'deleted'
            && t.terms[i].operator == '=') {

            return true;
        }
    }
    return false;
}

function sortHeaders(a, b) {
    a.sort = a.sort == undefined ? 0 : a.sort;
    b.sort = b.sort == undefined ? 0 : b.sort;
    if(a.sort < b.sort) {
        return -1
    }
    if(b.sort < a.sort) {
        return 1;
    }
    return 0;
}

function openShareDialog() {
    var pwd = document.URL.substr(0,document.URL.lastIndexOf('/') + 1);
    var reportLink = document.URL.substr(document.URL.lastIndexOf('/') + 1);

    dialog_message.setTitle('Share Report');
    dialog_message.setContent('<p>This link can be shared to provide a live view into this report.</p>'
                            + '<br /><textarea id="reportLink" style="width: 95%; height: 100px">'+ pwd + reportLink +'</textarea>'
                            + '<button id="prepareEmail" type="button" class="buttonNorm"><img src="../libs/dynicons/?img=internet-mail.svg&w=32" alt="Email report" /> Email Report</button> '
                            + '<br /><br /><p>Access rules are automatically applied based on the form and workflow configuration.</p>');
    dialog_message.show();
    $('#reportLink').on('click', function() {
        $('#reportLink').select();
    })

    $('#prepareEmail').on('click', function() {
        prepareEmail($('#reportLink').html());
    });

    $.ajax({
        type: 'POST',
        url: './api/open/report',
        data: {data: reportLink,
            CSRFToken: CSRFToken}
    })
    .then(function(res) {
        $('#reportLink').html(pwd + 'open.php?report=' + res);
    });
}

function showJSONendpoint() {
    var pwd = document.URL.substr(0,document.URL.lastIndexOf('/') + 1);
    var queryString = JSON.stringify(leafSearch.getLeafFormQuery().getQuery());
    var jsonPath = pwd + leafSearch.getLeafFormQuery().getRootURL() + 'api/form/query/?q=' + queryString;
    var powerQueryURL = '<!--{$powerQueryURL}-->' + window.location.pathname;

	dialog_message.setTitle('Data Endpoints');
    dialog_message.setContent('<p>This provides a live data source for custom dashboards or automated programs.</p><br />'
                           + '<button id="shortenLink" class="buttonNorm" style="float: right">Shorten Link</button>'
                           + '<button id="expandLink" class="buttonNorm" style="float: right; display: none">Expand Link</button>'
                           + '<select id="format">'
                           + '<option value="json">JSON</option>'
                           + '<option value="htmltable">HTML Table</option>'
                           + '<option value="jsonp">JSON-P</option>'
                           + '<option value="csv">CSV</option>'
                           + '<option value="xml">XML</option>'
                           + '<option value="debug">Plaintext</option>'
                           + '<option value="x-visualstudio">Visual Studio (testing)</option>'
                           + '</select>'
                           + '<span id="formatStatus" style="background-color:green; padding:5px 5px; color:white; display:none;"></span>'
                           + '<br /><div id="exportPathContainer" contenteditable="true" style="border: 1px solid gray; padding: 4px; margin-top: 4px; width: 95%; height: 100px; word-break: break-all;"><span id="exportPath">'+ jsonPath +'</span><span id="exportFormat"></span></div>'
			               + '<a href="./api/form/indicator/list?format=htmltable&sort=indicatorID" target="_blank">Data Dictionary Reference</a>'
                           + '<br /><br />'
                           + '<fieldset>'
                           + '<legend>Options</legend>'
                           + '<input id="msCompatMode" type="checkbox" /><label for="msCompatMode">Use compatibility mode (Excel, Access, etc.)</label>'
                           + '</fieldset>');

    $('#msCompatMode').on('click', function() {
        $('#shortenLink').click();

    });

    function setExportFormat() {
        if($('#shortenLink').css('display') == 'none') {
            $('#exportFormat').html('?');
        }
        else {
            $('#exportFormat').html('&');
        }


        switch($('#format').val()) {
            case 'json':
                $('#exportFormat').html('');
                break;
            default:
                $('#exportFormat').append('format=' + $('#format').val());
                $("#formatStatus").show().text("Format changed to " + $('#format').val());
                $("#formatStatus").fadeOut(3000);
                break;
        }
    }

    $('#format').on('change', function() {
        setExportFormat();
    });

    $('#expandLink').on('click', function() {
        $('#expandLink').css('display', 'none');
        $('#shortenLink').css('display', 'inline');
        $('#exportPath').html(jsonPath);
        $('#exportPath').off();
        setExportFormat();
    });

    $('#shortenLink').on('click', function() {
        $('#shortenLink').css('display', 'none');
        $('#exportPath').on('focus', function() {
		    document.execCommand("selectAll", false, null);
	    });
        $.ajax({
            type: 'POST',
            url: './api/open/form/query',
            data: {data: queryString,
                CSRFToken: CSRFToken}
        })
        .then(function(res) {
            $('#exportPath').html(pwd + leafSearch.getLeafFormQuery().getRootURL() + 'api/open/form/query/_' + res);
           if($('#msCompatMode').is(':checked')) {
                $('#expandLink').css('display', 'none');
                $('#exportPath').html(powerQueryURL + 'api/open/form/query/_' + res);
            }
            else {
                $('#expandLink').css('display', 'inline');
            }
            setExportFormat();
        });
    });

    // set defaults for IE
    if (navigator.msSaveOrOpenBlob) {
        $('#msCompatMode').click();
    }
	dialog_message.show();
}

var url, urlQuery, urlIndicators;
var leafSearch;
var headers = [];
var t_inIndicators;
var isNewQuery = false;
var dialog, dialog_message;
var indicatorSort = {}; // object = indicatorID : sortID
var grid;

var version = 3;
/* URL formats
    * v1 - base64
    * v2 - lz-string in base64
    * v3 - uses getData() from formQuery.js
*/
$(function() {
	dialog = new dialogController('xhrDialog', 'xhr', 'loadIndicator', 'button_save', 'button_cancelchange');
	dialog_message = new dialogController('genericDialog', 'genericDialogxhr', 'genericDialogloadIndicator', 'genericDialogbutton_save', 'genericDialogbutton_cancelchange');
    leafSearch = new LeafFormSearch('searchContainer');
    leafSearch.setOrgchartPath('<!--{$orgchartPath}-->');
    leafSearch.renderUI();

    $('#' + leafSearch.getPrefixID() + 'advancedSearchButton').click();
    $('#' + leafSearch.getPrefixID() + 'advancedOptions').css('border', '0');
    $('#' + leafSearch.getPrefixID() + 'advancedOptionsClose').css('visibility', 'hidden');
    $('#' + leafSearch.getPrefixID() + 'advancedOptions>legend').css('display', 'none');
    $('#' + leafSearch.getPrefixID() + 'advancedSearchApply').html('Next Step <img src="../libs/dynicons/?img=go-next.svg&w=32" alt="next step" />');

    $('#' + leafSearch.getPrefixID() + 'advancedSearchApply').off();

    // Step 1
    $('#' + leafSearch.getPrefixID() + 'advancedSearchApply').on('click', function() {
    	$('#step_2').fadeIn(400);
    	$('#step_1').slideUp(400);

    	// hide data fields that don't match forms selected by the user
    	leafSearch.generateQuery();
    	var tTerms = leafSearch.getLeafFormQuery().getQuery().terms;
    	var filteredCategories = [];
        var showOptionCancelled = false;

    	for(var i in tTerms) {
    		if(tTerms[i].id == 'categoryID'
    			&& tTerms[i].operator == '=') {
    			filteredCategories.push(tTerms[i].match);
    		}

            // hide dateCancelled option unless it's being searched for
            if(tTerms[i].id == 'stepID'
    			&& tTerms[i].operator == '='
                && tTerms[i].match == 'deleted') {
    			showOptionCancelled = true;
    		}
    	}
    	if(filteredCategories.length > 0) {
    		$('.category').css('display', 'none');
    		for(var i in filteredCategories) {
    			$('.' + filteredCategories[i]).css('display', 'inline');
    		}
    	}
    	else {
    		$('.category').css('display', 'inline');
    	}

        if(showOptionCancelled) {
            $('#option_dateCancelled').css('display', 'inline');
        }
        else {
            $('#option_dateCancelled').css('display', 'none');
        }
    });

    <!--{if $query == '' || $indicators == ''}-->
    loadSearchPrereqs();
    isNewQuery = true;
    <!--{/if}-->

    // Step 2
    var selectedIndicators = [];
    grid = new LeafFormGrid('results');
    grid.enableToolbar();
    var extendedToolbar = false;
    $('#generateReport').off();
    $('#generateReport').on('click', function() {
        $('#results').fadeIn(700);
        $('#saveLinkContainer').fadeIn(700);
        $('#step_2').slideUp(700);

        if(isNewQuery) {
            leafSearch.generateQuery();

            if(!isSearchingDeleted(leafSearch)) {
            	leafSearch.getLeafFormQuery().addTerm('deleted', '=', 0);
            }
            leafSearch.getLeafFormQuery().join('service');
            headers = [];
        }
        else if(!isSearchingDeleted(leafSearch)) {
            leafSearch.getLeafFormQuery().addTerm('deleted', '=', 0);
        }

    	selectedIndicators = [];
    	resSelectList = [];
    	$('.icheck:checked').each(function() {
    		resSelectList.push(this.value);
    	});
    	resSelectList.sort(function(a, b) {
            var sortA = indicatorSort[a] == undefined ? 0 : indicatorSort[a];
            var sortB = indicatorSort[b] == undefined ? 0 : indicatorSort[b];

            if(sortA < sortB) {
                return -1
            }
            if(sortB < sortA) {
                return 1;
            }
            return 0;
        });
    	for(var i in resSelectList) {
            var temp = {};
            temp.indicatorID = resSelectList[i];
            temp.name = resIndicatorList[temp.indicatorID] != undefined ? resIndicatorList[temp.indicatorID] : '';
            temp.sort = indicatorSort[temp.indicatorID] == undefined ? 0 : indicatorSort[temp.indicatorID];
            var tmp = document.createElement('div');
            tmp.innerHTML = temp.name;
            temp.name = tmp.textContent || tmp.innerText || '';
            temp.name = temp.name.replace(/[^\040-\176]/g, '');
            if($.isNumeric(resSelectList[i])) {
                headers.push(temp);
                leafSearch.getLeafFormQuery().getData(temp.indicatorID);
            }
            else {
                addHeader(temp.indicatorID);
            }
            selectedIndicators.push(temp);
    	}

    	headers.sort(sortHeaders);
    	selectedIndicators.sort(sortHeaders);


    	grid.setHeaders(headers);

    	leafSearch.getLeafFormQuery().onSuccess(function(res) {
            grid.setDataBlob(res);

            // this replaces grid.loadData()
            var tGridData = [];
            for(var i in res) {
                tGridData.push(res[i]);
            }

            if(<!--{$version}--> >= 3) {
                grid.setData(tGridData);
                grid.sort('recordID', 'desc');
                grid.renderBody();
            }
            else {
                var recordIDs = '';
                for (var i in res) {
                    recordIDs += res[i].recordID + ',';
                }
            	grid.loadData(recordIDs);
            }
    	});

    	// get data
    	leafSearch.getLeafFormQuery().execute();

    	// create save link once
    	if(!extendedToolbar) {
            $('#' + grid.getPrefixID() + 'gridToolbar').prepend('<button type="button" class="buttonNorm" onclick="openShareDialog()"><img src="../libs/dynicons/?img=internet-mail.svg&w=32" alt="share report" /> Share Report</button> ');
            $('#' + grid.getPrefixID() + 'gridToolbar').prepend('<button type="button" id="editLabels" class="buttonNorm" onclick="editLabels()"><img src="../libs/dynicons/?img=accessories-text-editor.svg&w=32" alt="email report" /> Edit Labels</button> ');

            $('#' + grid.getPrefixID() + 'gridToolbar').css('width', '460px');
            $('#' + grid.getPrefixID() + 'gridToolbar').prepend('<button type="button" class="buttonNorm" id="editReport"><img src="../libs/dynicons/?img=gnome-applications-science.svg&w=32" alt="Modify report" /> Modify Report</button> ');
            $('#' + grid.getPrefixID() + 'gridToolbar').append(' <button type="button" class="buttonNorm" onclick="showJSONendpoint();"><img src="../libs/dynicons/?img=applications-other.svg&w=32" alt="Icon for JSON endpoint viewer" /> JSON</button> ');
            extendedToolbar = true;

            $('#editReport').on('click', function() {
            	grid.stop();
            	isNewQuery = true;
                $('#reportTitleDisplay').css('display', 'none');
                $('#reportTitle').css('display', 'block');
            	loadSearchPrereqs();
                $('#saveLinkContainer').slideUp(700);
                $('#results').fadeOut(700);
                $('#step_1').fadeIn(700);
            });
    	}

    	if($.isEmptyObject(resIndicatorList)) {
    		$('#editLabels').css('display', 'none');
    	}
    	else {
    		$('#editLabels').css('display', 'inline');
    	}

    	urlQuery = LZString.compressToBase64(JSON.stringify(leafSearch.getLeafFormQuery().getQuery()));
    	urlIndicators = LZString.compressToBase64(JSON.stringify(selectedIndicators));

    	if(isNewQuery) {
    		baseURL = '';
    		if(window.location.href.indexOf('&') == -1) {
    			baseURL = window.location.href;
    		}
    		else {
    			baseURL = window.location.href.substr(0, window.location.href.indexOf('&'));
    		}
            url = baseURL + '&v='+ version + '&query=' + encodeURIComponent(urlQuery) + '&indicators=' + encodeURIComponent(urlIndicators);
            if($('#reportTitle').val() != '') {
                url += '&title=' + encodeURIComponent(btoa($('#reportTitle').val()));
            }
            window.history.pushState('', '', url);
            $('#reportTitle').on('keyup', function() {
                url = baseURL + '&v='+ version + '&query=' + encodeURIComponent(urlQuery) + '&indicators=' + encodeURIComponent(urlIndicators) + '&title=' + encodeURIComponent(btoa($('#reportTitle').val()));
                window.history.pushState('', '', url);
            });
    	}
    	else {
    		url = window.location.href;
    	}
    });

    <!--{if $query != '' && $indicators != ''}-->
    function loadReport() {
        var inQuery;
        var inIndicators;
        var title = '';
        title = atob('<!--{$title|escape:"html"}-->');
        title = title.replace(/[^\040-\176]/g, '');
        title = title.replace(/</g, '&lt;');
        title = title.replace(/>/g, '&gt;');
        $('#reportTitleDisplay').html(title);
        $('#reportTitle').css('display', 'none');
        $('#reportTitle').off();
        $('#reportTitle').val(title);
        $('#reportTitleDisplay').on('click', function() {
            $('#reportTitleDisplay').css('display', 'none');
            $('#reportTitle').css('display', 'inline');
            $('#reportTitle').on('keyup', function() {
                baseURL = window.location.href.substr(0, window.location.href.indexOf('&title='));
                url = baseURL + '&title=' + encodeURIComponent(btoa($('#reportTitle').val()));
                window.history.pushState('', '', url);
            });
        });
        try {
        	if(<!--{$version}--> >= 2) {
        	    var query = '<!--{$query|escape:"html"}-->';
        	    var indicators = '<!--{$indicators|escape:"html"}-->';
                query = query.replace(/ /g, '+');
                indicators = indicators.replace(/ /g, '+');
                inQuery = JSON.parse(LZString.decompressFromBase64(query));
                t_inIndicators = JSON.parse(LZString.decompressFromBase64(indicators));
        	}
        	else {
                inQuery = JSON.parse(atob('<!--{$query|escape:"html"}-->'));
                t_inIndicators = JSON.parse(atob('<!--{$indicators|escape:"html"}-->'));
        	}
        	inIndicators = [];
        	for(var i in t_inIndicators) {
        		var temp = {};
                if($.isNumeric(t_inIndicators[i].indicatorID)) {
                    temp.indicatorID = parseInt(t_inIndicators[i].indicatorID);
                    temp.name = t_inIndicators[i].name.replace(/[^\040-\176]/g, '');
                    temp.name = temp.name.replace(/</g, '&lt;');
                    temp.name = temp.name.replace(/>/g, '&gt;');
                    inIndicators.push(temp);
                }
                else {
                    addHeader(t_inIndicators[i].indicatorID);
                }
        	}

        	leafSearch.getLeafFormQuery().setQuery(inQuery);
        	if(!isSearchingDeleted(leafSearch)) {
                inQuery.terms.pop();
        	}
        	leafSearch.renderPreviousAdvancedSearch(inQuery.terms);
        	headers = headers.concat(inIndicators);
        	$('#step_1').slideUp(700);
        	$('#generateReport').click();
        }
        catch(err) {
        	alert('Invalid report');
        	console.log(err);
        }
    }
    if(typeof atob == 'function') {
        loadReport();
    }
    <!--{/if}-->
    // ie9 workaround
    if(typeof atob != 'function') {
        $.ajax({
            type: 'GET',
            url: 'js/base64.js',
            dataType: 'script',
            success: function() {
                window.atob = base64.decode;
                window.btoa = base64.encode;
                <!--{if $query != '' && $indicators != ''}-->
                loadReport();
                <!--{/if}-->
            }
        });
    }
    if(typeof window.history.pushState != 'function') {
    	window.history.pushState = function(a, b, c) {

    	}
    }
});
</script>
