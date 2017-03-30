<!--{if $deleted > 0}-->
<div style="font-size: 36px"><img src="../libs/dynicons/?img=emblem-unreadable.svg&amp;w=96" alt="Unreadable" style="float: left" /> Notice: This request has been marked as deleted.<br />
    <span class="buttonNorm" onclick="restoreRequest(<!--{$recordID}-->)"><img src="../libs/dynicons/?img=user-trash-full.svg&amp;w=32" alt="un-delete" /> Un-delete request</span>
</div><br style="clear: both" />
<hr />
<!--{/if}-->

<!-- Main content area (anything under the heading) -->
<div id="maincontent">
<div id="workflow_body">
    <!--{if $submitted == 0}-->
    <div id="progressSidebar" style="border: 1px solid black">
        <div style="background-color: #d76161; padding: 8px; margin: 0px; color: white; text-shadow: black 0.1em 0.1em 0.2em; font-weight: bold; text-align: center; font-size: 120%">Form completion progress</div>
        <div id="progressControl" style="padding: 16px; text-align: center; background-color: #ffaeae; font-weight: bold; font-size: 120%"><div id="progressBar" style="height: 30px; border: 1px solid black; text-align: center; width: 80%; margin: auto"><div style="width: 100%; line-height: 200%; float: left; font-size: 14px" id="progressLabel"></div></div><div style="line-height: 30%"><!-- ie7 workaround --></div></div>
    </div>
    <!--{/if}-->
    <div id="submitContent" class="noprint"></div>
    <div id="workflowcontent"></div>
</div>
<div id="formcontent"><div style="border: 2px solid black; text-align: center; font-size: 24px; font-weight: bold; background: white; padding: 16px; width: 95%">Loading... <img src="images/largespinner.gif" alt="loading..." /></div></div>
</div>

<!-- Toolbar -->
<div id="toolbar" class="toolbar_right toolbar noprint">
    <div id="tools" class="tools"><h1>Tools</h1>
        <!--{if $submitted == 0}-->
        <div onclick="window.location='?a=view&amp;recordID=<!--{$recordID}-->'"><img src="../libs/dynicons/?img=edit-find-replace.svg&amp;w=32" alt="Guided editor" title="Guided editor" /> Edit this form</div>
        <br /><br />
        <!--{/if}-->
        <div onclick="viewHistory()"><img src="../libs/dynicons/?img=appointment.svg&amp;w=32" alt="View Status" title="View History" /> View History</div>
        <div onclick="window.location='mailto:?subject=FW:%20Request%20%23<!--{$recordID}-->%20-%20<!--{$title|escape:'url'}-->&amp;body=Request%20URL:%20<!--{if $smarty.server.HTTPS == on}-->https<!--{else}-->http<!--{/if}-->://<!--{$smarty.server.SERVER_NAME}--><!--{$smarty.server.REQUEST_URI|escape:'url'}-->%0A%0A'"><img src="../libs/dynicons/?img=internet-mail.svg&amp;w=32" alt="Write Email" title="Write Email" /> Write Email</div>
        <!--{if $bookmarked == ''}-->
        <div onclick="toggleBookmark()" id="tool_bookmarkText"><img src="../libs/dynicons/?img=bookmark-new.svg&amp;w=32" alt="Add Bookmark" title="Add Bookmark" /> Add Bookmark</div>
        <!--{else}-->
        <div onclick="toggleBookmark()" id="tool_bookmarkText"><img src="../libs/dynicons/?img=bookmark-new.svg&amp;w=32" alt="Delete Bookmark" title="Delete Bookmark" /> Delete Bookmark</div>
        <!--{/if}-->
        <br /><br />
        <div onclick="cancelRequest()"><img src="../libs/dynicons/?img=process-stop.svg&amp;w=16" alt="Cancel Request" title="Cancel Request" /> Cancel Request</div>
    </div>

    <!--{if count($comments) > 0}-->
    <div id="comments">
    <h1>Comments</h1>
        <!--{section name=i loop=$comments}-->
            <div><span class="comments_time"><!--{$comments[i].time|date_format:' %b %e'}--></span>
                <span class="comments_name"><!--{$comments[i].actionTextPasttense}--> by <!--{$comments[i].name}--></span>
                <div class="comments_message"><!--{$comments[i].comment}--></div>
            </div>
        <!--{/section}-->
    </div>
    <!--{/if}-->

    <div id="category_list">
        <h1>Internal Use</h1>
        <div onclick="scrollPage('formcontent');openContent('ajaxIndex.php?a=printview&amp;recordID=<!--{$recordID}-->');"><img src="../libs/dynicons/?img=text-x-generic.svg&amp;w=16" alt="sub form" /> Main Request</div>
        <!--{section name=i loop=$childforms}-->
            <div onclick="scrollPage('formcontent');openContent('ajaxIndex.php?a=internalonlyview&amp;recordID=<!--{$recordID}-->&amp;childCategoryID=<!--{$childforms[i].childCategoryID}-->');"><img src="../libs/dynicons/?img=text-x-generic.svg&amp;w=16" alt="sub form" /> <!--{$childforms[i].childCategoryName}--></div>
        <!--{/section}-->
    </div>

    <div id="metaContainer" style="display: none">
        <h1 id="metaLabel"></h1>
        <h2 id="metaContent"></h2>
    </div>

    <!--{if $is_admin}-->
    <div id="adminTools" class="tools"><h1>Administrative Tools</h1>
        <!--{if $submitted != 0}-->
            <div onclick="admin_changeStep()"><img src="../libs/dynicons/?img=go-jump.svg&amp;w=32" alt="Change Current Step" title="Change Current Step" /> Change Current Step</div>
        <!--{/if}-->
        <div onclick="changeService()"><img src="../libs/dynicons/?img=user-home.svg&amp;w=32" alt="Change Service" title="Change Service" /> Change Service</div>
        <div onclick="admin_changeForm()"><img src="../libs/dynicons/?img=system-file-manager.svg&amp;w=32" alt="Change Forms" title="Change Forms" /> Change Form(s)</div>
        <div onclick="admin_changeInitiator()"><img src="../libs/dynicons/?img=gnome-stock-person.svg&amp;w=32" alt="Change Initiator" title="Change Initiator" /> Change Initiator</div>
    </div>
    <!--{/if}-->
</div>

<!-- DIALOG BOXES -->
<div id="formContainer"></div>
<!--{include file="site_elements/generic_xhrDialog.tpl"}-->
<!--{include file="site_elements/generic_confirm_xhrDialog.tpl"}-->
<!--{include file="site_elements/generic_dialog.tpl"}-->

<script type="text/javascript" src="js/functions/toggleZoom.js"></script>
<script type="text/javascript">
var currIndicatorID;
var currSeries;
var recordID = <!--{$recordID}-->;
var serviceID = <!--{$serviceID}-->;
var CSRFToken = '<!--{$CSRFToken}-->';
function doSubmit(recordID) {
	$('#submitControl').empty().html('<img src="./images/indicator.gif" />Submitting...');
	$.ajax({
		type: 'POST',
		url: "ajaxIndex.php?a=dosubmit&recordID=" + recordID,
		data: {CSRFToken: '<!--{$CSRFToken}-->'},
		success: function(response) {
            if(response.indexOf(recordID + 'submitOK') >= 0) {
                $('#submitControl').empty().html('Submitted');
                $('#submitContent').hide('blind', 500);
                workflow.getWorkflow(recordID);
            }
            else {
                $('#submitControl').empty().html('Submit Error. Please refresh and try again.');
            }
		}
	});
}

function updateTags() {
	$('#tags').fadeOut(250);
	$.ajax({
		type: 'GET',
		url: "./api/?a=form/<!--{$recordID}-->/tags",
		success: function(res) {
			var buffer = '';
			if(res.length > 0) {
				buffer = res.length + ' Bookmarks'
			}

			$('#tags').empty().html(buffer);
			$('#tags').fadeIn(250);
		},
		cache: false
	});
}

function getForm(indicatorID, series) {
	form.dialog().show();
	form.setPostModifyCallback(function() {
        getIndicator(indicatorID, series);
        updateProgress();
        form.dialog().hide();
	});
	form.getForm(indicatorID, series);
}

function getIndicatorLog(indicatorID, series) {
	dialog_message.setContent('Modifications made to this field:<table class="agenda" style="background-color: white"><thead><tr><td>Date/Author</td><td>Data</td></tr></thead><tbody id="history_'+ indicatorID +'"></tbody></table>');
    dialog_message.indicateBusy();
    dialog_message.show();
    
    $.ajax({
        type: 'GET',
        url: "api/?a=form/<!--{$recordID}-->/" + indicatorID + "/" + series + '/history',
        success: function(res) {
        	var numChanges = res.length;
        	var prev = '';
        	for(var i = 0; i < numChanges; i++) {
        		curr = res.pop();
        		date = new Date(curr.timestamp * 1000);
        		data = curr.data;
        		
        		if(i != 0) {
        			data = diffString(prev, data);
        		}
        		
        		$('#history_' + indicatorID).prepend('<tr><td>'+ date.toString() +'<br /><b>'+ curr.name +'</b></td><td><span class="printResponse" style="font-size: 16px">'+ data +'</span></td></tr>');
        		prev = curr.data;
        	}

            dialog_message.indicateIdle();
        },
        error: function(res) {
            dialog_message.setContent(res);
            dialog_message.indicateIdle();
        },
        cache: false
    });
}

function getIndicator(indicatorID, series) {
    $.ajax({
        type: 'GET',
        url: "ajaxIndex.php?a=getprintindicator&recordID=<!--{$recordID}-->&indicatorID=" + indicatorID + "&series=" + series,
        dataType: 'text',
        success: function(response) {
            if($("#PHindicator_" + indicatorID + "_" + series).hasClass("printheading_missing")) {
                $("#PHindicator_" + indicatorID + "_" + series).removeClass("printheading_missing");
                $("#PHindicator_" + indicatorID + "_" + series).addClass("printheading");
            }
            $("#xhrIndicator_" + indicatorID + "_" + series).empty().html(response);
            $("#xhrIndicator_" + indicatorID + "_" + series).fadeOut(250, function() {
                $("#xhrIndicator_" + indicatorID + "_" + series).fadeIn(250);
            });
        },
        cache: false
    });
}

function updateProgress() {
    $.ajax({
        type: 'GET',
        url: "./api/form/<!--{$recordID}-->/progress",
        dataType: 'json',
        success: function(response) {
            if(response < 100) {
                $('#progressBar').progressbar('option', 'value', response);
                $('#progressLabel').text(response + '%');
            }
            else if('<!--{$submitted}-->' == '0') {
                $('#progressBar').progressbar('option', 'value', response);
                $('#progressLabel').text(response + '%');
                $('#progressSidebar').slideUp(500);
                $.ajax({
                    type: 'GET',
                    url: "ajaxIndex.php?a=getsubmitcontrol&recordID=<!--{$recordID}-->",
                    dataType: 'text',
                    success: function(response) {
                        $("#submitContent").empty().html(response);
                        $("#submitContent").css({'border': '1px solid black',
                            'text-align': 'center',
                            'background-color': '#ffaeae'});
                        $("#workflowcontent").css({'font-size': "80%", 'padding-top': "8px"});
                    },
                    error: function(response) {
                    	$("#xhr").html("Error: " + response);
                    },
                    cache: false
                });
            }
        },
        cache: false
    });
}

function hideForm() {
    dialog.hide();
}

function restoreRequest() {
	$.ajax({
		type: 'POST',
		url: "ajaxIndex.php?a=restore",
		data: {restore: <!--{$recordID}-->,
            CSRFToken: '<!--{$CSRFToken}-->'},
        success: function(response) {
            if(response > 0) {
                window.location.href="index.php?a=printview&recordID=<!--{$recordID}-->";
            }
        }
	});
}

<!--{if $bookmarked == ''}-->
var bookmarkStatus = 0;
<!--{else}-->
var bookmarkStatus = 1;
<!--{/if}-->
function toggleBookmark() {
    if(bookmarkStatus == 0) {
        addBookmark();
        bookmarkStatus = 1;
        $('#tool_bookmarkText').empty().html('<img src="../libs/dynicons/?img=bookmark-new.svg&amp;w=32" style="vertical-align: middle" alt="Delete Bookmark" title="Delete Bookmark" /> Delete Bookmark');
    }
    else {
        removeBookmark();
        bookmarkStatus = 0;
        $('#tool_bookmarkText').empty().html('<img src="../libs/dynicons/?img=bookmark-new.svg&amp;w=32" style="vertical-align: middle" alt="Add Bookmark" title="Add Bookmark" /> Add Bookmark');
    }
}

function addBookmark() {
    $.ajax({
        type: 'POST',
        url: "ajaxIndex.php?a=addbookmark&recordID=<!--{$recordID}-->",
        data: {CSRFToken: '<!--{$CSRFToken}-->'},
        success: function(response) {
        	updateTags();
        }
    });
}

function removeBookmark() {
    $.ajax({
        type: 'POST',
        url: "ajaxIndex.php?a=removebookmark&recordID=<!--{$recordID}-->",
        data: {CSRFToken: '<!--{$CSRFToken}-->'},
        success: function(response) {
            updateTags();
        }
    });
}

function openContent(url) {
    $("#formcontent").html('<div style="border: 2px solid black; text-align: center; font-size: 24px; font-weight: bold; background: white; padding: 16px; width: 95%">Loading... <img src="images/largespinner.gif" alt="loading..." /></div>');
    $.ajax({
    	type: 'GET',
    	url: url,
    	dataType: 'text',  // IE9 issue
    	success: function(res) {
    		$('#formcontent').empty().html(res);
    		
    		// make box size more predictable
    		$('.printmainblock').each(function() {
                var boxSizer = {};
    			$(this).find('.printsubheading').each(function() {
    				layer = $(this).position().top;
    				if(boxSizer[layer] == undefined) {
    					boxSizer[layer] = $(this).height();
    				}
    				if($(this).height() > boxSizer[layer]) {
    					boxSizer[layer] = $(this).height();
    				}
    			});
    			$(this).find('.printsubheading').each(function() {
    				layer = $(this).position().top;
    				if(boxSizer[layer] != undefined) {
                        $(this).height(boxSizer[layer]);
    				}
                });
    		});
    	},
    	error: function(res) {
    		$('#formcontent').empty().html(res);
    	},
    	cache: false
    });
}

function viewHistory() {
	dialog_message.setContent('');
	dialog_message.show();
	dialog_message.indicateBusy();
	$.ajax({
		type: 'GET',
		url: 'ajaxIndex.php?a=getstatus&recordID=<!--{$recordID}-->',
		dataType: 'text',
		success: function(res) {
			 dialog_message.setContent(res);
			 dialog_message.indicateIdle();
		},
		cache: false
	});
}

function cancelRequest() {
	dialog_confirm.setContent('<img src="../libs/dynicons/?img=process-stop.svg&amp;w=48" alt="Cancel Request" style="float: left; padding-right: 24px" /> Are you sure you want to cancel this request?');

	dialog_confirm.setSaveHandler(function() {
		$.ajax({
			type: 'POST',
			url: 'ajaxIndex.php?a=cancel',
			data: {cancel: <!--{$recordID}-->,
                CSRFToken: '<!--{$CSRFToken}-->'},
            success: function(response) {
            	if(response == 1) {
                    window.location.href="index.php?a=cancelled_request&cancelled=<!--{$recordID}-->";
                }
            	else {
            		alert(response);
            	}
            },
            cache: false
		});
	});
	dialog_confirm.show();
}

function changeTitle() {
	dialog.setContent('Title: <input type="text" id="title" style="width: 300px" name="title" value="<!--{$title|escape:'quotes'}-->" /><input type="hidden" id="CSRFToken" name="CSRFToken" value="<!--{$CSRFToken}-->" />');
    dialog.show();

    dialog.setSaveHandler(function() {
        $.ajax({
        	type: 'POST',
        	url: 'api/?a=form/<!--{$recordID}-->/title',
        	data: {title: $('#title').val(),
                CSRFToken: '<!--{$CSRFToken}-->'},
        	success: function(res) {
        		if(res != null) {
        			  $('#requestTitle').empty().html(res);
        		}
                dialog.hide();
        	}
        });
    });
}

function changeService() {
    dialog.setTitle('Change Service');
    dialog.setContent('Select new service: <br /><div id="changeService"></div>');
    dialog.show();
    dialog.indicateBusy();
    dialog.setSaveHandler(function() {
        alert('Please wait for service list to load.');
    });
    $.ajax({
        type: 'GET',
        url: './api/?a=system/services',
        dataType: 'json',
        success: function(res) {
            var services = '<select id="newService" class="chosen" style="width: 250px">';
            for(var i in res) {
                services += '<option value="'+ res[i].groupID +'">'+ res[i].groupTitle +'</option>';
            }
            services += '</select>';
            $('#changeService').html(services);
            $('.chosen').chosen({disable_search_threshold: 6});
            dialog.indicateIdle();
            dialog.setSaveHandler(function() {
                $.ajax({
                    type: 'POST',
                    url: 'api/?a=form/<!--{$recordID}-->/service',
                    data: {serviceID: $('#newService').val(),
                           CSRFToken: CSRFToken},
                    success: function() {
                        window.location.href="index.php?a=printview&recordID=<!--{$recordID}-->";
                    }
                });
                dialog.hide();
            });
        },
        cache: false
    });
}

<!--{if $is_admin}-->

function admin_changeStep() {
    dialog.setTitle('Change Step');
    dialog.setContent('Set to this step: <br /><div id="changeStep"></div>');
    dialog.show();
    dialog.indicateBusy();
    $.ajax({
        type: 'GET',
        url: 'api/?a=formWorkflow/<!--{$recordID}-->/currentStep',
        dataType: 'json',
        success: function(res) {
        	var workflows = {};
        	for(var i in res) {
        		workflows[res[i].workflowID] = 1;
        	}

        	$.ajax({
                type: 'GET',
                url: 'api/?a=workflow/steps',
                dataType: 'json',
                success: function(res) {
                    var steps = '<select id="newStep" class="chosen" style="width: 250px">';
                    var steps2 = '';
                    var stepCounter = 0;
                	for(var i in res) {
               			steps += '<option value="'+ res[i].stepID +'">' + res[i].description + ': ' + res[i].stepTitle +'</option>';
               			stepCounter++;
                		steps2 += '<option value="'+ res[i].stepID +'">' + res[i].description + ' - ' + res[i].stepTitle +'</option>';
                	}
                	if(stepCounter == 0) {
                		steps += steps2;
                	}
                	steps += '</select>';
                    $('#changeStep').html(steps);
                    $('.chosen').chosen({disable_search_threshold: 6});
                    dialog.indicateIdle();
                    dialog.setSaveHandler(function() {
                        $.ajax({
                            type: 'POST',
                            url: 'api/?a=formWorkflow/<!--{$recordID}-->/step',
                            data: {stepID: $('#newStep').val(),
                                   CSRFToken: CSRFToken},
                            success: function() {
                                window.location.href="index.php?a=printview&recordID=<!--{$recordID}-->";
                            }
                        });
                        dialog.hide();
                    });
                }
        	});
        }
    });
}

function admin_changeForm() {
    dialog.setTitle('Change Form(s)');
    dialog.setContent('Select Forms: <br /><div id="changeForm"></div>');
    dialog.show();
    dialog.indicateBusy();
    dialog.setSaveHandler(function() {
        alert('Please wait for service list to load.');
    });
    $.ajax({
        type: 'GET',
        url: './api/?a=workflow/categoriesUnabridged',
        dataType: 'json',
        success: function(res) {
            var categories = '';
            for(var i in res) {
            	categories += '<input type="checkbox" class="admin_changeForm" id="category_'+ res[i].categoryID +'" name="categories[]" value="'+ res[i].categoryID +'" />';
                categories += '<label class="checkable" for="category_'+ res[i].categoryID +'">'+ res[i].categoryName +'</label><br />';
            }
            $('#changeForm').html(categories);
            $('.admin_changeForm').icheck({checkboxClass: 'icheckbox_square-blue', radioClass: 'iradio_square-blue'});
            dialog.indicateIdle();
            dialog.setSaveHandler(function() {
            	var data = {'categories[]' : [], CSRFToken: CSRFToken};
            	$('.admin_changeForm:checked').each(function() {
            		data['categories[]'].push($(this).val());
            	});
                $.ajax({
                    type: 'POST',
                    url: 'api/?a=form/<!--{$recordID}-->/types',
                    data: data,
                    success: function() {
                        window.location.href="index.php?a=printview&recordID=<!--{$recordID}-->";
                    }
                });
                dialog.hide();
            });

            // find current forms
            var query = {terms: [{id: 'recordID', operator: '=', match: '<!--{$recordID}-->'}],joins: ['categoryNameUnabridged']};
            $.ajax({
                type: 'GET',
                url: './api/?a=form/query',
                data: {q: JSON.stringify(query)},
                dataType: 'json',
                success: function(res) {
                	var temp = res[<!--{$recordID}-->].categoryNamesUnabridged;
                	$('label.checkable').each(function() {
                		for(var i in temp) {
                            if($(this).html() == temp[i]) {
                                $('#' + $(this).attr('for')).prop('checked', true);
                            }
                		}
                	});
                	$('.admin_changeForm').icheck('updated');
                }
            });
        }
    });
}

function admin_changeInitiator() {
    dialog.setTitle('Change Initiator');
    dialog.setContent('Select employee to be set as this request\'s initiator: <br /><div id="empSel_changeInitiator"></div><input type="hidden" id="changeInitiator"></input>');
    dialog.show();
    dialog.indicateBusy();

    dialog.setSaveHandler(function() {
    	if($('#changeInitiator').val() != '') {
            $.ajax({
                type: 'POST',
                url: './api/?a=form/<!--{$recordID}-->/initiator',
                data: {CSRFToken: CSRFToken,
                	   initiator: $('#changeInitiator').val()},
                success: function() {
                    location.reload();
                }
            });
    	}
    	else {
    		alert('An employee needs to be selected');
    	}
    });

    var empSel;
    function init_empSel() {
        empSel = new employeeSelector('empSel_changeInitiator');
        empSel.apiPath = '<!--{$orgchartPath}-->/api/';
        empSel.rootPath = '<!--{$orgchartPath}-->/';

        empSel.setSelectHandler(function() {
        	if(empSel.selectionData[empSel.selection] != undefined) {
        		$('#changeInitiator').val(empSel.selectionData[empSel.selection].userName);
        	}
        });
        empSel.setResultHandler(function() {
        	if(empSel.selectionData[empSel.selection] != undefined) {
                $('#changeInitiator').val(empSel.selectionData[empSel.selection].userName);
            }
        });
        empSel.initialize();
        dialog.indicateIdle();
    }

    if(typeof employeeSelector == 'undefined') {
        $('head').append('<link type="text/css" rel="stylesheet" href="<!--{$orgchartPath}-->/css/employeeSelector.css" />');
        $.ajax({
            type: 'GET',
            url: "<!--{$orgchartPath}-->/js/employeeSelector.js",
            dataType: 'script',
            success: function() {
                init_empSel();
            }
        });
    }
    else {
    	init_empSel();
    }

}
<!--{/if}-->

function scrollPage(id) {
	if($(document).height() < $('#'+id).offset().top + 100) {
		$('html, body').animate({scrollTop: $('#'+id).offset().top}, 500);		
	}
}

// attempt to force a consistent width for the sidebar if there is enough desktop resolution
var lastScreenSize = null;
function sideBar() {
//    console.log(window.innerWidth);
    if(lastScreenSize != window.innerWidth) {
        lastScreenSize = window.innerWidth;

        if(lastScreenSize < 700) {
            $('#toolbar').removeClass("toolbar_right");
            $('#toolbar').addClass("toolbar_inline");
            $('#maincontent').css("width", "98%");
            $('#toolbar').css("width", "98%");
        }
        else {
        	$('#toolbar').removeClass("toolbar_inline");
        	$('#toolbar').addClass("toolbar_right");
            // effective width of toolbar becomes around 205px
            mywidth = Math.floor((1 - 250/lastScreenSize) * 100);
            $('#maincontent').css("width", mywidth + "%");
            $('#toolbar').css("width", 98-mywidth + "%");
        }
    }
}

$(function() {
    $('#progressBar').progressbar({max: 100});

    form = new LeafForm('formContainer');
    form.setRecordID(<!--{$recordID}-->);

    workflow = new LeafWorkflow('workflowcontent', '<!--{$CSRFToken}-->');
    <!--{if $submitted > 0}-->
    workflow.getWorkflow(<!--{$recordID}-->);
    <!--{/if}-->

    /* General popup window */
    dialog = new dialogController('xhrDialog', 'xhr', 'loadIndicator', 'button_save', 'button_cancelchange');
    dialog_message = new dialogController('genericDialog', 'genericDialogxhr', 'genericDialogloadIndicator', 'genericDialogbutton_save', 'genericDialogbutton_cancelchange');
    dialog_confirm = new dialogController('confirm_xhrDialog', 'confirm_xhr', 'confirm_loadIndicator', 'confirm_button_save', 'confirm_button_cancelchange');

    <!--{if $childCategoryID == ''}-->
    openContent('ajaxIndex.php?a=printview&recordID=<!--{$recordID}-->');
    <!--{else}-->
    openContent('ajaxIndex.php?a=internalonlyview&recordID=<!--{$recordID}-->&childCategoryID=<!--{$childCategoryID}-->');
    <!--{/if}-->

    sideBar();
    setInterval("sideBar()", 500);

    <!--{if $submitted == 0}-->
    updateProgress();
    <!--{/if}-->

});

</script>