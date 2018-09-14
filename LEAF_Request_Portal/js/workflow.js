/************************
    Workflow widget
*/
var workflow;
var workflowModule = new Object();
var LeafWorkflow = function(containerID, CSRFToken) {
	var containerID = containerID;
	var CSRFToken = CSRFToken;
	var prefixID = 'LeafFlow' + Math.floor(Math.random()*1000) + '_';
	var htmlFormID = prefixID + 'record';
	var dialog;
	var currRecordID = 0;
	var postModifyCallback;
	var antiDblClick = 0;
	var actionSuccessCallback;

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

	    $("#workflowbox_dep" + data['dependencyID']).html('<div style="border: 2px solid black; text-align: center; font-size: 24px; font-weight: bold; background: white; padding: 16px; width: 95%">Applying action... <img src="images/largespinner.gif" alt="loading..." /></div>');
	    $.ajax({
	        type: 'POST',
	        url: 'api/?a=formWorkflow/' + currRecordID + '/apply',
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
	                $("#workflowbox_dep" + data['dependencyID']).html('<div style="border: 2px solid black; text-align: center; font-size: 24px; font-weight: bold; background: white; padding: 16px; width: 95%"><img src="../libs/dynicons/?img=dialog-error.svg&w=48" style="vertical-align: middle" alt="error icon" /> '+ errors +'<br /><span style="font-size: 14px; font-weight: normal">After resolving the errors, <button id="workflowbtn_tryagain" class="buttonNorm">click here to try again</button>.</span></div>');
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

        if (step.requiresDigitalSignature == true) {
            $(document.createElement('div'))
                .css({'margin': 'auto',
                      'width': '95%',
                      'text-align': 'center'})
                .html("<br style='clear: both' /><img src='../libs/dynicons/?img=application-certificate.svg&w=24' alt='Digital Signature Enabled' title='Digital Signature Enabled' style='vertical-align: middle'> Digital Signature Enabled")
                .appendTo('#form_dep' + step.dependencyID);

            if(typeof Signer == 'undefined') {
                $.ajax({
                    type: 'GET',
                    url: "../libs/sign/SmartcardHelpers.js",
                    dataType: 'script'});
                $.ajax({
                    type: 'GET',
                    url: "../libs/sign/Stomp.js",
                    dataType: 'script'});
                $.ajax({
                    type: 'GET',
                    url: "../libs/sign/SockJS.js",
                    dataType: 'script'});
            }
        }

		// draw buttons
		for(var i in step.dependencyActions) {
			var icon = '';
			if(step.dependencyActions[i].actionIcon != '') {
				icon = '<img src="../libs/dynicons/?img='+ step.dependencyActions[i].actionIcon +'&amp;w=22" alt="'+ step.dependencyActions[i].actionText +'" style="vertical-align: middle" />';
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
                        else {
                            applyAction(data);
                        }
                    else {
                        applyAction(data);
                    }
                };

                // TODO: eventually this will be handled by Workflow extension
                if (step.requiresDigitalSignature == true) {
                    if (LEAFRequestPortalAPI !== undefined) {

                        var portalAPI = LEAFRequestPortalAPI();
                        portalAPI.setCSRFToken(CSRFToken);

                        portalAPI.Forms.getJSONForSigning(
                            currRecordID,
                            function (json) {
                                var jsonStr = JSON.stringify(json);
                                Signer.sign(jsonStr, function (signedDataList) {
                                    var sigData = JSON.stringify(signedDataList);

                                    portalAPI.Signature.create(
                                        sigData,
                                        currRecordID,
                                        jsonStr,
                                        function (id) {
                                            data['signature'] = id.replace('"', "");

                                            completeAction();
                                        },
                                        function (err) {
                                            console.log(err);
                                        }
                                    );

                                }, function (err) {
                                    // TODO: display error message to user
                                    console.log(err);
                                });

                            },
                            function (err) {
                                console.log(err);
                            }
                        );

                    }
                    // TODO: handle getting signature here
                    // data['signature'] = "TEMPORARY SIGNATURE";
                } else {
                    completeAction();
                }
		    });
		}

		// load jsAssets
		for(var u in step.jsSrcList) {
		    $.ajax({
		        type: 'GET',
		        url: step.jsSrcList[u],
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
//		$('#btn_cancelRequest').css('display', 'none');

	    $('#' + containerID).append('<div id="workflowbox_dep'+ step.dependencyID +'" class="workflowbox"></div>');
	    $('#workflowbox_dep'+ step.dependencyID).css({'background-color': step.stepBgColor,
	                                'border': step.stepBorder,
	                                'text-align': 'center', 'padding': '8px'
	                               });
	    // dependencyID -1 : special case for person designated by the requestor
	    if(step.dependencyID == -1) {
	    	$.ajax({
	    		type: 'GET',
	    		url: 'api/?a=form/customData/_' + recordID + '/_' + step.indicatorID_for_assigned_empUID,
	    		success: function(res) {
	    			$('#workflowbox_dep'+ step.dependencyID).append('<span>Pending action from '+ res[recordID]['s1']['id' + step.indicatorID_for_assigned_empUID] +'</span>');
	    			$('#workflowbox_dep'+ step.dependencyID +' span').css({'font-size': '150%', 'font-weight': 'bold', 'color': step.stepFontColor});
	    		}
	    	});
	    }
	    else if(step.dependencyID == -3) { // dependencyID -3 : special case for group designated by the requestor
	    	$.ajax({
	    		type: 'GET',
	    		url: 'api/?a=form/customData/_' + recordID + '/_' + step.indicatorID_for_assigned_groupID,
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
	        url: 'api/?a=formWorkflow/' + recordID + '/lastAction',
	        dataType: 'json',
	        success: function(response) {
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

        $.ajax({
        	type: 'GET',
        	url: 'api/?a=formWorkflow/'+ recordID +'/currentStep',
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

	return {
		getWorkflow: getWorkflow,
		setActionSuccessCallback: setActionSuccessCallback
	}
};
