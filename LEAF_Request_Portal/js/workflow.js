/************************
    Workflow widget
*/
var workflow;
var workflowModule = new Object();
var workflowStepModule = new Object();
var LeafWorkflow = function(containerID, CSRFToken) {
    var containerID = containerID;
    var CSRFToken = CSRFToken;
    var prefixID = 'LeafFlow' + Math.floor(Math.random()*1000) + '_';
    var htmlFormID = prefixID + 'record';
    var dialog;
    var currRecordID = 0;
    var postModifyCallback;
    var antiDblClick = 0;
    var actionPreconditionFunc;
    var actionSuccessCallback;
    var rootURL = '';

    /**
     * @memberOf LeafWorkflow
     */
    function darkenColor(color) {
        bgColor = parseInt(color.substring(1), 16);
        r = (bgColor & 0xFF0000) >> 16;
        g = (bgColor & 0x00FF00) >> 8;
        b = bgColor & 0x0000FF;

        factor = -0.10;
        r = r + Math.round(r * factor);
        g = g + Math.round(g * factor);
        b = b + Math.round(b * factor);

        return '#' + ((r << 16) + (g << 8) + b).toString(16);
    }

    /**
     * @memberOf LeafWorkflow
     */
    function applyAction(data) {
        if(antiDblClick == 1) {
            return 1;
        }
        else {
            antiDblClick = 1;
        }

        $("#workflowbox_dep" + data['dependencyID']).html('<div style="border: 2px solid black; text-align: center; font-size: 24px; font-weight: bold; background: white; padding: 16px; width: 95%">Applying action... <img src="'+ rootURL +'images/largespinner.gif" alt="loading..." /></div>');
        $.ajax({
            type: 'POST',
            url: rootURL + 'api/?a=formWorkflow/' + currRecordID + '/apply',
            data: data,
            success: function(response) {
                if(response.errors.length == 0) {
                    $("#workflowbox_dep" + data['dependencyID']).html('<div style="border: 2px solid black; text-align: center; font-size: 24px; font-weight: bold; background: white; padding: 16px; width: 95%">Action applied!</div>');
                    $("#workflowbox_dep" + data['dependencyID']).hide('blind', 500);

                    getWorkflow(currRecordID);
                    if(actionSuccessCallback != undefined) {
                        actionSuccessCallback();
                    }
                }
                else {
                    var errors = '';
                    for(var i in response.errors) {
                        errors += response.errors[i] + '<br />';
                    }
                    $("#workflowbox_dep" + data['dependencyID']).html('<div style="border: 2px solid black; text-align: center; font-size: 24px; font-weight: bold; background: white; padding: 16px; width: 95%"><img src="'+ rootURL +'../libs/dynicons/?img=dialog-error.svg&w=48" style="vertical-align: middle" alt="error icon" /> '+ errors +'<br /><span style="font-size: 14px; font-weight: normal">After resolving the errors, <button id="workflowbtn_tryagain" class="buttonNorm">click here to try again</button>.</span></div>');
                    $("#workflowbtn_tryagain").on('click', function() {
                        getWorkflow(currRecordID);
                    });
                }
                antiDblClick = 0;
            },
            error: function(response) {
                $("#workflowbox_dep" + data['dependencyID']).html('<div style="border: 2px solid black; text-align: center; font-size: 24px; font-weight: bold; background: white; padding: 16px; width: 95%">Error: Workflow Events may not have triggered</div>');
            }
        });
    }

    /**
     * @memberOf LeafWorkflow
     */
    var modulesLoaded = {};
    function drawWorkflow(step) {
        // draw frame and header
        var stepDescription = step.description == null ? 'Your workflow is missing a requirement. Please check your workflow.' : step.description;

        $('#' + containerID).append('<div id="workflowbox_dep'+ step.dependencyID +'" class="workflowbox">\
                <span>\
                <div id="stepDescription_dep'+ step.dependencyID +'" style="background-color: ' + darkenColor(step.stepBgColor) + '; padding: 8px">'+ stepDescription +'</div>\
                </span>\
                <form id="form_dep'+ step.dependencyID +'" enctype="multipart/form-data" action="#">\
                    <div id="form_dep_extension'+ step.dependencyID +'"></div>\
                </form>\
                </div>');
        $('#workflowbox_dep'+ step.dependencyID).css({'padding': '0px', 'background-color': step.stepBgColor, 'border': step.stepBorder});
        $('#workflowbox_dep'+ step.dependencyID +' span').css({'font-size': '120%', 'font-weight': 'bold', 'color': step.stepFontColor});

        // draw comment area and button anchors
        $('#form_dep'+ step.dependencyID).append('<div id="form_dep_container'+ step.dependencyID +'">\
                <span class="noprint" aria-label="comments">Comments:</span><br />\
                <textarea id="comment_dep'+ step.dependencyID +'" aria-label="comment text area"></textarea>\
                </div>');
        $('#form_dep_container'+ step.dependencyID).css({'margin': 'auto', 'width': '95%', 'padding': '8px'});
        $('#workflowbox_dep'+ step.dependencyID).append('<br style="clear: both"/>');

        $('#comment_dep'+ step.dependencyID).css({'height': '40px',
                        'width': '100%',
                        'padding': '4px',
                        'resize': 'vertical'});

        // draw buttons
        for(var i in step.dependencyActions) {
            var icon = '';
            if(step.dependencyActions[i].actionIcon != '') {
                icon = '<img src="'+ rootURL +'../libs/dynicons/?img='+ step.dependencyActions[i].actionIcon +'&amp;w=22" alt="'+ step.dependencyActions[i].actionText +'" style="vertical-align: middle" />';
            }

            $('#form_dep_container'+ step.dependencyID).append('<div id="button_container'+ step.dependencyID +'_'+ step.dependencyActions[i].actionType +'" style="float: '+ step.dependencyActions[i].actionAlignment +'">\
                    <button type="button" id="button_step'+ step.dependencyID +'_'+ step.dependencyActions[i].actionType +'" class="button">\
                    '+ icon + ' ' + step.dependencyActions[i].actionText +'\
                    </button>\
                    </div>');
            $('#button_step'+ step.dependencyID +'_'+ step.dependencyActions[i].actionType).css({'border': '1px solid black', 'padding': '6px', 'margin': '4px'});

            $('#button_step'+ step.dependencyID +'_'+ step.dependencyActions[i].actionType).on('click', { step: step, idx: i },
                function(e) {
                var data = new Object();
                data['comment'] = $('#comment_dep'+ e.data.step.dependencyID).val();
                data['actionType'] = e.data.step.dependencyActions[e.data.idx].actionType;
                data['dependencyID'] = e.data.step.dependencyID;

                var completeAction = function() {
                    data['CSRFToken'] = CSRFToken;
                    if (e.data.step.dependencyActions[e.data.idx].fillDependency > 0)
                        if(typeof workflowModule[e.data.step.dependencyID] !== 'undefined') {
                            workflowModule[e.data.step.dependencyID].trigger(function() {
                                applyAction(data);
                            });
                        }
                        else if(typeof workflowStepModule[e.data.step.stepID] !== 'undefined') {
                            var actionTriggered = false;
                            for(var i in workflowStepModule[e.data.step.stepID]) {
                                if(typeof workflowStepModule[e.data.step.stepID][i].trigger !== 'undefined') {
                                    actionTriggered = true;
                                    workflowStepModule[e.data.step.stepID][i].trigger(function() {
                                        applyAction(data);
                                    });
                                    break;
                                }
                            }
                            if(!actionTriggered) {
                                applyAction(data);
                            }
                        }
                        else {
                            applyAction(data);
                        }
                    else {
                        applyAction(data);
                    }
                };

                if(actionPreconditionFunc !== undefined) {
                    actionPreconditionFunc(e.data, completeAction);
                }
                else {
                    completeAction();
                }

            });
        }

        // load workflowStep modules
        if (step.requiresDigitalSignature == true) {
            $.ajax({
                type: 'GET',
                url: rootURL + 'ajaxScript.php?a=workflowStepModules&s=LEAF_digital_signature&stepID=' + step.stepID,
                dataType: 'script',
                success: function() {
                    workflowStepModule[step.stepID].LEAF_digital_signature.init(step);
                }
            });
        }
        if(step.stepModules != undefined) {
            for(var x in step.stepModules) {
                if(modulesLoaded[step.stepModules[x].moduleName + '_' + step.stepID] == undefined) {
                    modulesLoaded[step.stepModules[x].moduleName + '_' + step.stepID] = 1;
                    $.ajax({
                        type: 'GET',
                        url: rootURL + 'ajaxScript.php?a=workflowStepModules&s='+ step.stepModules[x].moduleName +'&stepID=' + step.stepID,
                        dataType: 'script',
                        success: function() {
                            workflowStepModule[step.stepID][step.stepModules[x].moduleName].init(step);
                        }
                    });
                }
            }
        }

        // legacy workflow modules based on dependencyIDs
        for(var u in step.jsSrcList) {
            $.ajax({
                type: 'GET',
                url: rootURL + step.jsSrcList[u],
                dataType: 'script',
                success: function() {
                    workflowModule[step.dependencyID].init(currRecordID);
                }
            });
        }
    }

    /**
     * @memberOf LeafWorkflow
     */
    function drawWorkflowNoAccess(step) {
        // hide cancel button since the user doesn't have access
//        $('#btn_cancelRequest').css('display', 'none');

        $('#' + containerID).append('<div id="workflowbox_dep'+ step.dependencyID +'" class="workflowbox"></div>');
        $('#workflowbox_dep'+ step.dependencyID).css({'background-color': step.stepBgColor,
                                    'border': step.stepBorder,
                                    'text-align': 'center', 'padding': '8px'
                                   });
        // dependencyID -1 : special case for person designated by the requestor
        if(step.dependencyID == -1) {
            $.ajax({
                type: 'GET',
                url: rootURL + 'api/?a=form/customData/_' + recordID + '/_' + step.indicatorID_for_assigned_empUID,
                success: function(res) {
                    $('#workflowbox_dep'+ step.dependencyID).append('<span>Pending action from '+ res[recordID]['s1']['id' + step.indicatorID_for_assigned_empUID] +'</span>');
                    $('#workflowbox_dep'+ step.dependencyID +' span').css({'font-size': '150%', 'font-weight': 'bold', 'color': step.stepFontColor});
                }
            });
        }
        else if(step.dependencyID == -3) { // dependencyID -3 : special case for group designated by the requestor
            $.ajax({
                type: 'GET',
                url: rootURL + 'api/?a=form/customData/_' + recordID + '/_' + step.indicatorID_for_assigned_groupID,
                success: function(res) {
                    $('#workflowbox_dep'+ step.dependencyID).append('<span>Pending action from '+ step.description +'</span>');
                    $('#workflowbox_dep'+ step.dependencyID +' span').css({'font-size': '150%', 'font-weight': 'bold', 'color': step.stepFontColor});
                }
            });
        }
        else {
            $('#workflowbox_dep'+ step.dependencyID).append('<span>Pending '+ step.description +'</span>');
            $('#workflowbox_dep'+ step.dependencyID +' span').css({'font-size': '150%', 'font-weight': 'bold', 'color': step.stepFontColor});
        }
    }

    /**
     * @memberOf LeafWorkflow
     */
    function getLastAction(recordID, res) {
        $.ajax({
            type: 'GET',
            url: rootURL + 'api/?a=formWorkflow/' + recordID + '/lastActionSummary',
            dataType: 'json',
            success: function(lastActionSummary) {
                response = lastActionSummary.lastAction;
                if(response == null) {
                    if(res == null) {
                        $('#' + containerID).append('No actions available');
                    }
                    return null;
                }
                response.stepBgColor = response.stepBgColor == null ? '#e0e0e0' : response.stepBgColor;
                response.stepFontColor = response.stepFontColor == null ? '#000000' : response.stepFontColor;
                response.stepBorder = response.stepBorder == null ? '1px solid black' : response.stepBorder;
                var label = response.dependencyID == 5 ? response.categoryName: response.description;
                if(res != null) {
                    if(response.dependencyID != 5) {
                        $('#' + containerID).append('<div id="workflowbox_lastAction" class="workflowbox" style="padding: 0px; margin-top: 8px"></div>');
                        $('#workflowbox_lastAction').css({'background-color': response.stepBgColor, 'border': response.stepBorder});
                    }

                    var date = new Date(response.time * 1000);

                    var text = '';
                    if(response.description != null && response.actionText != null) {
                        text = '<div style="background-color: ' + darkenColor(response.stepBgColor) + '; padding: 4px"><span style="float: left; font-size: 90%">' + label + ': ' + response.actionTextPasttense + '</span>';
                        text += '<span style="float: right; font-size: 90%">' + date.toLocaleString('en-US', {weekday: "long", year: "numeric", month: "long", day: "numeric"}) + '</span><br /></div>';
                        if(response.comment != '' && response.comment != null) {
                            text += '<div style="font-size: 80%; padding: 4px 8px 4px 8px">Comment:<br /><div style="font-weight: normal; padding-left: 16px; font-size: 12px">' + response.comment + '</div></div>';
                        }
                    }
                    else {
                        text = "[ Please refer to this request's history for current status ]";
                    }

                    if(response.dependencyID != 5) {
                        $('#workflowbox_lastAction').append('<span style="font-weight: bold; color: '+response.stepFontColor+'">'+text+'</span>');
                    }
                }
                else {
                    $('#workflowcontent').append('<div id="workflowbox_lastAction"></div>');
                    $('#workflowbox_lastAction').css({'background-color': response.stepBgColor,
                                                'border': response.stepBorder,
                                                'text-align': 'center', padding: '0px'
                                               });
                    $('#workflowbox_lastAction').addClass('workflowbox');

                    var date = new Date(response.time * 1000);

                    var text = '';
                    if(response.description != null && response.actionText != null) {
                        text = '<div style="padding: 4px; background-color: ' + darkenColor(response.stepBgColor) + '">' + label + ': ' + response.actionTextPasttense;
                        text += '<br /><span style="font-size: 60%">' + date.toLocaleString('en-US', {weekday: "long", year: "numeric", month: "long", day: "numeric"}) + '</span></div>';
                        if(response.comment != '' && response.comment != null) {
                            text += '<div style="padding: 4px 16px"><fieldset style="border: 1px solid black"><legend class="noprint">Comment</legend><span style="font-size: 80%; font-weight: normal">' + response.comment + '</span></fieldset></div>';
                        }
                    }
                    else {
                        text = "[ Please refer to this request's history for current status. ]";
                    }

                    $('#workflowbox_lastAction').append('<span style="font-size: 150%; font-weight: bold", color: '+response.stepFontColor+'>'+ text +'</span>');
                }
                
                // check signatures
                if(lastActionSummary.signatures.length > 0) {
                    $('#workflowcontent').append('<div id="workflowSignatureContainer" style="margin-top: 8px"></div>');
                    for(var i in lastActionSummary.signatures) {
                        var sigTime = new Date(lastActionSummary.signatures[i].timestamp * 1000);
                        var month = sigTime.getMonth() + 1;
                        var date = sigTime.getDate();
                        var year = sigTime.getFullYear();
                        $('#workflowSignatureContainer').append('<div style="float: left; width: 30%; margin: 0 4px 4px 0; padding: 8px; background-color: #d1ffcc; border: 1px solid black; text-align: center">'+ lastActionSummary.signatures[i].stepTitle +' - Digitally signed<br /><span style="font-size: 140%; line-height: 200%"><img src="'+ rootURL +'../libs/dynicons/?img=application-certificate.svg&w=32" style="vertical-align: middle; padding-right: 4px" alt="digital signature (beta) logo" />'
                                + lastActionSummary.signatures[i].name + ' '
                                + month + '/' + date + '/' + year
                                +'</span><br /><span aria-hidden="true" style="font-size: 75%">x'+ lastActionSummary.signatures[i].signature.substr(0, 32) +'</span></div>');
                    }
                    for(var i in lastActionSummary.stepsPendingSignature) {
                        $('#workflowSignatureContainer').append('<div style="float: left; width: 30%; margin: 0 4px 4px 0; padding: 8px; background-color: white; border: 1px dashed black; text-align: center">'+ lastActionSummary.stepsPendingSignature[i] +'<br /><span style="font-size: 140%; line-height: 300%">X&nbsp;______________</span></div>');
                    }
                    $('#workflowcontent').append('<br style="clear: both" />');
                }
            },
            cache: false
        });
    }

    /**
     * @memberOf LeafWorkflow
     */
    function getWorkflow(recordID) {
        $('#' + containerID).empty();
        $('#' + containerID).css('display', 'none');
        antiDblClick = 0
        currRecordID = recordID;

        var masquerade = '';
        if(window.location.href.indexOf('masquerade=nonAdmin') != -1) {
            masquerade = '&masquerade=nonAdmin';
        }

        $.ajax({
            type: 'GET',
            url: rootURL + 'api/?a=formWorkflow/'+ recordID +'/currentStep' + masquerade,
            dataType: 'json',
            success: function(res) {
                for(var i in res) {
                    if(res[i].hasAccess == 1) {
                        drawWorkflow(res[i]);
                    }
                    else {
                        drawWorkflowNoAccess(res[i]);
                    }
                }
                getLastAction(recordID, res);
                $('#' + containerID).show('blind', 250);
            },
            cache: false
        });
    }

    /**
     * @memberOf LeafWorkflow
     */
    function setActionSuccessCallback(func) {
        actionSuccessCallback = func;
    }

    /**
     * @memberOf LeafWorkflow
     * func should accept 2 arguments:
     *     data - {
     *                 idx: index matching the current action for data.step.dependencyActions[]
     *                 step: data related to the current step
     *               }
     *     completeAction - to be executed in order to complete the workflow action
     */
    function setActionPreconditionFunc(func) {
        actionPreconditionFunc = func;
    }

    return {
        getWorkflow: getWorkflow,
        setActionPreconditionFunc: setActionPreconditionFunc,
        setActionSuccessCallback: setActionSuccessCallback,
        setRootURL: function(url) { rootURL = url; }
    }
};
