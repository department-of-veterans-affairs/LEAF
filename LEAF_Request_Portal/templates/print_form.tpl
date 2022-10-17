<!--{if $deleted > 0}-->
<div style="font-size: 36px"><img src="../libs/dynicons/?img=emblem-unreadable.svg&amp;w=96" alt="Unreadable" style="float: left" /> Notice: This request has been marked as deleted.<br />
    <span class="buttonNorm" onclick="restoreRequest(<!--{$recordID|strip_tags}-->)"><img src="../libs/dynicons/?img=user-trash-full.svg&amp;w=32" alt="un-delete" /> Un-delete request</span>
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
    <span style="position: absolute; width: 60%; height: 1px; margin: -1px; padding: 0; overflow: hidden; clip: rect(0,0,0,0); border: 0;" aria-atomic="true" aria-live="polite" id="submitStatus" role="status"></span>
    <div id="submitContent" class="noprint"></div>
    <div id="workflowcontent"></div>
</div>
<div id="formcontent"><div style="border: 2px solid black; text-align: center; font-size: 24px; font-weight: bold; background: white; padding: 16px; width: 95%">Loading... <img src="images/largespinner.gif" alt="loading..." /></div></div>
</div>

<!-- Toolbar -->
<!-- Toolbar -->
<div id="toolbar" class="toolbar_right toolbar noprint">
    <div id="tools" class="tools"><h1>Tools</h1>
        <!--{if $submitted == 0}-->
        <button class="tools"  onclick="window.location='?a=view&amp;recordID=<!--{$recordID|strip_tags}-->'" ><img src="../libs/dynicons/?img=edit-find-replace.svg&amp;w=32" alt="Guided editor" title="Guided editor" style="vertical-align: middle" /> Edit this form</button>
        <br />
        <br />
        <!--{/if}-->
        <button class="tools" onclick="viewHistory()" ><img src="../libs/dynicons/?img=appointment.svg&amp;w=32" alt="View Status" title="View History" style="vertical-align: middle" /> View History</button>
        <button class="tools" onclick="window.location='mailto:?subject=FW:%20Request%20%23<!--{$recordID|strip_tags}-->%20-%20<!--{$title|escape:'url'}-->&amp;body=Request%20URL:%20<!--{if $smarty.server.HTTPS == on}-->https<!--{else}-->http<!--{/if}-->://<!--{$smarty.server.SERVER_NAME}--><!--{$smarty.server.REQUEST_URI|escape:'url'}-->%0A%0A'" ><img src="../libs/dynicons/?img=internet-mail.svg&amp;w=32" alt="Write Email" title="Write Email" style="vertical-align: middle"/> Write Email</button>
        <button class="tools" id="btn_printForm"><img src="../libs/dynicons/?img=printer.svg&amp;w=32" alt="Print this Form" title="Print this Form" style="vertical-align: middle" /> Print to PDF <span style="font-style: italic; background-color: white; color: red; border: 1px solid black; padding: 4px">BETA</span></button>
        <!--{if $bookmarked == ''}-->
        <button class="tools"  onclick="toggleBookmark()" id="tool_bookmarkText" role="status" aria-live="polite"><img src="../libs/dynicons/?img=bookmark-new.svg&amp;w=32" alt="Add Bookmark" title="Add Bookmark" style="vertical-align: middle" /> <span>Add Bookmark</span></button>
        <!--{else}-->
        <button class="tools" onclick="toggleBookmark()" id="tool_bookmarkText" role="status" aria-live="polite" ><img src="../libs/dynicons/?img=bookmark-new.svg&amp;w=32" alt="Delete Bookmark" title="Delete Bookmark" style="vertical-align: middle"/> <span>Delete Bookmark</span></button>
        <!--{/if}-->
        <br />
        <br />
        <button class="tools" id="btn_cancelRequest" onclick="cancelRequest()"><img src="../libs/dynicons/?img=process-stop.svg&amp;w=16" alt="Cancel Request" title="Cancel Request" style="vertical-align: middle" /> Cancel Request</button>
    </div>

    <!--{if count($comments) > 0}-->
    <div id="comments">
    <h1>Comments</h1>
        <!--{section name=i loop=$comments}-->
            <div><span class="comments_time"><!--{$comments[i].time|date_format:' %b %e'|escape}--></span>
                <span class="comments_name"><!--{$comments[i].actionTextPasttense|sanitize}--> by <!--{$comments[i].name}--></span>
                <div class="comments_message"><!--{$comments[i].comment|sanitize}--></div>
            </div>
        <!--{/section}-->
    </div>
    <!--{/if}-->

    <div id="category_list">
        <h1>Internal Use</h1>
        <button class="IUbutton" onclick="scrollPage('formcontent');openContent('ajaxIndex.php?a=printview&amp;recordID=<!--{$recordID|strip_tags}-->'); "style="vertical-align: middle; background-image: url(../libs/dynicons/?img=text-x-generic.svg&amp;w=16); background-repeat: no-repeat; background-position: left; text-align: left; text-indent: 20px;"> Main Request</button>
        <!--{section name=i loop=$childforms}-->
            <button class="IUbutton" onclick="scrollPage('formcontent');openContent('ajaxIndex.php?a=internalonlyview&amp;recordID=<!--{$recordID|strip_tags}-->&amp;childCategoryID=<!--{$childforms[i].childCategoryID|strip_tags}-->');" style="vertical-align: middle; background-image: url(../libs/dynicons/?img=text-x-generic.svg&amp;w=16); background-repeat: no-repeat; background-position: left; text-align: center"> <!--{$childforms[i].childCategoryName|sanitize}--></button>
        <!--{/section}-->
    </div>

    <div id="metaContainer" style="display: none">
        <div id="metaLabel"></div>
        <div id="metaContent"></div>
    </div>

    <!--{if $is_admin}-->
    <div id="adminTools" class="tools"><h1>Administrative Tools</h1>
        <!--{if $submitted != 0}-->
            <button class="AdminButton" onclick="admin_changeStep()" title="Change Current Step" style="vertical-align: middle; background-image: url(../libs/dynicons/?img=go-jump.svg&w=32); background-repeat: no-repeat; background-position: left; text-align: left; text-indent: 35px; height: 38px"> Change Current Step</button>
        <!--{/if}-->
        <button class="AdminButton" onclick="duplicateFrom()" title="Duplicate From" style="vertical-align: middle; background-image: url(../libs/dynicons/?img=edit-copy.svg&amp;w=32); background-repeat: no-repeat; background-position: left; text-align: left; text-indent: 35px; height: 38px"> Duplicate From</button>
        <button class="AdminButton" onclick="changeService()" title="Change Service" style="vertical-align: middle; background-image: url(../libs/dynicons/?img=user-home.svg&amp;w=32); background-repeat: no-repeat; background-position: left; text-align: left; text-indent: 35px; height: 38px"> Change Service</button>
        <button class="AdminButton" onclick="admin_changeForm()" title="Change Forms" style="vertical-align: middle; background-image: url(../libs/dynicons/?img=system-file-manager.svg&amp;w=32); background-repeat: no-repeat; background-position: left; text-align: left; text-indent: 35px; height: 38px"> Change Form(s)</button>
        <button class="AdminButton" onclick="admin_changeInitiator()" title="Change Initiator" style="vertical-align: middle; background-image: url(../libs/dynicons/?img=gnome-stock-person.svg&amp;w=32); background-repeat: no-repeat; background-position: left; text-align: left; text-indent: 35px; height: 38px"> Change Initiator</button>
    </div>
    <!--{/if}-->
    <div class="toolbar_security">
        <h1 role="heading">Security Permissions</h1>
        <button class="buttonPermission" onclick="viewAccessLogsRead()">
            <!--{if $canRead}-->
            <img src="../libs/dynicons/?img=edit-find.svg&amp;w=32" alt="Read Access" style="vertical-align: middle" /> You have read access
            <!--{else}-->
            <img src="../libs/dynicons/?img=emblem-readonly.svg&amp;w=32" alt="No Read Access" style="vertical-align: middle" tabindex="0"/> You do not have read access
            <!--{/if}-->
        </button>
        <button class="buttonPermission" onclick="viewAccessLogsWrite()">
            <!--{if $canWrite}-->
            <img src="../libs/dynicons/?img=accessories-text-editor.svg&amp;w=32" alt="Write Access" style="vertical-align: middle" /> You have write access
            <!--{else}-->
            <img src="../libs/dynicons/?img=emblem-readonly.svg&amp;w=32" alt="No Write Access" style="vertical-align: middle" /> You do not have write access
            <!--{/if}-->
        </button>
    </div>
</div>

<!-- DIALOG BOXES -->
<div id="formContainer"></div>
<!--{include file="site_elements/generic_xhrDialog.tpl"}-->
<!--{include file="site_elements/generic_confirm_xhrDialog.tpl"}-->
<!--{include file="site_elements/generic_dialog.tpl"}-->

<script type="text/javascript" src="js/functions/toggleZoom.js"></script>
<script type="text/javascript" src="../libs/js/LEAF/sensitiveIndicator.js"></script>
<script type="text/javascript">
let currIndicatorID;
let currSeries;
let recordID = <!--{$recordID|strip_tags}-->;
let serviceID = <!--{$serviceID|strip_tags}-->;
let CSRFToken = '<!--{$CSRFToken}-->';
let formPrintConditions = {};
function doSubmit(recordID) {
	$('#submitControl').empty().html('<img alt="Submitting..." src="./images/indicator.gif" />Submitting...');
	$.ajax({
		type: 'POST',
		url: "./api/form/" + recordID + "/submit",
		data: {CSRFToken: '<!--{$CSRFToken}-->'},
		success: function(response) {
            if(response.errors.length == 0) {
                $('#submitStatus').text('Request submmited');
                $('#submitControl').empty().html('Submitted');
                $('#submitContent').hide('blind', 500);
                workflow.getWorkflow(recordID);
            }
            else {
            	let errors = '';
            	for(let i in response.errors) {
            		errors += response.errors[i] + '<br />';
            	}
                $('#submitControl').empty().html('Error: ' + errors);
                $('#submitStatus').text('Request can not be submmited');
            }
		}
	});
}

function updateTags() {
	$('#tags').fadeOut(250);
	$.ajax({
		type: 'GET',
		url: "./api/form/<!--{$recordID|strip_tags}-->/tags",
		success: function(res) {
			let buffer = '';
			if(res.length > 0) {
				buffer = res.length + ' Bookmarks'
			}
            let tags = $('#tags');
            tags.empty().html(buffer);
            tags.fadeIn(250);
		},
		cache: false
	});
}

function getForm(indicatorID, series) {
  //ie11 fix
  setTimeout(function () {
	   form.dialog().show();
  }, 0);
	form.setPostModifyCallback(function() {
        getIndicator(indicatorID, series);
        updateProgress();
        form.dialog().hide();
	});
	form.getForm(indicatorID, series);
}

function getIndicatorLog(indicatorID, series) {
	dialog_message.setContent('Modifications made to this field:<table class="agenda" style="background-color: white"><thead><tr><th>Date/Author</th><th>Data</th></tr></thead><tbody id="history_'+ indicatorID +'"></tbody></table>');
    dialog_message.indicateBusy();
    //ie11 fix
    setTimeout(function () {
      dialog_message.show();
    }, 0);

    $.ajax({
        type: 'GET',
        url: "api/form/<!--{$recordID|strip_tags}-->/" + indicatorID + "/" + series + '/history',
        success: function(res) {
        	let numChanges = res.length;
            let prev = '';
        	for(let i = 0; i < numChanges; i++) {
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
        url: "ajaxIndex.php?a=getprintindicator&recordID=<!--{$recordID|strip_tags}-->&indicatorID=" + indicatorID + "&series=" + series,
        dataType: 'text',
        success: function(response) {
            let currentPHindicator = $("#PHindicator_" + indicatorID + "_" + series);
            if(currentPHindicator.hasClass("printheading_missing")) {
                currentPHindicator.removeClass("printheading_missing");
                currentPHindicator.addClass("printheading");
            }
            let xhrIndicator = $("#xhrIndicator_" + indicatorID + "_" + series);
            xhrIndicator.empty().html(response);
            xhrIndicator.fadeOut(250, function() {
                xhrIndicator.fadeIn(250);
            });
            for (let c in formPrintConditions) {
                handlePrintConditionalIndicators(formPrintConditions[c]);
            }
        },
        error: function(){ console.log('There was an error getting the indicator!'); },
        cache: false
    });
}

function updateProgress() {
    $.ajax({
        type: 'GET',
        url: "./api/form/<!--{$recordID|strip_tags}-->/progress",
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
                    url: "ajaxIndex.php?a=getsubmitcontrol&recordID=<!--{$recordID|strip_tags}-->",
                    dataType: 'text',
                    success: function(response) {
                        let submitContent = $("#submitContent");
                        submitContent.empty().html(response);
                        submitContent.css({
                            'border': '1px solid black',
                            'text-align': 'center',
                            'background-color': '#ffaeae'
                        });
                        $("#workflowcontent").css({
                            'font-size': "80%",
                            'padding-top': "8px"
                        });
                    },
                    error: function(response) {
                    	$("#xhr").html("Error: " + response);
                    },
                    cache: false
                });
            }
        },
        error: function(){ console.log('There was an error getting the progress!'); },
        cache: false
    });
}

/**
 * Is this even used? I do not see it called here. are there external things that could rely on it?
 */
function hideForm() {
    dialog.hide();
}

function restoreRequest() {
	$.ajax({
		type: 'POST',
		url: "ajaxIndex.php?a=restore",
		data: {
            restore: <!--{$recordID|strip_tags|escape}-->,
            CSRFToken: '<!--{$CSRFToken}-->'
        },
        success: function(response) {
            if(response > 0) {
                window.location.href="index.php?a=printview&recordID=<!--{$recordID|strip_tags}-->";
            }
        },
        error: function(){ console.log('There was an error restoring the request!'); }
	});
}

<!--{if $bookmarked == ''}-->
let bookmarkStatus = 0;
<!--{else}-->
let bookmarkStatus = 1;
<!--{/if}-->

function toggleBookmark() {
    if(bookmarkStatus == 0) {
        addBookmark();
        bookmarkStatus = 1;
        $('#tool_bookmarkText span').empty().html('Delete Bookmark');
    }
    else {
        removeBookmark();
        bookmarkStatus = 0;
        $('#tool_bookmarkText span').empty().html('Add Bookmark');
    }
}

function addBookmark() {
    $.ajax({
        type: 'POST',
        url: "ajaxIndex.php?a=addbookmark&recordID=<!--{$recordID|strip_tags}-->",
        data: {
            CSRFToken: '<!--{$CSRFToken}-->'
        },
        success: function() {
        	updateTags();
        },
        error: function(){ console.log('There was an error adding the bookmark!'); }
    });
}

function removeBookmark() {
    $.ajax({
        type: 'POST',
        url: "ajaxIndex.php?a=removebookmark&recordID=<!--{$recordID|strip_tags}-->",
        data: {CSRFToken: '<!--{$CSRFToken}-->'},
        success: function() {
            updateTags();
        },
        error: function(){ console.log('There was an error removing the bookmark!'); }
    });
}

function handlePrintConditionalIndicators(formPrintConditions) {
    const conditions = formPrintConditions.conditions;
    const format = formPrintConditions.format;
    for (let i in conditions) {
        const elParentInd = document.getElementById('data_' + conditions[i].parentIndID + '_1');
        const elChildInd = document.getElementById('subIndicator_' + conditions[i].childIndID + '_1');

        if ((format === 'dropdown' || format === 'text')
            && elParentInd !== null && conditions[i].selectedOutcome !== 'Pre-fill') {
            //*NOTE: need format for various plugins (icheck, chosen, etc)

            let comparison = false;
            const val = elParentInd.innerHTML.trim();
            const compVal = conditions[i].selectedParentValue;
            //TODO: need format for some comparisons (eg str, num, dates), OR use distinct cases for numbers, dates etc
            switch (conditions[i].selectedOp) {
                case '==':
                    comparison = val === compVal;
                    break;
                case '!=':
                    comparison = val !== compVal;
                    break;
                case '>':
                    comparison = val > compVal;
                    break;
                case '<':
                    comparison = val < compVal;
                    break;
                default:
                    console.log(conditions[i].selectedOp);
                    break;
            }

            switch (conditions[i].selectedOutcome) {
                case 'Hide':
                    comparison ? elChildInd.style.display = "none" : elChildInd.style.display = "block";
                    break;
                case 'Show':
                    comparison ? elChildInd.style.display = "block" : elChildInd.style.display = "none";
                    break;
                default:
                    console.log(conditions[i].selectedOutcome);
                    break;
            }
        }
    }
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
                let boxSizer = {};
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
            for (let c in formPrintConditions) {
                handlePrintConditionalIndicators(formPrintConditions[c]);
            }
    	},
    	error: function(res) {
    		$('#formcontent').empty().html(res);
    	},
    	cache: false
    });
}

function viewAccessLogsRead() {
    // presents logs as bullet points in a message window
    let viewAccessLogsRead = '<!--{foreach from=$accessLogs["read"] item=log}--> <li><!--{$log}--></li> <!--{/foreach}-->';
    dialog_message.setTitle('Security Permissions');
    dialog_message.setContent(viewAccessLogsRead);
    dialog_message.show();
    dialog_message.indicateIdle();
    $('div[role="dialog"]').css('height', '20%');
}

function viewAccessLogsWrite() {
    // presents logs as bullet points in a message window
    let viewAccessLogsWrite = '<!--{foreach from=$accessLogs["write"] item=log}--> <li><!--{$log}--></li> <!--{/foreach}-->';
    dialog_message.setTitle('Access Logs');
    dialog_message.setContent(viewAccessLogsWrite);
    dialog_message.show();
    dialog_message.indicateIdle();
    $('div[role="dialog"]').css('height', '20%');
}

function viewHistory() {
	dialog_message.setContent('');
	dialog_message.show();
	dialog_message.indicateBusy();
	$.ajax({
		type: 'GET',
		url: 'ajaxIndex.php?a=getstatus&recordID=<!--{$recordID|strip_tags}-->',
		dataType: 'text',
		success: function(res) {
			 dialog_message.setContent(res);
			 dialog_message.indicateIdle();
		},
        error: function(){ console.log('There was an error collecting the history!'); },
		cache: false
	});
}

function cancelRequest() {
	dialog_confirm.setContent('<img src="../libs/dynicons/?img=process-stop.svg&amp;w=48" alt="Cancel Request" style="float: left; padding-right: 24px" /> Are you sure you want to cancel this request?');

	dialog_confirm.setSaveHandler(function() {
		$.ajax({
			type: 'POST',
			url: 'api/form/<!--{$recordID|strip_tags|escape}-->/cancel',
			data: {CSRFToken: '<!--{$CSRFToken}-->'},
            success: function(response) {
            	if(response == 1) {
                    window.location.href="index.php?a=cancelled_request&cancelled=<!--{$recordID|strip_tags}-->";
                }
            	else {
            		alert(response);
            	}
            },
            error: function(){ console.log('There was an error canceling the request!'); },
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
            url: 'api/form/<!--{$recordID|strip_tags}-->/title',
            data: {title: $('#title').val(),
                CSRFToken: '<!--{$CSRFToken}-->'},
            success: function(res) {
                if(res != null) {
                      $('#requestTitle').empty().html(res);
                }
                dialog.hide();
            },
            error: function(){ console.log('There was an error changing the title!'); }
        });
    });
}

/**
 *
 * @param {object} indicators
 * @returns {array}
 */
function getChildrenIndicatorIDs(indicators) {
    let children = [];
    Object.values(indicators).forEach(function (indicator) {
        children.push(indicator.indicatorID);
        if(indicator.child){
            let subchildren = getChildrenIndicatorIDs(indicator.child);
            // well this took me a bit to realize concat returns the value of results
            children = children.concat(subchildren);
        }
    });

    return children;
}

/**
 * popup for duplicating the current form
 * will allow an end user to choose which sections they would like to copy over
 */
function duplicateFrom(){

    $('.chosen').chosen({disable_search_threshold: 6});
    // this should be written in pure JS but 1. VUEjs, 2. Need to get it done.
    $('body').on('click','.pickAndChooseAll',function(event){
        $(".pickAndChoose").prop( "checked", event.target.checked );
    }).on('click','.pickAndChoose',function(){
        if($(".pickAndChoose").length===$(".pickAndChoose:checked").length){
            $(".pickAndChooseAll").prop( "checked", true );
        }
        else{
            $(".pickAndChooseAll").prop( "checked", false );
        }
    });

    // options for the service dropdown
    let serviceOptions = '';
    // how is this supposed to work? Old functionality that is no longer used?
    let series = 1;
    // allow the end user to choose what should be copied.
    let pickAndChoose = [];
    // give it all, make it a bit easier
    let pickAndChooseOptions = '<label><input class="pickAndChooseAll" checked="checked" type="checkbox" >All</label><br />';

    // get our service list
    $.ajax({
        type: 'GET',
        url: 'api/service',
        async: false, // I am not going to nest these to make things easier to follow.
        CSRFToken: '<!--{$CSRFToken}-->',
        success: function(res) {
            Object.values(res).forEach(function(resultValue){
                let selected = (parseInt(resultValue.serviceID) === parseInt(serviceID)) ? 'selected="selected"' : '';
                serviceOptions += '<option value="'+resultValue.serviceID+'" '+selected+'>'+resultValue.service+'</option>';
            });
        },
        error: function(){ console.log('Failed to gather services for dropdown!'); }
    });

    // but for now the fields for pick and choose will be done likewise...
    $.ajax({
        type: 'GET',
        url: 'api/form/<!--{$recordID|strip_tags}-->/data/tree',
        CSRFToken: '<!--{$CSRFToken}-->',
        async: false, // I am not going to nest these to make things easier to follow.
        success: function(res) {
            Object.values(res).forEach(function(resultValue) {

                let children = getChildrenIndicatorIDs(resultValue.child);

                pickAndChoose.push({
                    'name' :resultValue.name,
                    'children' : children
                });

            });
        },
        error: function(){ console.log('Failed to gather data to copy as well as make dropdowns'); }
    });

    // I probably can do this in the loop above but trying to keep things readable at this point
    if(pickAndChoose.length > 0){
        pickAndChoose.forEach(function(option){
            // wow, not sure how to work with these entries. was hoping to just get some text here.
            let doc = new DOMParser().parseFromString(option.name, 'text/html');
            let finalName =  doc.body.textContent || "";
            finalName = XSSHelpers.stripAllTags(finalName);

            pickAndChooseOptions += '<label><input class="pickAndChoose" checked="checked" name="pickAndChoose[]" type="checkbox"  value="'+JSON.stringify(option.children)+'" >'+finalName+'</label><br />';
        });
    }

    dialog.setTitle('Duplicate From <!--{$title|escape:'quotes'}-->');
    dialog.setContent('Select new service: <br /><div id="changeService"></div>');
    dialog.setContent(''
        + 'Title:<br />'
        + '<input id="title" name="title" type="text" value="<!--{$title|escape:'quotes'}-->" /><br /><br />'
        + 'Service:<br />'
        + '<select class="chosen" id="service" name="service"> <option value=""></option>'+serviceOptions+'</select><br /><br />'
        + 'Priority:<br />'
        + '<select class="chosen" id="priority" name="priority"><option value="-10">EMERGENCY</option><option value="0" selected="selected">Normal</option></select><br /><br />'
        + 'Sections to Copy:<br />'
        + pickAndChooseOptions
        + '<br /><br />'
    );
    dialog.show();
    dialog.indicateBusy();
    dialog.indicateIdle();
    dialog.setSaveHandler(function() {

        // we will add on the categories in the first ajax call, this takes in what data the end user updates
        let createData = {
            title: $('#title').val(),
            service: $('#service').val(),
            priority: $('#priority').val(),
            CSRFToken: '<!--{$CSRFToken}-->'
        };

        let updateData = {
            series: series,
            CSRFToken: '<!--{$CSRFToken}-->'
        };

        let chosenSections = [];
        let pickAndChooseValues = $("input[name='pickAndChoose[]']:checked")
            .map(function(){
                return chosenSections.concat(JSON.parse($(this).val()));
            }).get();

        // get our data for submission
        // I can probably use this to also allow for pick and choose
        if(pickAndChooseValues.length > 0) {
            $.ajax({
                type: 'GET',
                url: 'api/form/<!--{$recordID|strip_tags}-->/data',
                CSRFToken: '<!--{$CSRFToken}-->',
                async: false, // I am not going to nest these to make things easier to follow.
                success: function (res) {
                    Object.values(res).forEach(function (resultValue) {

                        if (pickAndChooseValues.includes(resultValue[series].indicatorID)) {
                            updateData[resultValue[series].indicatorID] = resultValue[series].value;
                        }

                    });
                },
                error: function () { console.log('Failed to gather data to copy as well as make dropdowns'); }
            });
        }

        // need the "categories" and attach them to the createData
        $.ajax({
            type: 'GET',
            url: 'api/form/<!--{$recordID|strip_tags}-->/recordinfo',
            CSRFToken: '<!--{$CSRFToken}-->',
            async: false, // I am not going to nest these to make things easier to follow.
            success: function(res) {
                // categories attached to the createData, need this to create a new form
                Object.values(res.categories).forEach(function(category) {
                    // your what hurts? value is ignored afaik
                    createData['num'+category] = 'num'+category;
                });
            },
            error: function(){ console.log('Failed to gather categories before creating new form'); }
        });

        // create the new record, we will update the existing data once we get a complete.
        $.ajax({
            type: 'POST',
            url: './api/form/new',
            data: createData,
            success: function(res) {
                let newRecordID = parseFloat(res);
                // this was copied from another area, probably a better way of handling this?
                if(!isNaN(newRecordID) && isFinite(newRecordID) && newRecordID !== 0) {
                    // save the contents, could not tell if this could be done in one call.
                    if(pickAndChooseValues.length > 0) {
                        $.ajax({
                            type: 'POST',
                            url: './api/form/' + newRecordID,
                            data: updateData,
                            success: function () {
                                // then redirect
                                window.location = "index.php?a=view&recordID=" + newRecordID;
                                dialog.hide();
                            },
                            error: function () {
                                console.log('Failed to copy data to new form!')
                            }
                        });
                    }
                }
                else{
                    console.log('Unknown error occurred, could not save contents to form!');
                }
            },
            error: function(){ console.log('Failed to create new form!'); }
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
        url: './api/system/services',
        dataType: 'json',
        success: function(res) {
            let services = '<select id="newService" class="chosen" style="width: 250px">';
            for(let i in res) {
                services += '<option value="'+ res[i].groupID +'">'+ res[i].groupTitle +'</option>';
            }
            services += '</select>';
            $('#changeService').html(services);
            $('.chosen').chosen({disable_search_threshold: 6});
            dialog.indicateIdle();
            dialog.setSaveHandler(function() {
                $.ajax({
                    type: 'POST',
                    url: 'api/form/<!--{$recordID|strip_tags}-->/service',
                    data: {
                        serviceID: $('#newService').val(),
                        CSRFToken: CSRFToken
                    },
                    success: function() {
                        window.location.href="index.php?a=printview&recordID=<!--{$recordID|strip_tags}-->";
                    },
                    error: function(){ console.log('Failed to gather services!'); }
                });
                dialog.hide();
            });
        },
        error: function(){ console.log('There was an error changing the service!'); },
        cache: false
    });
}

<!--{if $is_admin}-->

function admin_changeStep() {
    dialog.setTitle('Change Step');
    dialog.setContent('Set to this step: <br /><div id="changeStep"></div><br /><br />'
                + 'Comments:<br /><textarea id="changeStep_comment" type="text" style="width: 90%; padding: 4px" aria-label="Comments"></textarea>'
                + '<br /><br />'
                + '<fieldset>'
                + '<legend>Advanced Options</legend>'
                + '<input id="showAllSteps" type="checkbox" /><label for="showAllSteps">Show steps from other workflows</label>'
                + '</fieldset>');
    dialog.show();
    dialog.indicateBusy();
    $.ajax({
        type: 'GET',
        url: 'api/formWorkflow/<!--{$recordID|strip_tags}-->/currentStep',
        dataType: 'json',
        success: function(res) {
        	let workflows = {};
        	for(let i in res) {
        		workflows[res[i].workflowID] = 1;
        	}

        	$.ajax({
                type: 'GET',
                url: 'api/workflow/steps',
                dataType: 'json',
                success: function(res) {
                    let steps = '<select id="newStep" class="chosen" style="width: 250px">';
                    let steps2 = '';
                    let stepCounter = 0;
                	for(let i in res) {
                		if(Object.keys(workflows).length == 0
                			|| workflows[res[i].workflowID] != undefined) {
                            steps += '<option value="'+ res[i].stepID +'">' + res[i].description + ': ' + res[i].stepTitle +'</option>';
                            stepCounter++;
                		}
                        steps2 += '<option value="'+ res[i].stepID +'">' + res[i].description + ' - ' + res[i].stepTitle +'</option>';
                	}
                	if(stepCounter == 0) {
                		steps += steps2;
                	}
                	steps += '</select>';
                    $('#changeStep').html(steps);

                    $('#showAllSteps').on('click', function() {
                        let newstep = $('#newStep');
                        if($('#showAllSteps').is(':checked')) {
                            newstep.html(steps2);
                        }
                        else {
                            newstep.html(steps);
                        }
                        newstep.trigger('chosen:updated');
                    });
                    $('.chosen').chosen({disable_search_threshold: 6});
                    dialog.indicateIdle();
                    dialog.setSaveHandler(function() {
                        $.ajax({
                            type: 'POST',
                            url: 'api/formWorkflow/<!--{$recordID|strip_tags}-->/step',
                            data: {
                                stepID: $('#newStep').val(),
                                comment: $('#changeStep_comment').val(),
                                CSRFToken: CSRFToken
                            },
                            success: function() {
                                window.location.href="index.php?a=printview&recordID=<!--{$recordID|strip_tags}-->";
                            },
                            error: function(){ console.log('There was an error saving the workflow step!'); }
                        });
                        dialog.hide();
                    });
                },
                error: function(){ console.log('There was an error getting workflow steps!'); },
                cache: false
        	});
        },
        error: function(){ console.log('There was an error getting the current step!'); },
        cache: false
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
        url: './api/workflow/categoriesUnabridged',
        dataType: 'json',
        success: function(res) {
            let categories = '';
            for(let i in res) {
            	categories += '<label class="checkable leaf_check" for="category_'+ res[i].categoryID +'">';
                categories += '<input type="checkbox" class="icheck admin_changeForm leaf_check" id="category_'+ res[i].categoryID +'" name="categories[]" value="'+ res[i].categoryID +'" />';
                categories += '<span class="leaf_check"></span>'+ res[i].categoryName +'</label>';
            }
            $('#changeForm').html(categories);
            dialog.indicateIdle();
            dialog.setSaveHandler(function() {
                let data = {
                    'categories[]' : [], CSRFToken: CSRFToken
                };
            	$('.admin_changeForm:checked').each(function() {
            		data['categories[]'].push($(this).val());
            	});
                $.ajax({
                    type: 'POST',
                    url: 'api/form/<!--{$recordID|strip_tags}-->/types',
                    data: data,
                    success: function() {
                        window.location.href="index.php?a=printview&recordID=<!--{$recordID|strip_tags}-->";
                    }
                });
                dialog.hide();
            });

            // find current forms
            let query = {terms: [{id: 'recordID', operator: '=', match: '<!--{$recordID|strip_tags}-->'}],joins: ['categoryNameUnabridged']};
            $.ajax({
                type: 'GET',
                url: './api/form/query',
                data: {
                    q: JSON.stringify(query)
                },
                dataType: 'json',
                success: function(res) {
                    let temp = res[<!--{$recordID|strip_tags|escape}-->].categoryNamesUnabridged;
                	$('label.checkable').each(function() {
                		for(let i in temp) {
                            if($(this).text() === temp[i]) {
                                $('#' + $(this).attr('for')).prop('checked', true);
                            }
                		}
                	});
                },
                error: function(){ console.log('There was an error getting the form via query!'); },
                cache: false
            });
        },
        error: function(){ console.log('There was an error getting the categories!'); },
        cache: false
    });
}

function admin_changeInitiator() {
    dialog.setTitle('Change Initiator');
    dialog.setContent('Select employee to be set as this request\'s initiator: <br /><div id="empSel_changeInitiator"></div><input type="hidden" id="changeInitiator" />');
    dialog.show();
    dialog.indicateBusy();

    dialog.setSaveHandler(function() {
        let changeInitiator = $('#changeInitiator');
    	if(changeInitiator.val() != '') {
            $.ajax({
                type: 'POST',
                url: './api/form/<!--{$recordID|strip_tags}-->/initiator',
                data: {
                    CSRFToken: CSRFToken,
                    initiator: changeInitiator.val()
                },
                success: function() {
                    location.reload();
                },
                error: function(){ console.log('There was an error saving the initiator!'); }
            });
    	}
    	else {
    		alert('An employee needs to be selected');
    	}
    });

    let empSel;
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
            },
            error: function(){ console.log('There was an error getting the employee selector!'); }
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
let lastScreenSize = null;
function sideBar() {
//    console.log(window.innerWidth);
    if(lastScreenSize != window.innerWidth) {
        lastScreenSize = window.innerWidth;
        let toolbar = $('#toolbar');
        let maincontent = $('#maincontent');
        if(lastScreenSize < 700) {
            toolbar.removeClass("toolbar_right");
            toolbar.addClass("toolbar_inline");
            maincontent.css("width", "98%");
            toolbar.css("width", "98%");
        }
        else {
            toolbar.removeClass("toolbar_inline");
            toolbar.addClass("toolbar_right");
            // effective width of toolbar becomes around 205px
            mywidth = Math.floor((1 - 250/lastScreenSize) * 100);
            maincontent.css("width", mywidth + "%");
            toolbar.css("width", 98-mywidth + "%");
        }
    }
}

this.portalAPI = LEAFRequestPortalAPI();
this.portalAPI.setBaseURL('api/?a=');
this.portalAPI.setCSRFToken('<!--{$CSRFToken}-->');

$(function() {
    $('#progressBar').progressbar({max: 100});

    form = new LeafForm('formContainer');
    print = new printer();

    $('#btn_printForm').on('click', function() {
        print.printForm(recordID);
    });
    form.setRecordID(<!--{$recordID|strip_tags|escape}-->);

    workflow = new LeafWorkflow('workflowcontent', '<!--{$CSRFToken}-->');
    <!--{if $submitted > 0}-->
    workflow.getWorkflow(<!--{$recordID|strip_tags|escape}-->);
    <!--{/if}-->

    /* General popup window */
    dialog = new dialogController('xhrDialog', 'xhr', 'loadIndicator', 'button_save', 'button_cancelchange');
    dialog_message = new dialogController('genericDialog', 'genericDialogxhr', 'genericDialogloadIndicator', 'genericDialogbutton_save', 'genericDialogbutton_cancelchange');
    dialog_confirm = new dialogController('confirm_xhrDialog', 'confirm_xhr', 'confirm_loadIndicator', 'confirm_button_save', 'confirm_button_cancelchange');

    <!--{if $childCategoryID == ''}-->
    openContent('ajaxIndex.php?a=printview&recordID=<!--{$recordID|strip_tags}-->');
    <!--{else}-->
    openContent('ajaxIndex.php?a=internalonlyview&recordID=<!--{$recordID|strip_tags}-->&childCategoryID=<!--{$childCategoryID|strip_tags}-->');
    <!--{/if}-->

    sideBar();
    setInterval("sideBar()", 500);

    <!--{if $submitted == 0}-->
    updateProgress();
    <!--{/if}-->

    //scroll event for dialog menu
    let elParentForm = document.querySelector('[id^="LeafForm"][id$="_record"]');
    let elFormMenu = document.getElementById('form-xhr-cancel-save-menu');
    window.addEventListener('scroll', function(){
        if (elParentForm && elFormMenu){
            let parent_Y = elParentForm.getBoundingClientRect().y;
            elFormMenu.style.top = parent_Y > 0 ? 0 : (-1 * parent_Y) + "px";
        }
    });
});
</script>
