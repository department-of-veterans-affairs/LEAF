var depVisibility = [];
var inboxDataLoaded = new Object();
var currRecordID = null;
var intvalStatus = null;
var lastActTime = null;
var dialog_message;

/**
 * Purpose: Toggle by Keypress the ability to see inbox menu for dependency
 * @param evt - Event
 * @param depID - Dependency ID
 */
function toggleDepVisibilityKeypress(evt, depID, csrfToken) {
    if(evt.keyCode === 13) {
        toggleDepVisibility(depID, csrfToken);
    }
}

/**
 * Purpose: Toggle the ability to see inbox dependency menu
 * @param depID - Dependency ID
 * @param csrfToken - CSRF Token
 */
function toggleDepVisibility(depID, csrfToken) {
    if(depVisibility[depID] == undefined
        || depVisibility[depID] == 1) {
        depVisibility[depID] = 0;
        $('#depTitleAction_' + depID).attr('aria-label', 'Collapsed menu');
        $('#depTitle_' + depID + '_announce').attr('aria-label', 'Collapsed menu');
        $('#depTitle_' + depID + '_announce').html('<div aria-label="Collapsed menu" style="position: absolute"></div>');
        $('#depContainer_' + depID).css({
            'visibility': 'hidden',
            'display': 'none'
        });
        $('#depTitle_' + depID).css({
            'width': '50%'
        });
    }
    else {
        depVisibility[depID] = 1;
        loadInboxData(depID, csrfToken);
        $('#depTitleAction_' + depID).attr('aria-label', 'Expanded menu');
        $('#depTitle_' + depID + '_announce').attr('aria-label', 'Expanded menu');
        $('#depTitle_' + depID + '_announce').html('<div aria-label="Expanded menu" style="position: absolute"></div>');
        $('#depTitle_' + depID).css({
            'width': '100%'
        });
        $('#depContainer_' + depID).css({
            'visibility': 'visible',
            'display': 'inline'
        });
    }
}

/**
 * Purpose: Strip HTML by adding to created DIV then reading back out
 * @param input
 * @returns {string}
 */
function stripHtml(input) {
    var temp = document.createElement('div');
    temp.innerHTML = input;
    return temp.innerText || temp.textContent;
}

/**
 * Purpose: Load Inbox Data to display depending on Dependency ID submitted
 * @param depID
 * @param csrfToken
 */
function loadInboxData(depID, csrfToken) {
    $('#depContainerIndicator_' + depID).css('display', 'block');

    $.ajax({
        type: 'GET',
        url: 'api/inbox/dependency/_' + depID,
        success: function(res) {
            inboxDataLoaded[depID] = 1;
            processInboxData(depID, res, csrfToken);
        },
        fail: function(err) {
            alert('Error: ' + err.statusText + ' in api/inbox/dependency/_' + depID);
        },
        cache: false
    });
}

/**
 * Purpose: Process inbox data from AJAX request according to Dependency ID
 * @param depID
 * @param res
 * @param csrftoken
 */
function processInboxData(depID, res, csrftoken) {
    var formGrid = new LeafFormGrid('depContainer_' + depID);

    var recordIDs = '';
    for (var i in res[depID]['records']) {
        recordIDs += res[depID]['records'][i].recordID + ',';
    }

    formGrid.setDataBlob(res);
    formGrid.setHeaders([
        {name: 'Type', indicatorID: 'type', editable: false, callback: function(data, blob) {
                var listRecord = blob[depID]['records'][data.recordID];
                var cellContainer = $('#'+data.cellContainerID);
                var categoryNames = '';
                if(listRecord.categoryNames != undefined) {
                    categoryNames = listRecord.categoryNames.replace(' | ', ', ');
                }
                else {
                    categoryNames = '<span style="color: red">Warning: This request is based on an old or deleted form.</span>';
                }
                cellContainer.html(categoryNames).attr('tabindex', '0').attr('aria-label', categoryNames);
            }},
        {name: 'Service', indicatorID: 'service', editable: false, callback: function(data, blob) {
                var listRecord = blob[depID]['records'][data.recordID];
                var cellContainer = $('#'+data.cellContainerID);
                cellContainer.html(listRecord.service).attr('tabindex', '0').attr('aria-label', listRecord.service);
            }},
        {name: 'Title', indicatorID: 'title', editable: false, callback: function(data, blob) {
                var listRecord = blob[depID]['records'][data.recordID];
                var cellContainer = $('#'+data.cellContainerID);
                cellContainer.attr('tabindex', '0').attr('aria-label', listRecord.title);
                cellContainer.html('<a href="index.php?a=printview&recordID='+ data.recordID + '" target="_blank">' + listRecord.title + '</a>'
                    + ' <button type="button" id="'+ data.cellContainerID +'_preview" class="buttonNorm">Quick View</button>'
                    + '<div id="inboxForm_' + depID + '_' + data.recordID +'" style="background-color: white; display: none; height: 300px; overflow: scroll"></div>');
                $('#'+data.cellContainerID + '_preview').on('click', function() {
                    $('#'+data.cellContainerID + '_preview').hide();
                    if($('#inboxForm_'+depID+'_'+data.recordID).html() == '') {
                        $('#inboxForm_'+depID+'_'+data.recordID).html('Loading...');
                        $('#inboxForm_'+depID+'_'+data.recordID).slideDown();
                        $.ajax({
                            type: 'GET',
                            url: 'ajaxIndex.php?a=printview&recordID=' + data.recordID,
                            success: function(res) {
                                $('#inboxForm_'+depID+'_'+data.recordID).html(res);
                                $('#inboxForm_'+depID+'_'+data.recordID).slideDown();
                                $('#requestTitle').attr('tabindex', '0');
                                $('#requestInfo').attr('tabindex', '0');
                                ariaSubIndicators(1);
                            },
                            fail: function(err) {
                                alert('Error: ' + err.statusText + ' in retrieving Title for dep_' + depID);
                            },
                            cache: false
                        });
                    }
                });
            }},
        {name: 'Status', indicatorID: 'currentStatus', editable: false, callback: function(data, blob) {
                var listRecord = blob[depID]['records'][data.recordID];
                var cellContainer = $('#'+data.cellContainerID);
                var waitText = listRecord.blockingStepID == 0 ? 'Pending ' : 'Waiting for ';
                var status = '';
                if(listRecord.stepID == null && listRecord.submitted == '0') {
                    status = '<span style="color: #e00000">Not Submitted</span>';
                }
                else if(listRecord.stepID == null) {
                    var lastStatus = listRecord.lastStatus;
                    if(lastStatus == '') {
                        lastStatus = '<a href="index.php?a=printview&recordID='+ data.recordID +'">Check Status</a>';
                    }
                    status = '<span style="font-weight: bold">' + lastStatus + '</span>';
                }
                else {
                    status = waitText + listRecord.stepTitle;
                }

                if(listRecord.deleted > 0) {
                    status += ', Cancelled';
                }

                cellContainer.html(status).attr('tabindex', '0').attr('aria-label', status);
                if(listRecord.userID == '<!--{$userID}-->') {
                    cellContainer.css('background-color', '#feffd1');
                }
            }},
        {name: 'Action', indicatorID: 'action', editable: false, sortable: false, callback: function(data, blob) {
                var depDescription = 'Take Action';
                $('#'+data.cellContainerID).html('<button type="button" class="buttonNorm" style="text-align: center; font-weight: bold; white-space: normal" onclick="loadWorkflow('+ data.recordID +', \''+ depID +'\', \''+ formGrid.getPrefixID() +'\', \''+csrftoken+'\');">'+ depDescription +'</button>');
            }}
    ]);

    formGrid.loadData(recordIDs);
    $('#' + formGrid.getPrefixID() + 'header_title').css('width', '60%');
    $('#depContainerIndicator_' + depID).css('display', 'none');
}

/**
 * Purpose: Add ARIA features to inbox item sub-indiciator outputs
 * @param i
 */
function ariaSubIndicators(i) {
    if(document.getElementById('PHindicator_' + i + '_1') !== null) {
        $('#PHindicator_' + i + '_1').append('<div aria-label="' +i +'"></div>');
        $('#PHindicator_' + i + '_1').attr('tabindex', '0');
        $('#xhrIndicator_' + i + '_1').attr('tabindex', '0');
        ariaIndicatorSeries(i, 1);
        i = i + 1;
        ariaSubIndicators(i);
    }
}

/**
 * Purpose: Add ARIA features to inbox item indicator series
 * @param i
 * @param j
 */
function ariaIndicatorSeries(i, j) {
    if(document.getElementById('PHindicator_' + i + '_' + j) !== null) {
        $('#PHindicator_' + i + '_' + j).attr('tabindex', '0');
        $('#xhrIndicator_' + i + '_' + j).attr('tabindex', '0');
        j = j + 1;
        ariaIndicatorSeries(i, j);
    }
}

/**
 * Purpose: Load Workflow so user can quickly move inbox item forward in workflow in dialog box
 * @param recordID
 * @param dependencyID
 * @param prefixID
 * @param csrfToken
 */
function loadWorkflow(recordID, dependencyID, prefixID, csrfToken) {
    dialog_message.setTitle('Apply Action to #' + recordID);

    currRecordID = recordID;
    dialog_message.setContent('<div id="workflowcontent"></div><div id="currItem"></div>');
    workflow = new LeafWorkflow('workflowcontent', csrfToken);
    workflow.setActionSuccessCallback(function() {
        dialog_message.hide();
        $('#' + prefixID + 'tbody_tr' + recordID).fadeOut(1500);
    });
    workflow.getWorkflow(recordID);
    dialog_message.show();
}
