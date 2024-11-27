<div id="step_1" style="<!--{if $query != '' && $indicators != ''}-->display: none; <!--{/if}-->width: fit-content; width: -moz-fit-content; background-color: white; border: 1px solid black; margin: 2em auto; padding: 0px">
    <div style="background-color: #003a6b; color: white; padding: 4px; font-size: 22px; font-weight: bold">
        Step 1: Develop search filter
    </div>
    <div style="padding: 8px">
        <div id="searchContainer"></div>
    </div>
</div>

<div id="step_2" style="display: none; width: 95%; background-color: white; border: 1px solid black; margin: 2em auto; padding: 0px">
    <div style="background-color: #0059a4; color: white; padding: 4px; font-size: 22px; font-weight: bold">
        Step 2: Select Data Columns
    </div>
    <div style="padding: 8px">
        <div id="indicatorList" class="section group" style="padding: 8px">Loading...</div>
        <br style="clear: both" />
        <button id="generateReport" class="buttonNorm" style="position: fixed; bottom: 14px; margin: auto; left: 0; right: 0; font-size: 140%; height: 52px; padding-top: 8px; padding-bottom: 4px; width: 70%; margin: auto; text-align: center; box-shadow: 0 0 20px black">Generate Report <img src="dynicons/?img=x-office-spreadsheet-template.svg&w=32" alt="" /></button>
    </div>
</div>

<div id="saveLinkContainer" style="display: none">
    <div id="reportTitleDisplay" style="font-size: 200%; padding-left: 8px;"></div>
    <input id="reportTitle" type="text" aria-label="Text" style="font-size: 200%; width: 50%" placeholder="Untitled Report" />
    <br /><span id="reportStats" style="padding-left: 8px; z-index: 1"></span><button id="btn_abort" class="buttonNorm" style="display: none">Stop and show results</button>
</div>

<div id="results" style="display: none">Loading...</div>

<!--{include file="site_elements/generic_dialog.tpl"}-->
<!--{include file="site_elements/generic_xhrDialog.tpl"}-->
<!--{include file="site_elements/generic_confirm_xhrDialog.tpl"}-->
<!--{include file="site_elements/generic_OkDialog.tpl"}-->
<script>
const CSRFToken = '<!--{$CSRFToken}-->';

function scrubHTML(input) {
    if(input == undefined) {
        return '';
    }
    let t = new DOMParser().parseFromString(input, 'text/html').body;
    while(input != t.textContent) {
        return scrubHTML(t.textContent);
    }
    return t.textContent;
}

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
var filterData = {}; // used to remove unused data returned by query
let categoryID = 'strCatID';

function addHeader(column) {
    let today = new Date();
    switch(column) {
        case 'title':
            filterData['title'] = 1;
            headers.push({
                name: 'Title',
                indicatorID: 'title',
                callback: function(data, blob) {
                    document.querySelector(`#${data.cellContainerID}`).innerHTML = blob[data.recordID].title;
                    document.querySelector(`#${data.cellContainerID}`).addEventListener('click', () => {
                        changeTitle(data, $('#'+data.cellContainerID).html());
                    });
            }});
            break;
        case 'service':
            filterData['service'] = 1;
            leafSearch.getLeafFormQuery().join('service');
            headers.push({
                name: 'Service',
                indicatorID: 'service',
                editable: false,
                callback: function(data, blob) {
                    document.querySelector(`#${data.cellContainerID}`).innerHTML = blob[data.recordID].service;
            }});
            break;
        case 'type':
            filterData['categoryNames'] = 1;
            leafSearch.getLeafFormQuery().join('categoryName');
            headers.push({
                name: 'Type',
                indicatorID: 'type',
                editable: false,
                callback: function(data, blob) {
                     let types = '';
                     for(let i in blob[data.recordID].categoryNames) {
                         types += blob[data.recordID].categoryNames[i] + ' | ';
                     }
                     types = types.substr(0, types.length - 3);
                     document.querySelector(`#${data.cellContainerID}`).innerHTML = types;
            }});
            break;
        case 'status':
            filterData['stepTitle'] = 1;
            filterData['lastStatus'] = 1;
            leafSearch.getLeafFormQuery().join('status');
            headers.push({
                name: 'Current Status',
                indicatorID: 'status',
                editable: false,
                callback: function(data, blob) {
                     var status = blob[data.recordID].stepTitle == null ? blob[data.recordID].lastStatus : 'Pending ' + blob[data.recordID].stepTitle;
                     status = status == null ? 'Not Submitted' : status;
                     if(blob[data.recordID].deleted > 0) {
                         status += ', Cancelled';
                     }
                     document.querySelector(`#${data.cellContainerID}`).innerHTML = status;
            }});
            break;
        case 'initiator':
            filterData['lastName'] = 1;
            filterData['firstName'] = 1;
            leafSearch.getLeafFormQuery().join('initiatorName');
            headers.push({
                name: 'Initiator', indicatorID: 'initiator', editable: false, callback: function(data, blob) {
                document.querySelector(`#${data.cellContainerID}`).innerHTML = blob[data.recordID].lastName + ', ' + blob[data.recordID].firstName;
            }});
            break;
        case 'dateCancelled':
            filterData['deleted'] = 1;
            filterData['action_history.approverName'] = 1;
            leafSearch.getLeafFormQuery().join('action_history');
            headers.push({
                name: 'Date Cancelled', indicatorID: 'dateCancelled', editable: false, callback: function(data, blob) {
                if(blob[data.recordID].deleted > 0) {
                    var date = new Date(blob[data.recordID].deleted * 1000);
                    document.querySelector(`#${data.cellContainerID}`).innerHTML = date.toLocaleDateString();
                }
            }});
            headers.push({
                name: 'Cancelled By', indicatorID: 'cancelledBy', editable: false, callback: function(data, blob) {
                if(blob[data.recordID].action_history != undefined) {
                    var cancelData = blob[data.recordID].action_history.pop();
                    if(cancelData != undefined && cancelData.actionType === 'deleted') {
                        document.querySelector(`#${data.cellContainerID}`).innerHTML = cancelData.approverName;
                    }
                }
            }});
            break;
        case 'dateInitiated':
            filterData['date'] = 1;
            headers.push({
                name: 'Date Initiated', indicatorID: 'dateInitiated', editable: false, callback: function(data, blob) {
                var date = new Date(blob[data.recordID].date * 1000);
                document.querySelector(`#${data.cellContainerID}`).innerHTML = date.toLocaleDateString();
            }});
            break;
        case 'dateResolved':
            filterData['recordResolutionData'] = 1;
            leafSearch.getLeafFormQuery().join('recordResolutionData');
            headers.push({
                name: 'Date Resolved', indicatorID: 'dateResolved', editable: false, callback: function(data, blob) {
                if(blob[data.recordID].recordResolutionData != undefined) {
                    var date = new Date(blob[data.recordID].recordResolutionData.fulfillmentTime * 1000);
                    document.querySelector(`#${data.cellContainerID}`).innerHTML = date.toLocaleDateString();
                }
            }});
            headers.push({
                name: 'Action Taken', indicatorID: 'typeResolved', editable: false, callback: function(data, blob) {
                if(blob[data.recordID].recordResolutionData != undefined) {
                    document.querySelector(`#${data.cellContainerID}`).innerHTML = blob[data.recordID].recordResolutionData.lastStatus;
                }
            }});
            break;
        case 'resolvedBy':
            filterData['recordResolutionBy'] = 1;
            leafSearch.getLeafFormQuery().join('recordResolutionBy');
            headers.push({
                name: 'Resolved By', indicatorID: 'resolvedBy', editable: false, callback: function(data, blob) {
                if(blob[data.recordID].recordResolutionBy != undefined) {
                    document.querySelector(`#${data.cellContainerID}`).innerHTML = blob[data.recordID].recordResolutionBy.resolvedBy;
                }
            }});
            break;
        case 'actionButton':
            headers.unshift({
                name: 'Action', indicatorID: 'actionButton', editable: false, callback: function(data, blob) {
                document.querySelector(`#${data.cellContainerID}`).innerHTML = '<div tabindex="0" class="buttonNorm">Take Action</div>';
                document.querySelector(`#${data.cellContainerID}`).addEventListener('keydown', function(e) {
                    if (e.which === 13) {
                        e.preventDefault();
                        loadWorkflow(data.recordID, grid.getPrefixID());
                    }
                });
                document.querySelector(`#${data.cellContainerID}`).addEventListener('click', function() {
                    loadWorkflow(data.recordID, grid.getPrefixID());
                });
            }});
            break;
        case 'action_history':
            filterData['action_history.time'] = 1;
            filterData['action_history.comment'] = 1;
            leafSearch.getLeafFormQuery().join('action_history');
            headers.push({
                name: 'Comment History',
                indicatorID: 'action_history',
                editable: false,
                callback: function(data, blob) {
                     var buffer = '<table style="min-width: 300px">';
                     var now = new Date();

                     for(let i in blob[data.recordID].action_history) {
                         var date = new Date(blob[data.recordID].action_history[i]['time'] * 1000);
                         var formattedDate = date.toLocaleDateString();
                         if(blob[data.recordID].action_history[i]['comment'] != '') {
                             buffer += '<tr><td style="border-right: 1px solid black; padding-right: 4px; text-align: right">'
                                + formattedDate + delim + '</td><td style="padding-left: 4px">' + blob[data.recordID].action_history[i]['comment'] + '.</td>'
                                + delimLF + '</tr>';
                         }
                     }
                     buffer += '</table>';
                     document.querySelector(`#${data.cellContainerID}`).innerHTML = buffer;
            }});
            break;
        case 'approval_history':
            filterData['action_history.time'] = 1;
            filterData['action_history.description'] = 1;
            filterData['action_history.actionTextPasttense'] = 1;
            filterData['action_history.approverName'] = 1;
            leafSearch.getLeafFormQuery().join('action_history');
            headers.push({
                name: 'Approval History',
                indicatorID: 'approval_history',
                editable: false,
                callback: function(data, blob) {
                     var buffer = '<table class="table" style="min-width: 300px">';
                     var now = new Date();

                     for(let i in blob[data.recordID].action_history) {
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
                     document.querySelector(`#${data.cellContainerID}`).innerHTML = buffer;
                 }});
            break;
        case 'days_since_last_action':
        case 'days_since_last_step_movement':
            filterData['action_history.time'] = 1;
            filterData['action_history.stepID'] = 1;
            filterData['action_history.actionType'] = 1;
            filterData['stepFulfillmentOnly'] = 1;
            filterData['submitted'] = 1;
            leafSearch.getLeafFormQuery().join('action_history');
            leafSearch.getLeafFormQuery().join('stepFulfillmentOnly');

            let headerName = (column === 'days_since_last_action') ? 'Days Since Last Action' : 'Days Since Last Workflow Change';
            let indicatorIDName = (column === 'days_since_last_action') ? 'daysSinceLastAction' : 'daysSinceLastStepMovement';
            headers.push({
                name: headerName,
                indicatorID: indicatorIDName,
                editable: false,
                callback: function(data, blob) {
                    let daysSinceAction;
                    let recordBlob = blob[data.recordID];
                    if(recordBlob.action_history != undefined && recordBlob.action_history.length > 0) {
                        // Get Last Action no matter what (could change for non-comment)
                        let lastActionRecord = recordBlob.action_history.length - 1;
                        let lastAction = recordBlob.action_history[lastActionRecord];
                        let date = new Date(lastAction?.time * 1000);

                        // We want to get date of last non-comment action so let's roll
                        if (column === 'days_since_last_step_movement') {
                            // Already have date we need if
                            //  1) Only submit
                            //  2) Last action was a manual step move
                            //  3) No records in Step Fulfillment - Completed
                            if ( (lastActionRecord > 0)
                                && (lastAction.stepID != 0 && lastAction.actionType !== 'move')
                                && (recordBlob.stepFulfillmentOnly != undefined)
                            ) {
                                // Newest addition to Step Fulfillment table is date we need
                                let lastStep = recordBlob.stepFulfillmentOnly[0];
                                date = new Date(lastStep.time * 1000);
                            }
                        }
                        daysSinceAction = Math.round((today.getTime() - date.getTime()) / 86400000);
                        if(recordBlob.submitted == 0) {
                            // if there's no submit timestamp, then it's not submitted
                            daysSinceAction = "Not Submitted";
                        }
                    }
                    else {
                        daysSinceAction = "Not Submitted";
                    }
                    document.querySelector(`#${data.cellContainerID}`).innerHTML = daysSinceAction;
                }
            });
            break;
        case 'destructionDate':
            filterData['submitted'] = 1;
            filterData['destructionAge'] = 1;
            filterData['deleted'] = 1;
            filterData['recordResolutionData'] = 1;
            leafSearch.getLeafFormQuery().join('destructionDate');
            headers.push({
                name: 'Date of Scheduled Destruction', indicatorID: 'destructionDate', editable: false, callback: function(data, blob) {
                //NOTE: requests still show if the form is disabled but there is no info from categories table
                const destructionAgeDays = blob[data.recordID]?.destructionAge || null;
                let content = '';
                if (destructionAgeDays === null) {
                    content = 'never';
                } else {
                    const destMilliseconds = destructionAgeDays * 24 * 60 * 60 * 1000;
                    const recordResolutionData = blob[data.recordID]?.recordResolutionData || null;
                    const deletionDate = blob[data.recordID].deleted * 1000;
                    //if there is no resolution data the report is either not yet fulfilled OR cancelled
                    if (recordResolutionData === null) {
                        if(deletionDate === 0) {
                            content = `${destructionAgeDays} days after resolution`;
                        } else {
                            content = new Date(deletionDate + destMilliseconds).toLocaleDateString();
                        }
                    //fulfilled requests
                    } else {
                        const fulfillmentTime = recordResolutionData.fulfillmentTime * 1000;
                        content = new Date(fulfillmentTime + destMilliseconds).toLocaleDateString();
                    }
                }
                document.querySelector(`#${data.cellContainerID}`).innerHTML = content;
            }});
            break;
        default:
            if(column.substr(0, 6) === 'depID_') { // backwards compatibility for LEAF workflow requirement based approval dates
                filterData['recordsDependencies'] = 1;
                depID = column.substr(6);
                tDepHeader[depID] = 0;
                leafSearch.getLeafFormQuery().join('recordsDependencies');
                headers.push({
                    name: 'Checkpoint Date',
                    indicatorID: column,
                    editable: false,
                    callback: function(depID) {
                    return function(data, blob) {
                        if(blob[data.recordID].recordsDependencies != undefined
                            && blob[data.recordID].recordsDependencies[depID] != undefined) {
                            var date = new Date(blob[data.recordID].recordsDependencies[depID].time * 1000);
                            document.querySelector(`#${data.cellContainerID}`).innerHTML = date.toLocaleDateString();
                            if(tDepHeader[depID] == 0) {
                                headerID = data.cellContainerID.substr(0, data.cellContainerID.indexOf('_') + 1) + 'header_' + column;
                                document.querySelector(`#${headerID}`).innerHTML = blob[data.recordID].recordsDependencies[depID].description;
                                tDepHeader[depID] = 1;
                            }
                        }
                    }
                }(depID)});
            }
            if(column.substr(0, 7) === 'stepID_') { // approval dates based on workflow steps
                filterData['stepFulfillment'] = 1;
                stepID = column.substr(7);
                tStepHeader[stepID] = 0;
                leafSearch.getLeafFormQuery().join('stepFulfillment');
                headers.push({
                    name: 'Checkpoint Date',
                    indicatorID: column,
                    editable: false,
                    callback: function(stepID) {
                    return function(data, blob) {
                        if(blob[data.recordID].stepFulfillment != undefined
                            && blob[data.recordID].stepFulfillment[stepID] != undefined) {
                            var date = new Date(blob[data.recordID].stepFulfillment[stepID].time * 1000);
                            document.querySelector(`#${data.cellContainerID}`).innerHTML = date.toLocaleDateString();

                            if(tStepHeader[stepID] == 0) {
                                headerID = data.cellContainerID.substr(0, data.cellContainerID.indexOf('_') + 1) + 'header_' + column;
                                document.querySelector(`#${headerID}`).innerHTML = blob[data.recordID].stepFulfillment[stepID].step;
                                tStepHeader[stepID] = 1;
                            }
                        }
                    }
                }(stepID)});
            }
            break;
    }
}

var resIndicatorList = { };
var searchPrereqsLoaded = false;
function loadSearchPrereqs() {
    if(searchPrereqsLoaded == true) {
        return;
    }
    searchPrereqsLoaded = true;
    $.ajax({
        type: 'GET',
        url: './api/form/indicator/list?x-filterData=name,indicatorID,categoryID,categoryName,parentCategoryID,parentStaples,isDisabled',
        dataType: 'text json',
        success: function(res) {
            var buffer = '';


            // special columns
            buffer += '<div class="col span_1_of_3">';
            buffer += '<div class="indicatorOption"><label class="checkable leaf_check" for="indicators_title">';
            buffer += '<input type="checkbox" class="icheck leaf_check" id="indicators_title" name="indicators[title]" value="title" /><span class="leaf_check"></span> Title of Request</label></div>';
            buffer += '<div class="indicatorOption"><label class="checkable leaf_check" for="indicators_service">';
            buffer += '<input type="checkbox" class="icheck leaf_check" id="indicators_service" name="indicators[service]" value="service" /><span class="leaf_check"></span> Service</label></div>';
            buffer += '<div class="indicatorOption"><label class="checkable leaf_check" for="indicators_type">';
            buffer += '<input type="checkbox" class="icheck leaf_check" id="indicators_type" name="indicators[type]" value="type" /><span class="leaf_check"></span> Type of Request</label></div>';
            buffer += '<div class="indicatorOption"><label class="checkable leaf_check" for="indicators_status">';
            buffer += '<input type="checkbox" class="icheck leaf_check" id="indicators_status" name="indicators[status]" value="status" /><span class="leaf_check"></span> Current Status</label></div>';
            buffer += '<div class="indicatorOption"><label class="checkable leaf_check" for="indicators_initiator">';
            buffer += '<input type="checkbox" class="icheck leaf_check" id="indicators_initiator" name="indicators[initiator]" value="initiator" /><span class="leaf_check"></span> Initiator</label></div>';
            buffer += '<div class="indicatorOption"><label class="checkable leaf_check" for="indicators_actionButton">';
            buffer += '<input type="checkbox" class="icheck leaf_check" id="indicators_actionButton" name="indicators[actionButton]" value="actionButton" /><span class="leaf_check"></span> Action Button</label></div>';
            buffer += '<div class="indicatorOption"><label class="checkable leaf_check" for="indicators_action_history">';
            buffer += '<input type="checkbox" class="icheck leaf_check" id="indicators_action_history" name="indicators[action_history]" value="action_history" /><span class="leaf_check"></span> Comment History</label></div>';
            buffer += '<div class="indicatorOption"><label class="checkable leaf_check" for="indicators_approval_history">';
            buffer += '<input type="checkbox" class="icheck leaf_check" id="indicators_approval_history" name="indicators[approval_history]" value="approval_history" /><span class="leaf_check"></span> Approval History</label></div>';
            buffer += '<div class="indicatorOption"><label class="checkable leaf_check" for="indicators_days_since_last_action">';
            buffer += '<input type="checkbox" class="icheck leaf_check" id="indicators_days_since_last_action" name="indicators[days_since_last_action]" value="days_since_last_action" /><span class="leaf_check"></span> Days Since Last Action</label></div>';
            buffer += '<div class="indicatorOption"><label class="checkable leaf_check" for="indicators_days_since_last_step_movement">';
            buffer += '<input type="checkbox" class="icheck leaf_check" id="indicators_days_since_last_step_movement" name="indicators[days_since_last_step_movement]" value="days_since_last_step_movement" /><span class="leaf_check"></span> Days Since Last Step Movement</label></div>';
            buffer += '</div>';

            var groupList = {};
            var groupNames = [];
            var groupIDmap = {};
            var tmp = document.createElement('div');
            let grid = {};

            for(let i in res) {
                resIndicatorList[res[i].indicatorID] = scrubHTML(res[i].name);

                if(groupList[res[i].categoryID] == undefined) {
                    groupList[res[i].categoryID] = [];
                }
                groupList[res[i].categoryID].push(res[i].indicatorID);
                if(groupIDmap[res[i].categoryID] == undefined) {
                    groupNames.push({
                        categoryID: res[i].categoryID,
                        categoryName: res[i].categoryName
                    });
                    groupIDmap[res[i].categoryID] = { };
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

            for(let k in groupNames) {
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
                buffer += '<div tabindex="0" class="form category '+ associatedCategories +'" style="width: 250px; float: left; min-height: 30px; margin-bottom: 4px"><div class="formLabel buttonNorm"><img src="dynicons/?img=gnome-zoom-in.svg&w=32" alt=""/> ' + categoryLabel + '</div>';
                for(let j in groupList[i]) {
                    const indID = groupList[i][j];
                    const isDisabled = res.find(ele => ele.indicatorID === indID).isDisabled;
                    const isArchivedClass = isDisabled > 0 ? ' is-archived' : '';
                    const isArchivedText = isDisabled > 0 ? ' (Archived)' : '';

                    buffer += `<div class="indicatorOption${isArchivedClass}" id="indicatorOption_${indID}" style="display: none"><label class="checkable leaf_check" for="indicators_${indID}" title="indicatorID: ${indID}\n${resIndicatorList[indID]}${isArchivedText}" >`;
                    buffer += `<input type="checkbox" class="icheck leaf_check parent" id="indicators_${indID}" name="indicators[${indID}]" value="${indID}" />`
                    buffer += `<span class="leaf_check"></span> ${resIndicatorList[indID]}${isArchivedText}</label>`;
                    // sub checklist for case of grid indicator
                    const format = res.find(i => i.indicatorID === indID)?.format;
                    if (format && format.indexOf('grid')===0) {
                        const cols = JSON.parse(format.slice(format.indexOf('\n')));
                        for (let c in cols) {
                            const col = cols[c];
                            buffer += `<div class="subIndicatorOption" style="display: none"><label class="checkable leaf_check" for="indicators_${indID}_columns_${col.id}" title="columnID: ${col.id}\n${col.name}">`;
                            buffer += `<input type="checkbox" class="icheck leaf_check parent-indicators_${indID}" id="indicators_${indID}_columns_${col.id}" name="indicators[${indID}].columns[${col.name}]" value="${col.id}" gridParent="${indID}" />`;
                            buffer += `<span class="leaf_check"></span> ${col.name}</label></div>`;
                        }
                    }
                    buffer += '</div>';
                }
                buffer += '</div>';
            }
            buffer += '</div>';

            $('#indicatorList').html(buffer);

            $('#indicatorList').css('height', $(window).height() - 240);

            //toggle all subcheckboxes with parent indicator checkbox
            $('.indicatorOption > label > input').on('change', function() {
                const indicatorIsChecked = this.checked;
                $(`input[id^="indicators_${this.value}_columns"]`).prop('checked', indicatorIsChecked);
            });
            //check parent if any subcheckbox is checked, uncheck if none are checked
            $('.subIndicatorOption > label > input').on('change', function() {
                const indicatorID = this.getAttribute('gridparent');
                const siblings = Array.from($(`input[id^="indicators_${indicatorID}_columns"]`));
                const atLeastOneChecked = siblings.some(sib => sib.checked === true);
                if(atLeastOneChecked) {
                    $(`#indicators_${indicatorID}`).prop('checked', true);
                } else $(`#indicators_${indicatorID}`).prop('checked', false);
            });

            $('.form').on('keydown', function(event) {
                if (event.keyCode === 13) {
                    $(this).children('.formLabel').removeClass('buttonNorm');
                    $(this).find('.formLabel>img').css('display', 'none');
                    $(this).css({width: '100%'});
                    $(this).children('div').css('display', 'block');
                    $(this).children('div').children('.subIndicatorOption').css('display', 'block');
                    $(this).children('.formLabel').css({'border-bottom': '1px solid #e0e0e0',
                        'font-weight': 'bold'});
                }
            });

            $('.form').on('click', function() {
                $(this).children('.formLabel').removeClass('buttonNorm');
                $(this).find('.formLabel>img').css('display', 'none');
                $(this).css({width: '100%'});
                $(this).children('div').css('display', 'block');
                $(this).children('div').children('.subIndicatorOption').css('display', 'block');
                $(this).children('.formLabel').css({'border-bottom': '1px solid #e0e0e0',
                    'font-weight': 'bold'});
            });

            $.ajax({
                type: 'GET',
                url: './api/workflow/steps?x-filterData=workflowID,stepID,stepTitle,description',
                dataType: 'json',
                success: function(res) {
                    let allStepsData = res;
                    buffer = '';
                    buffer += '<div class="form col span_1_of_3" style="min-height: 30px; margin: 4px"><div class="formLabel" style="border-bottom: 1px solid #e0e0e0; font-weight: bold">Checkpoint Dates<br />(Data only available from May 3, 2017)</div>';
                    for(let i in allStepsData) {
                        buffer += '<div class="indicatorOption"><label class="checkable leaf_check" for="indicators_stepID_'+ allStepsData[i].stepID +'" title="'+ allStepsData[i].stepTitle +'">';
                        buffer += '<input type="checkbox" class="icheck leaf_check" id="indicators_stepID_'+ allStepsData[i].stepID +'" name="indicators[stepID'+ allStepsData[i].stepID +']" value="stepID_'+ allStepsData[i].stepID +'" />'
                        buffer += '<span class="leaf_check"></span> '+ allStepsData[i].description + ' - ' + allStepsData[i].stepTitle +'</label></div>';
                    }
                    buffer += '<div id="legacyDependencies"></div>'; // backwards compat
                    buffer += '</div>';

                    $('#indicatorList').append(buffer);

                    $.ajax({
                        type: 'GET',
                        url: './api/workflow/dependencies',
                        dataType: 'json',
                        success: function(res) {
                            buffer2 = '';
                            buffer2 += '<div><br /><br /><div class="formLabel" style="border-bottom: 1px solid #e0e0e0; font-weight: bold">Action Dates (step requirements)</div>';

                            // Option to retrieve Date Request Initiated / Resolved
                            buffer2 += '<div id="option_dateCancelled" class="indicatorOption"><label class="checkable leaf_check" for="indicators_dateCancelled" title="Date request Cancelled">';
                            buffer2 += '<input type="checkbox" class="icheck leaf_check" id="indicators_dateCancelled" name="indicators[dateCancelled]" value="dateCancelled" /><span class="leaf_check"></span> Date Request Cancelled</label></div>';
                            buffer2 += '<div class="indicatorOption"><label class="checkable leaf_check" for="indicators_dateInitiated" title="Date request initiated">';
                            buffer2 += '<input type="checkbox" class="icheck leaf_check" id="indicators_dateInitiated" name="indicators[dateInitiated]" value="dateInitiated" /><span class="leaf_check"></span> Date Request Initiated</label></div>';
                            buffer2 += '<div class="indicatorOption"><label class="checkable leaf_check" for="indicators_dateResolved" title="Date request resolved">';
                            buffer2 += '<input type="checkbox" class="icheck leaf_check" id="indicators_dateResolved" name="indicators[dateResolved]" value="dateResolved" /><span class="leaf_check"></span> Date Request Resolved</label></div>';
                            buffer2 += '<div class="indicatorOption"><label class="checkable leaf_check" for="indicators_resolvedBy" title="Resolved By">';
                            buffer2 += '<input type="checkbox" class="icheck leaf_check" id="indicators_resolvedBy" name="indicators[resolvedBy]" value="resolvedBy" /><span class="leaf_check"></span> Resolved By</label></div>';
                            buffer2 += '<div class="indicatorOption"><label class="checkable leaf_check" for="indicators_destruction">';
                            buffer2 += '<input type="checkbox" class="icheck leaf_check" id="indicators_destruction" name="indicators[destructionDate]" value="destructionDate" /><span class="leaf_check"></span> Date of Scheduled Destruction</label></div>';

                            for(let i in res) {
                                buffer2 += '<div class="indicatorOption"><label class="checkable leaf_check" for="indicators_depID_'+ res[i].dependencyID +'">';
                                buffer2 += '<input type="checkbox" class="icheck leaf_check" id="indicators_depID_'+ res[i].dependencyID +'" name="indicators[depID_'+ res[i].dependencyID +']" value="depID_'+ res[i].dependencyID +'" /><span class="leaf_check"></span> ' + res[i].description +'</label></div>';
                            }
                            buffer2 += '</div>';

                            $('#legacyDependencies').append(buffer2);

                            // write buffer and finalize view
                            //$('#indicatorList').append(buffer);

                            // set user selections
                            if(t_inIndicators != undefined) {
                                for(let i in t_inIndicators) {
                                    $('#indicators_' + t_inIndicators[i].indicatorID).prop('checked', true);

                                    if (t_inIndicators[i].cols !== undefined) {
                                        for (var j in t_inIndicators[i].cols) {
                                            $('#indicators_' + t_inIndicators[i].indicatorID + '_columns_' + t_inIndicators[i].cols[j]).prop('checked', true);
                                        }
                                    }
                                }
                            }
                            else {
                                // pre-select defaults
                                $('#indicators_title').prop('checked', true);
                            }

                        }
                    });
                }
            });
        }
    });
}

//loop through headers array, and if its ID exists as a key on
//the gridColor data object, updates background and text color
//called at Edit Label's 'save' and report page load
function updateHeaderColors(){
    headers.forEach(function(header) {
        if (gridColorData.hasOwnProperty(header.indicatorID)) {
            let bg_color = gridColorData[header.indicatorID];
            //IE uses text inputs. Allows only #<6digithex>
            if (!/^#[0-9a-f]{6}$/i.test(bg_color)){
                gridColorData[header.indicatorID] = '#D1DFFF';
                bg_color = '#D1DFFF';
            }
            let elHeader = document.getElementById(grid.getPrefixID() + "header_" + header.indicatorID);
            let arrRGB = [];  //convert from hex to RGB
            for (let i = 1; i < 7; i += 2) {
                arrRGB.push(parseInt(bg_color.slice(i, i + 2), 16));
            }
            let maxVal = Math.max(arrRGB[0],arrRGB[1],arrRGB[2]); //IE dies with spread op
            let sum = arrRGB.reduce(function(total, currentVal){
                return total + currentVal;
            });
            //pick text color based on bgcolor, apply to headers
            let textColor = maxVal < 128 || (sum < 350 && arrRGB[1] < 225) ? 'white' : 'black';
            elHeader.style.setProperty('background-color', bg_color);
            elHeader.style.setProperty('color', textColor);
        }
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

    for(let i in resSelectList) {
        if(resIndicatorList[resSelectList[i]] != undefined) {
            buffer += `<tr id="sortID_${resSelectList[i]}">
                <td>
                    <input type="color" aria-label="select header background color" id="colorPicker${resSelectList[i]}" value="#d1dfff" style="height: 26px;" />
                    <input type="text" aria-label="edit header column text" style="min-width: 400px" id="id_${resSelectList[i]}" value="${resIndicatorList[resSelectList[i]]}"/>
                </td>
                <td>
                    <button type="button" aria-label="move column down" class="buttonNorm" onclick="editLabels_down(${resSelectList[i]});"><img src="./dynicons/?img=go-down_red.svg&w=16" /></button>
                    <button type="button" aria-label="move column up" class="buttonNorm" onclick="editLabels_up(${resSelectList[i]});"><img src="./dynicons/?img=go-up.svg&w=16" /></button>
                </td>
                </tr>`;
        }
    }
    buffer += '</table>';
    dialog.setContent(buffer);
    dialog.show();

    resSelectList.map(function(checkedIndicator) {
        if(resIndicatorList[checkedIndicator] != undefined) {
            let elInput = document.getElementById("colorPicker" + checkedIndicator);
            //update inputs and tempColors to the current colors if they have been set
            if (gridColorData.hasOwnProperty(checkedIndicator)){
                elInput.value = gridColorData[checkedIndicator];
                tempColorData[checkedIndicator] = gridColorData[checkedIndicator]; //primitive
            }
            //update temp color object on change
            elInput.addEventListener('change', function () {
                tempColorData[checkedIndicator] = elInput.value;
            });
        }
    });

    dialog.setSaveHandler(function() {
        $('#labelSorter tr').each(function(i) {
            var curID = this.id.substr(7);
            indicatorSort[curID] = i + 1;
        });
        var tmp = document.createElement('div');
        for(let i in resSelectList) {
            if(resIndicatorList[resSelectList[i]] != undefined) {
                resIndicatorList[resSelectList[i]] = scrubHTML($('#id_' + resSelectList[i]).val());
            }
        }
        gridColorData = Object.assign({ }, tempColorData);
        if(Object.keys(gridColorData).length !== 0) {
            updateHeaderColors();
            let baseURL = window.location.href.substr(0, window.location.href.indexOf('&'));
            buildURLComponents(baseURL);
        }
        tempColorData = Object.assign({ }, gridColorData);

        grid.stop();
        $('#generateReport').click();
        dialog.hide();
    });
}

function isSearchingDeleted(searchObj) {
    // check if the user explicitly wants to find deleted requests
    var t = searchObj.getLeafFormQuery().getQuery();
    var searchDeleted = false;
    for(let i in t.terms) {
        if(t.terms[i].id === 'stepID'
            && t.terms[i].match === 'deleted'
            && t.terms[i].operator === '=') {

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
    var pwd = document.URL.substr(0,document.URL.lastIndexOf('?'));
    var reportLink = document.URL.substr(document.URL.lastIndexOf('?') - 1);

    dialog_message.setTitle('Share Report');
    dialog_message.setContent('<p>This link can be shared to provide a live view into this report.</p>'
                            + '<br /><textarea id="reportLink" style="width: 95%; height: 100px">'+ pwd + reportLink +'</textarea>'
                            + '<button id="prepareEmail" type="button" class="buttonNorm"><img src="dynicons/?img=internet-mail.svg&w=32" alt="" /> Email Report</button> '
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
    let pwd = document.URL.substr(0,document.URL.lastIndexOf('?'));
    let query = leafSearch.getLeafFormQuery().getQuery();
    delete query.limit;
    delete query.limitOffset;
    let queryString = JSON.stringify(query);
    let xFilterData = '&x-filterData=recordID,'+ Object.keys(filterData).join(',');
    let jsonPath = pwd + leafSearch.getLeafFormQuery().getRootURL() + 'api/form/query/?q=' + queryString + xFilterData;
    let powerQueryURL = '<!--{$powerQueryURL}-->' + window.location.pathname;

    dialog_message.setTitle('Data Endpoints');
    dialog_message.setContent('<p>This provides a live data source for custom dashboards or automated programs.</p><br />'
                           + '<button id="shortenLink" class="buttonNorm" style="float: right">Shorten Link</button>'
                           + '<button id="expandLink" class="buttonNorm" style="float: right; display: none">Expand Link</button>'
                           + '<button id="copy" class="buttonNorm" style="float: right">Copy to Clipboard</button>'
                           + '<select id="format">'
                           + '<option value="json">JSON</option>'
                           + '<option value="htmltable">HTML Table</option>'
                           + '<option value="jsonp">JSON-P</option>'
                           + '<option value="csv">CSV</option>'
                           + '<option value="xml">XML</option>'
                           + '<option value="debug">Plaintext</option>'
                           + '<option value="leafFormQuery">JavaScript Template</option>'
                           + '<option value="x-visualstudio">Visual Studio (testing)</option>'
                           + '</select>'
                           + '<span id="formatStatus" style="background-color:green; padding:5px 5px; color:white; display:none;"></span>'
                           + '<br /><div id="exportPathContainer" contenteditable="true" spellcheck="false" style="border: 1px solid gray; padding: 4px; margin-top: 4px; width: 95%; min-height: 100px; word-break: break-all;"><span id="exportPath">'+ jsonPath +'</span><span id="exportFormat"></span></div>'
                           + '<a href="report.php?a=LEAF_Data_Dictionary" target="_blank">Data Dictionary Reference</a>'
                           + '<br /><br />'
                           + '<fieldset>'
                           + '<legend>Options</legend>'
                           + '<input id="msCompatMode" type="checkbox" /><label for="msCompatMode">Use compatibility mode (Excel, Access, etc.)</label>'
                           + '</fieldset>');

    $('#msCompatMode').on('click', function() {
        $('#shortenLink').click();

    });

    function setExportFormat() {
        if($('#shortenLink').css('display') === 'none') {
            $('#exportFormat').html('?');
        }
        else {
            $('#exportFormat').html('&');
        }


        switch($('#format').val()) {
            case 'json':
                $('#exportFormat').html('');
                document.querySelector('#exportPath').style.display = 'inline';
                break;
            case 'leafFormQuery':
                let buffer = "<scr"+"ipt>\n";
                buffer += `async function main() {
                    \u00A0\u00A0\u00A0\u00A0let query = new LeafFormQuery();
                    \u00A0\u00A0\u00A0\u00A0query.importQuery(${queryString});
                    \u00A0\u00A0\u00A0\u00A0query.setExtraParams("${xFilterData}"); // minimizes network utilization
                    \u00A0\u00A0\u00A0\u00A0let results = await query.execute();
                    \u00A0\u00A0\u00A0\u00A0// Do something with the results
                    }
                    document.addEventListener('DOMContentLoaded', main);\n`;
                buffer += "</scr"+"ipt>";
                document.querySelector('#exportFormat').innerText = buffer;
                document.querySelector('#exportPath').style.display = 'none';
                break;
            default:
                document.querySelector('#exportPath').style.display = 'inline';
                $('#exportFormat').append('format=' + $('#format').val());
                $("#formatStatus").show().text("Format changed to " + $('#format').val());
                $("#formatStatus").fadeOut(3000);
                break;
        }
    }

    function selectExample() {
        let selection = window.getSelection();
        let range = document.createRange();
        range.selectNodeContents(document.querySelector('#exportPathContainer'));
        selection.removeAllRanges();
        selection.addRange(range);
        return selection;
    }

    document.querySelector('#copy').addEventListener('click', () => {
        navigator.clipboard.writeText(selectExample().focusNode.innerText);
        $("#formatStatus").show().text("Copied!");
        $("#formatStatus").fadeOut(3000);
    });

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
            $('#exportPath').html(pwd + leafSearch.getLeafFormQuery().getRootURL() + 'api/open/form/query/_' + res + '?x-filterData=recordID,'+ Object.keys(filterData).join(','));
           if($('#msCompatMode').is(':checked')) {
                $('#expandLink').css('display', 'none');
                $('#exportPath').html(powerQueryURL + 'api/open/form/query/_' + res + '?x-filterData=recordID,'+ Object.keys(filterData).join(','));
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

/**
 * Purpose: Update Request Titles
*/

 function changeTitle(form_data, current_title) {
    dialog.setContent('<label for="recordTitle"><b>Report Title</b></label><br/><input type="text" id="recordTitle" style="width: 250px" name="recordTitle" value="' + current_title + '" /><input type="hidden" id="CSRFToken" name="CSRFToken" value="<!--{$CSRFToken}-->" />');
    dialog.show();
    dialog.setSaveHandler(function() {
        $.ajax({
            type: 'POST',
            url: 'api/form/' + form_data.recordID + '/title',
            data: {title: $('#recordTitle').val(),
                    CSRFToken: '<!--{$CSRFToken}-->'},
            success: function(res) {
                if(res != null) {
                    $('#' + form_data.cellContainerID).fadeOut(400);
                    $('#' + form_data.cellContainerID).empty().html(res);
                    $('#' + form_data.cellContainerID).fadeIn(400);

                }
                dialog.hide();
            }
        });
    });
}

/**
 * Purpose: Create New Row Requests
 * @param catID - Form ID passing in for new request
 * @return - Creates new request inline on grid
 */
function createRequest(catID) {
    if (!clicked) {
        $('#newRecordWarning').css('display', 'none');
        catID = catID || 'strCatID';
        const portalAPI = LEAFRequestPortalAPI();
        portalAPI.setBaseURL('./api/?a=');
        portalAPI.setCSRFToken(CSRFToken);

        if (catID !== 'strCatID') {
            portalAPI.Forms.newRequest(
                catID,
                    {title: 'untitled'},
                function (recordID) {
                    recordID = recordID || 0;
                    //Type number. Sent back on success (UID column of report builder)
                    if (recordID > 0) {
                        newRecordID = parseInt(recordID);  //global
                        $('#generateReport').click();
                        dialog.hide();
                        //styling to hilite row for short / simple queries
                        setTimeout(function () {
                            let el_ID = grid.getPrefixID() + "tbody_tr" + recordID;
                            let newRow = document.getElementById(el_ID);
                            if (newRow !== null) { //null if query > .75s or if the query does not return the record created
                                newRow.style.backgroundColor = 'rgb(254, 255, 209)';
                            }
                        }, 750);
                    }
                },
                function (error) {
                    if (error) {
                        alert('New Request could not be processed');
                        dialog.hide();
                    }
                }
            );
        }
    }
    clicked = true;
}


var url, urlQuery, urlIndicators;
let urlColorData = 'str';
var leafSearch;
var headers = [];
var t_inIndicators;
var isNewQuery = false;
var dialog, dialog_message, dialog_confirm;
var indicatorSort = {}; // object = indicatorID : sortID
var grid;
let gridColorData = {}; //object updated with id: color
let tempColorData = {}; //object updated with id: color
let sortPreference = {}; // store current sorting preference
let isOneFormType = false;

/**
 * Purpose: Check if only one type of form could logically be returned and,
 * if so, update global variables isOneFormType (bool) and categoryID (string).
 * @param searchQueryTerms - variable with result of leafSearch.getLeafFormQuery().getQuery().terms (array)
 */
function checkIfOneTypeSearchedAndUpdate(searchQueryTerms) {
    searchQueryTerms = searchQueryTerms || 0;
    isOneFormType = false;   //global
    categoryID = 'strCatID'; //global
    if (searchQueryTerms !== 0 && searchQueryTerms.length > 0) {
        let boolGateCheck = false;
        let categoriesSearched = searchQueryTerms.filter(function (term) {
            return term.id === "categoryID";
        });

        //search must be limited to one Type, and its operator must be "=", additionally search differs based on location:
        //If Type is the first criteria, all gates must be AND. If not, only its own gate must be AND.
        //example: 'type IS <form> OR title is <title>', VS 'title IS <title> OR <other search> AND type IS <form>'
        if (categoriesSearched.length === 1 && categoriesSearched[0].operator === "=") {
            if (searchQueryTerms[0].id === "categoryID") {  //if it's the first search criteria
                boolGateCheck = searchQueryTerms.every(function (term) {
                    return term.gate === "AND";
                });
            } else {
                boolGateCheck = (categoriesSearched[0].gate === "AND");
            }
            if (boolGateCheck) {
                isOneFormType = true; //global
                categoryID = categoriesSearched[0].match; //global
            }
        }
    }
}

var version = 3;
/* URL formats
    * v1 - base64
    * v2 - lz-string in base64
    * v3 - uses getData() from formQuery.js
*/

// Update window title
function updateTitle(title) {
    if(title != '') {
        let siteName = document.querySelector('#headerDescription')?.innerText;
        let siteLocation = document.querySelector('#headerLabel')?.innerText;
        if(siteName == undefined) {
            document.querySelector('title').innerText = scrubHTML(`${title}`);
        }
        else {
            document.querySelector('title').innerText = scrubHTML(`${title} - ${siteName} | ${siteLocation}`);
        }
    }
}

/**
 * Generates a url based on the current report preferences
 * @param baseURL URL of this script, without parameters
 * @param update (optional) bool - update an existing URL
 */
function buildURLComponents(baseURL, update){
    url = baseURL + '&v='+ version + '&query=' + encodeURIComponent(urlQuery) + '&indicators=' + encodeURIComponent(urlIndicators);

    if(update != undefined) {
        let urlParams = new URLSearchParams(window.location.search);
        url = baseURL + '&v='+ version + '&query=' + urlParams.get('query') + '&indicators=' + urlParams.get('indicators');
    }

    if (Object.keys(gridColorData).length !== 0){
        urlColorData = LZString.compressToBase64(JSON.stringify(gridColorData));
        url += '&colors=' + encodeURIComponent(urlColorData);
    }
    if(Object.keys(sortPreference).length != 0) {
        let urlSortPreference = LZString.compressToBase64(JSON.stringify(sortPreference));
        url += '&sort=' + encodeURIComponent(urlSortPreference);
    }
    if($('#reportTitle').val() != '') {
        updateTitle($('#reportTitle').val());
        url += '&title=' + encodeURIComponent(btoa($('#reportTitle').val()));
    }
    window.history.pushState('', '', url);
}

var clicked = false;
var newRecordID = 0;
$(function() {
	dialog = new dialogController('xhrDialog', 'xhr', 'loadIndicator', 'button_save', 'button_cancelchange');
	dialog_confirm = new dialogController('confirm_xhrDialog', 'confirm_xhr', 'confirm_loadIndicator', 'confirm_button_save', 'confirm_button_cancelchange');
    dialog_message = new dialogController('genericDialog', 'genericDialogxhr', 'genericDialogloadIndicator', 'genericDialogbutton_save', 'genericDialogbutton_cancelchange');
    dialog_ok = new dialogController('ok_xhrDialog', 'ok_xhr', 'ok_loadIndicator', 'confirm_button_ok', 'confirm_button_cancelchange');
    leafSearch = new LeafFormSearch('searchContainer');
    leafSearch.setJsPath('<!--{$app_js_path}-->');
    leafSearch.setOrgchartPath('<!--{$orgchartPath}-->');
    leafSearch.renderUI();

    $('#' + leafSearch.getPrefixID() + 'searchIcon').toggle();

    $('#' + leafSearch.getPrefixID() + 'advancedSearchButton').click();
    $('#' + leafSearch.getPrefixID() + 'advancedOptions').css('border', '0');
    $('#' + leafSearch.getPrefixID() + 'advancedOptionsClose').css('visibility', 'hidden');
    $('#' + leafSearch.getPrefixID() + 'advancedOptions>legend').css('display', 'none');
    $('#' + leafSearch.getPrefixID() + 'advancedSearchApply').html('Next Step <img src="dynicons/?img=go-next.svg&w=32" alt="" />');

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

        for(let i in tTerms) {
            if(tTerms[i].id === 'categoryID'
                && tTerms[i].operator === '=') {
                filteredCategories.push(tTerms[i].match);
            }

            // hide dateCancelled option unless it's being searched for
            if(tTerms[i].id === 'stepID'
                && tTerms[i].operator === '='
                && tTerms[i].match === 'deleted') {
                showOptionCancelled = true;
            }
        }
        if(filteredCategories.length > 0) {
            $('.category').css('display', 'none');
            for(let i in filteredCategories) {
                $('.' + filteredCategories[i]).css('display', 'inline');
            }
        }
        else {
            $('.category').css('display', 'inline');
        }

        if(showOptionCancelled) {
            $('#option_dateCancelled').css('display', 'block');
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
    grid.setPostSortRequestFunc((key, order) => {
        sortPreference = {key: key, order: order};
        let baseURL = window.location.href.substr(0, window.location.href.indexOf('&'));
        buildURLComponents(baseURL, true);
    });
    var extendedToolbar = false;
    $('#generateReport').off();
    $('#generateReport').on('click', async function() {
        $('#results').fadeIn(700);
        $('#saveLinkContainer').fadeIn(700);
        $('#step_2').slideUp(700);
        $('#newRecordWarning').css('display', 'none');
        if(isNewQuery) {
            leafSearch.generateQuery();

            if(!isSearchingDeleted(leafSearch)) {
                leafSearch.getLeafFormQuery().addTerm('deleted', '=', 0);
            }
            headers = [];
        }
        else if(!isSearchingDeleted(leafSearch)) {
            leafSearch.getLeafFormQuery().addTerm('deleted', '=', 0);
        }

        selectedIndicators = [];
        resSelectList = [];
        $('.leaf_check:checked').each(function() {
            let gridParent = this.attributes.gridparent?.value;
            if (gridParent !== undefined) {
                let dest = resSelectList.indexOf(gridParent);

                if (dest !== -1) {
                    resSelectList[dest] = [resSelectList[dest]];
                } else {
                    for (let i in resSelectList) {
                        if (resSelectList[i][0] === gridParent) {
                            dest = i;
                        }
                    }
                }
                resSelectList[dest].push(this.value);
            } else {
                resSelectList.push(this.value);
            }
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

        for(let i in resSelectList) {
            let temp = {};
            if (Array.isArray(resSelectList[i])) {
                temp.indicatorID = resSelectList[i][0];
                temp.cols = [];
                for (let j = 1; j < resSelectList[i].length; j++) {
                    temp.cols.push(resSelectList[i][j]);
                }
            } else {
                temp.indicatorID = resSelectList[i];
            }
            temp.name = resIndicatorList[temp.indicatorID] != undefined ? resIndicatorList[temp.indicatorID] : '';
            temp.sort = indicatorSort[temp.indicatorID] == undefined ? 0 : indicatorSort[temp.indicatorID];
            temp.name = scrubHTML(temp.name);
            if($.isNumeric(resSelectList[i][0]) || $.isNumeric(resSelectList[i])) {
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

        function renderGrid(res) {
            grid.setDataBlob(res);

            if(<!--{$version}--> >= 3) {
                let sortKey = 'recordID';
                let sortDirection = 'desc';
                if(sortPreference.key != undefined && sortPreference.order != undefined) {
                    sortKey = sortPreference.key;
                    sortDirection = sortPreference.order;
                }
                grid.sort(sortKey, sortDirection);
                grid.renderBody();
            }
            else {
                let recordIDs = '';
                for (let i in res) {
                    recordIDs += res[i].recordID + ',';
                }
                grid.loadData(recordIDs);
            }
            let gridResults = grid.getCurrentData();
            let filteredGridResults = gridResults.filter(function(r) {
                return r.categoryID != undefined;
            });
            //if catID info is available for the results, it can be used to determine form type.
            if (filteredGridResults.length > 0) {
                categoryID = filteredGridResults[0].categoryID;
                isOneFormType = filteredGridResults.every(function(fr) {
                    return fr.categoryID === categoryID;
                });
            }
            if (isOneFormType){
                $('#newRequestButton').css('display', 'inline-block');
            } else {
                $('#newRequestButton').css('display', 'none');
            }
            let reportHasNewRecord = gridResults.some(function(obj){
                return obj.recordID === newRecordID;
            })
            if (newRecordID !== 0 && clicked === true && !reportHasNewRecord){
                $('#newRecordWarning').css('display', 'block');
            }
            clicked = false; //global to reduce dblclicks
        }

        let abortController = new AbortController();
        let queryResult = {};
        let abortLoad = false;
        let masquerade = '';
        let urlParams = new URLSearchParams(window.location.search);
        let addMasqueradeParam = '';
        urlMasqueradeParam = urlParams.get('masquerade');
        if(urlMasqueradeParam == 'nonAdmin') {
            addMasqueradeParam = '&masquerade=nonAdmin';
        }

        document.querySelector('#btn_abort').style.display = 'inline';
        document.querySelector('#btn_abort').addEventListener('click', function() {
            abortController.abort();
            abortLoad = true;
        });

        // show top results asap
        document.querySelector('#reportStats').innerText = `Loading...`;
        let queryFirstBatch = new LeafFormQuery();
        queryFirstBatch.setQuery(structuredClone(leafSearch.getLeafFormQuery().getQuery()));
        queryFirstBatch.sort('recordID', 'DESC');
        queryFirstBatch.setLimit(50);
        queryFirstBatch.setExtraParams('&x-filterData=recordID,'+ Object.keys(filterData).join(',') + addMasqueradeParam);
        let firstBatch = await queryFirstBatch.execute();
        renderGrid(firstBatch);

        leafSearch.getLeafFormQuery().setBatchSize(1000);
        leafSearch.getLeafFormQuery().setLimit(Infinity); // Backward compat: limit shouldn't exist
        leafSearch.getLeafFormQuery().setExtraParams('&x-filterData=recordID,'+ Object.keys(filterData).join(',') + addMasqueradeParam);
        leafSearch.getLeafFormQuery().setAbortSignal(abortController.signal);
        leafSearch.getLeafFormQuery().onProgress(progress => {
            document.querySelector('#reportStats').innerText = `Loading ${progress}+ records`;
            document.querySelector(`#${grid.getPrefixID()}tfoot`).innerHTML = `<tr>
                <td colspan="${grid.getNumHeaders()}" style="padding: 8px; font-size: 120%; font-weight: bold">
                <img src="./images/indicator.gif" style="vertical-align: middle" alt="" /> Loading ${progress}+ records
                </td>
            </tr>`;
        });

        // get data
        leafSearch.getLeafFormQuery().execute().then(queryResult => {
            let partialLoad = '';
            if(abortLoad) {
                partialLoad = ' (partially loaded)';
            }
            document.querySelector('#btn_abort').style.display = 'none';
            $('#reportStats').html(`${Object.keys(queryResult).length} records${partialLoad}`);
            renderGrid(queryResult);
            //update Checkpoint Date Step header text if still needed (should be rare)
            if(tStepHeader.some(ele => ele === 0)) {
                $.ajax({
                    type: 'GET',
                    url: './api/workflow/steps?x-filterData=workflowID,stepID,stepTitle,description',
                    dataType: 'json',
                    success: (res) => {
                        let div = document.createElement('div');
                        res.forEach(step => {
                            if(tStepHeader[step.stepID] === 0) {
                                const title = XSSHelpers.stripAllTags($(div).html(step.stepTitle || "").text());
                                $('#' + grid.getPrefixID() + 'header_stepID_' + step.stepID).text(title);
                                tStepHeader[step.stepID] = 1;
                            }
                        });

                    },
                    error: (err) => console.log(err),
                });
            }
        });

        // create save link once
        if(!extendedToolbar) {
            $('#' + grid.getPrefixID() + 'gridToolbar').prepend('<button type="button" class="buttonNorm" onclick="openShareDialog()"><img src="dynicons/?img=internet-mail.svg&w=32" alt="" /> Share Report</button> ');
            $('#' + grid.getPrefixID() + 'gridToolbar').prepend('<button type="button" id="editLabels" class="buttonNorm" onclick="editLabels()"><img src="dynicons/?img=accessories-text-editor.svg&w=32" alt="" /> Edit Labels</button> ');

            $('#' + grid.getPrefixID() + 'gridToolbar').css('width', '100%');
            $('#' + grid.getPrefixID() + 'gridToolbar').prepend('<button type="button" class="buttonNorm" id="editReport"><img src="dynicons/?img=gnome-applications-science.svg&w=32" alt="" /> Modify Search</button> ');
            $('#' + grid.getPrefixID() + 'gridToolbar').append(' <button type="button" class="buttonNorm" onclick="showJSONendpoint();"><img src="dynicons/?img=applications-other.svg&w=16" alt="" /> JSON</button> ');
            $('#' + grid.getPrefixID() + 'gridToolbar').prepend('<button id="newRequestButton" class="buttonNorm"  style="display: none; position: absolute; bottom: 0; left: 0" type="button" onclick="createRequest(categoryID)"><img src="dynicons/?img=list-add.svg&amp;w=16" alt="" />Create Row</button><p id="newRecordWarning" style="display: none; position: absolute; top: 0; left: 0; color:#d00">A new request was created, but it was not returned by the current query.</p>');
            extendedToolbar = true;


            $('#editReport').on('click', function() {
                filterData = {}; // reset x-filterData params
                grid.stop();
                isNewQuery = true;
                $('#reportTitleDisplay').css('display', 'none');
                $('#reportTitle').css('display', 'block');
                $('#newRequestButton').css('display', 'none');
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
        let leafSearchQuery = leafSearch.getLeafFormQuery().getQuery();
        checkIfOneTypeSearchedAndUpdate(leafSearchQuery.terms);

        urlQuery = LZString.compressToBase64(JSON.stringify(leafSearchQuery));
        urlIndicators = LZString.compressToBase64(JSON.stringify(selectedIndicators));

        if(isNewQuery) {
            baseURL = '';
            if(window.location.href.indexOf('&') === -1) {
                baseURL = window.location.href;
            }
            else {
                baseURL = window.location.href.substr(0, window.location.href.indexOf('&'));
            }
            buildURLComponents(baseURL);

            $('#reportTitle').on('keyup', function() {
                buildURLComponents(baseURL, true);
            });
        }
        else {
            url = window.location.href;
        }
        //reapply colors if user has moved away from reports view
        if(Object.keys(gridColorData).length !== 0){
            updateHeaderColors(gridColorData);
        }
    });


    <!--{if $query != '' && $indicators != ''}-->
    function loadReport() {
        let inQuery;
        let inIndicators;
        let title = '';

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
        updateTitle(title);

        try {
            if(<!--{$version}--> >= 2) {
                let query = '<!--{$query|escape:"html"}-->';
                let indicators = '<!--{$indicators|escape:"html"}-->';
                let colors = '<!--{$colors|escape:"html"}-->';
                query = query.replace(/ /g, '+');
                indicators = indicators.replace(/ /g, '+');
                colors = colors.replace(/ /g, '+');
                inQuery = JSON.parse(LZString.decompressFromBase64(query));
                //if refreshed or not a new report
                checkIfOneTypeSearchedAndUpdate(inQuery.terms);

                t_inIndicators = JSON.parse(LZString.decompressFromBase64(indicators));
                t_inIndicators.forEach(ind => {
                    if (+ind?.indicatorID > 0) {
                       indicatorSort[ind.indicatorID] = ind.sort;
                    }
                });
                let queryColors = JSON.parse(LZString.decompressFromBase64(colors));
                if (queryColors !== null) {
                    gridColorData = queryColors;
                    updateHeaderColors(gridColorData);
                }

                let urlParams = new URLSearchParams(window.location.search);
                urlSortParam = urlParams.get('sort');
                if(urlSortParam != null) {
                    sortPreference = JSON.parse(LZString.decompressFromBase64(urlSortParam));
                }
            }
            else {
                inQuery = JSON.parse(atob('<!--{$query|escape:"html"}-->'));
                t_inIndicators = JSON.parse(atob('<!--{$indicators|escape:"html"}-->'));
            }
            inIndicators = [];
            for(let i in t_inIndicators) {
                var temp = {};
                if($.isNumeric(t_inIndicators[i].indicatorID)) {
                    // add selected columns to payload in case of grid indicator
                    if (Array.isArray(t_inIndicators[i].cols)) {
                        temp.cols = t_inIndicators[i].cols;
                    }
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

            // We usually don't want to see deleted requests, but this parameter still needs to be
            // passed into the API. To simplify the user interface, the parameter is removed before
            // rendering the view. Explicit searches for deleted requests are not affected.
            if(!isSearchingDeleted(leafSearch)) {
                for(let i in inQuery.terms) {
                    if(inQuery.terms[i].id == 'deleted'
                        && inQuery.terms[i].operator == '='
                        && parseInt(inQuery.terms[i].match) == 0) {
                        inQuery.terms.splice(i, 1);
                    }
                }
            }
            leafSearch.renderPreviousAdvancedSearch(inQuery.terms);
            headers = headers.concat(inIndicators);
            $('#step_1').slideUp(700);
            $('#generateReport').click();
        }
        catch(err) {
            alert('Invalid report');
        }
    }
    loadReport();
    <!--{/if}-->
});
</script>
