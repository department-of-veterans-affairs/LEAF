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
        <!--{if $bookmarked == ''}-->
        <button class="tools"  onclick="toggleBookmark()" id="tool_bookmarkText" role="status" aria-live="polite"><img src="../libs/dynicons/?img=bookmark-new.svg&amp;w=32" alt="Add Bookmark" title="Add Bookmark" style="vertical-align: middle" /> <span>Add Bookmark</span></button>
        <!--{else}-->
        <button class="tools" onclick="toggleBookmark()" id="tool_bookmarkText" role="status" aria-live="polite" ><img src="../libs/dynicons/?img=bookmark-new.svg&amp;w=32" alt="Delete Bookmark" title="Delete Bookmark" style="vertical-align: middle"/> <span>Delete Bookmark</span></button>
        <!--{/if}-->
        <button class="tools" onclick="printForm();" ><img src="../libs/dynicons/?img=printer.svg&amp;w=32" alt="Print this Form" title="Print this Form" style="vertical-align: middle" /> Print this Form</button>
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
            <button class="AdminButton" onclick="admin_changeStep()" title="Change Current Step" style="vertical-align: middle; background-image: url(../libs/dynicons/?img=go-jump.svg&w=32); background-repeat: no-repeat; background-position: left; text-align: left; text-indent: 35px; height: 38px"/> Change Current Step</button>
        <!--{/if}-->
        <button class="AdminButton" onclick="changeService()" title="Change Service" style="vertical-align: middle; background-image: url(../libs/dynicons/?img=user-home.svg&amp;w=32); background-repeat: no-repeat; background-position: left; text-align: left; text-indent: 35px; height: 38px"/> Change Service</button>
        <button class="AdminButton" onclick="admin_changeForm()" title="Change Forms" style="vertical-align: middle; background-image: url(../libs/dynicons/?img=system-file-manager.svg&amp;w=32); background-repeat: no-repeat; background-position: left; text-align: left; text-indent: 35px; height: 38px"/> Change Form(s)</button>
        <button class="AdminButton" onclick="admin_changeInitiator()" title="Change Initiator" style="vertical-align: middle; background-image: url(../libs/dynicons/?img=gnome-stock-person.svg&amp;w=32); background-repeat: no-repeat; background-position: left; text-align: left; text-indent: 35px; height: 38px"/> Change Initiator</button>
    </div>
    <!--{/if}-->
</div>

<!-- DIALOG BOXES -->
<div id="formContainer"></div>
<!--{include file="site_elements/generic_xhrDialog.tpl"}-->
<!--{include file="site_elements/generic_confirm_xhrDialog.tpl"}-->
<!--{include file="site_elements/generic_dialog.tpl"}-->

<script type="text/javascript" src="js/functions/toggleZoom.js"></script>
<script type="text/javascript" src="../libs/js/LEAF/sensitiveIndicator.js"></script>
<script type="text/javascript">
var currIndicatorID;
var currSeries;
var recordID = <!--{$recordID|strip_tags}-->;
var serviceID = <!--{$serviceID|strip_tags}-->;
var CSRFToken = '<!--{$CSRFToken}-->';
function doSubmit(recordID) {
	$('#submitControl').empty().html('<img src="./images/indicator.gif" />Submitting...');
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
            	var errors = '';
            	for(var i in response.errors) {
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
		url: "./api/?a=form/<!--{$recordID|strip_tags}-->/tags",
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
        url: "api/?a=form/<!--{$recordID|strip_tags}-->/" + indicatorID + "/" + series + '/history',
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
        url: "ajaxIndex.php?a=getprintindicator&recordID=<!--{$recordID|strip_tags}-->&indicatorID=" + indicatorID + "&series=" + series,
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
		data: {restore: <!--{$recordID|strip_tags|escape}-->,
            CSRFToken: '<!--{$CSRFToken}-->'},
        success: function(response) {
            if(response > 0) {
                window.location.href="index.php?a=printview&recordID=<!--{$recordID|strip_tags}-->";
            }
        }
	});
}

<!--{if $bookmarked == ''}-->
var bookmarkStatus = 0;
<!--{else}-->
var bookmarkStatus = 1;
<!--{/if}-->

function printForm() {
    var doc = new jsPDF({lineHeight: 1.3});
    var blank = false;

    var width = doc.internal.pageSize.getWidth();
    var height = doc.internal.pageSize.getHeight();

    var indicatorData = [];
    var requestTitle = $('#requestTitle').clone();
    requestTitle.find('img').remove();
    requestTitle.find('br').remove();
    requestTitle.find('span').remove();
    doc.text(requestTitle.text(), 33, 10);
    doc.setTextColor(80,80,80);
    doc.setFontStyle("italic");
    doc.text($('#requestTitle > span').text(), 33, 17);
    doc.text($('#headerDescription').text(), 33, 24);
    doc.text($('#headerLabel').text(), 33, 31);
    doc.setTextColor(0,0,0);
    doc.setFontStyle("normal");

    function getBase64Image(img) {
        // Create an empty canvas element
        var canvas = document.createElement("canvas");
        canvas.width = img.width;
        canvas.height = img.height;

        // Copy the image contents to the canvas
        var ctx = canvas.getContext("2d");
        ctx.drawImage(img, 0, 0);

        var dataURL = canvas.toDataURL("image/png");

        return dataURL.replace(/^data:image\/(png|jpg);base64,/, "");
    }

    if (!blank) {
        doc.text($('#requestInfo > table > tbody > tr:eq(1) > td:eq(0)').text() + ' ' + $('#requestInfo > table > tbody > tr:eq(1) > td:eq(1)').text(), 200, 10, null, null, 'right');
        doc.text($('#requestInfo > table > tbody > tr:eq(2) > td:eq(0)').text() + ' ' + $('#requestInfo > table > tbody > tr:eq(2) > td:eq(1)').text(), 200, 17, null, null, 'right');
        doc.addImage(getBase64Image($('img[alt="QR code"]')[0]), 'PNG', 8, 6, 25, 25);
    } else {
        var img = document.createElement('img');
        var homeURL = encodeURIComponent($('span#headerMenu > a[href="./"]')[0].href);
        img.setAttribute('class', 'print nodisplay');
        img.setAttribute('style', "width: 72px");
        img.setAttribute('src', '../libs/qrcode/?encode=' + homeURL);
        $(img).on('load', function() {
            doc.addImage(getBase64Image(this), 'PNG', 8, 6, 25, 25);
        });
    }

    function cleanTags(input) {
        input = input.replace(/(<li>)/ig,"-");
        input = input.replace(/(<([^>]+)>)/ig,"\n");
        return input;
    }

    function makePdf(data) {
        var verticalShift = 30;
        var makeCount = 0;
        var numInRow = 0;
        var horizontalShift = 20;
        var maxWidth = 170;
        var subCount = 1;
        var lineSpacing = doc.getFontSize() * 1.28 * 25.4 / 72;
        var page = 1;
        var htmlPattern = new RegExp('<([^>]+)>');
        var date = new Date().toJSON().slice(0,10).replace(/-/g,'/');

        function pageFooter(isLast) {
            var originalColor = doc.getTextColor();
            doc.setTextColor(0);
            doc.line(20, height - 10, width - 20, height - 10);
            doc.setFontSize(10);
            doc.setFont("times");
            doc.text($('#requestTitle > span').text(), 20, height - 7);
            doc.text(page.toString(), 188, height - 7);
            if (!isLast) {
                doc.text('Continued on the next page.', 105, height - 7, null, null, 'center');
                page++;
            } else {
                doc.text('This form was generated by LEAF on ' + date, 105, height - 7, null, null, 'center');
            }
            doc.setFont("helvetica");
            doc.setFontSize(16);
            doc.setTextColor(originalColor);
        }

        function subNewRow() {
            numInRow = 0;
            verticalShift += 12;
            horizontalShift = 20;
            maxWidth = 170;
        }

        function makeEntry(indicator, parentID, depth, numAtLevel) {
            var required = Number(indicator.required) === 1 ? ' *' : '';
            var number = depth === 0 ? indicator.indicatorID : parentID + '.' + subCount;
            var storedSubCount = subCount;
            doc.setFillColor(30, 70, 125);
            if (depth === 0) {
                verticalShift += 10;
                doc.setTextColor(255);
                doc.setDrawColor(0);
            } else {
                doc.setTextColor(0);
            }

            if (verticalShift > height - 70) {
                pageFooter(false);
                doc.addPage();
                verticalShift = 30;
            }
            var value = htmlPattern.test(indicator.value) ? cleanTags(indicator.value) : indicator.value;
            var splitText = doc.splitTextToSize(value, 140);
            var lines = 1;

            $.each(splitText, function(i) {
                if (splitText[i].length !== 0) {
                    lines++;
                }
            });

            if (depth > 0) {
                var title = number + ': ' + indicator.name;
                switch (indicator.format) {
                    case 'date':
                    case 'text':
                        if (title.length > value.length) {
                            var sizeOfBox = title.length * 3.5;
                        } else {
                            var sizeOfBox = value.length > 0 ? value.length * 3.5 : numInRow * 170/numAtLevel;
                        }
                        if (sizeOfBox > maxWidth) {
                            if (title.length > value.length) {
                                var sizeOfBox = title.length * 3.5;
                            } else {
                                var sizeOfBox = value.length > 0 ? value.length * 3.5 : numInRow * 170/numAtLevel;
                            }
                            subNewRow();
                        }
                        doc.rect(horizontalShift, verticalShift, maxWidth, 12);
                        doc.setFontSize(8);
                        doc.text(title + required, horizontalShift + 1, verticalShift + 3);
                        doc.setFontSize(16);
                        if (!blank) {
                            doc.text(value, horizontalShift + 2, verticalShift + 10);
                        }
                        maxWidth = maxWidth - sizeOfBox;
                        horizontalShift += sizeOfBox;
                        makeCount++;
                        numInRow++;
                        break;
                    case 'textarea':
                        subNewRow();
                        var fitSize = !blank ? lines * lineSpacing : 60;
                        var start = verticalShift;
                        doc.setFontSize(8);
                        doc.text(title + required, 21, verticalShift + 3);
                        doc.setFontSize(16);
                        if (!blank) {
                            for (var i = 0; i < splitText.length; i++) {
                                if (verticalShift >= height - 30) {
                                    pageFooter(false);
                                    doc.addPage();
                                    doc.setTextColor(255);
                                    doc.setDrawColor(0);
                                    doc.setFillColor(30, 70, 125);
                                    verticalShift = 30;
                                    fitSize = (splitText.length - i) * lineSpacing;
                                    doc.rect(20, verticalShift, 170, fitSize + 20, 'FD');
                                    doc.rect(25, verticalShift + 8, 120, fitSize + 8, 'FD');
                                    doc.text(indicator.name + ' continued' + required, 21, verticalShift + 6);
                                }
                                doc.setTextColor(0);
                                doc.text(splitText[i], 30, verticalShift + 16);
                                verticalShift += lineSpacing;
                            }
                        } else {
                            verticalShift += 5 * lineSpacing;
                        }
                        doc.rect(20, start, 170, verticalShift - start + 16);
                        verticalShift += 2.19 * lineSpacing;
                        break;
                    case 'radio':
                    case 'checkbox':
                    case 'checkboxes':
                        var sizeOfBox = 0;
                        $.each(indicator.options, function(i) {
                            sizeOfBox += this.length * 3.5 + 20;
                        });
                        doc.setFontSize(8);

                        if (sizeOfBox > maxWidth) {
                            subNewRow();
                        }
                        doc.rect(horizontalShift, verticalShift, maxWidth, 12);
                        doc.text(title + required, horizontalShift + 1, verticalShift + 3);
                        doc.setFontSize(16);
                        for (var i = 0; i < indicator.options.length; i++) {
                            var sizeOfOption = indicator.options[i].length * 3.5;
                            sizeOfBox += sizeOfOption;
                            doc.text(indicator.options[i], horizontalShift + 2, verticalShift + 10.5);
                            doc.rect(sizeOfOption + horizontalShift + 3, verticalShift + 6, 5, 5);
                            if (!blank && indicator.value.indexOf(indicator.options[i]) > -1) {
                                doc.text('x', sizeOfOption + horizontalShift + 4, verticalShift + 10.5);
                            }
                            horizontalShift += 20;
                        }
                        // doc.text(value, horizontalShift + 2, verticalShift + 10);
                        maxWidth = maxWidth - sizeOfBox;
                        horizontalShift += sizeOfBox;
                        makeCount++;
                        numInRow++;
                        break;
                    default:
                        subNewRow();
                        doc.rect(20, verticalShift, 170, 12, 'FD');
                        doc.setTextColor(255);
                        doc.text(number + ': ' + indicator.name + required, 105, verticalShift + 8, null, null, 'center');
                        subNewRow();
                }
            } else {
                switch (indicator.format) {
                    case 'date':
                    case 'text':
                        doc.setFillColor(30, 70, 125);
                        doc.rect(20, verticalShift, 170, 8, 'FD');
                        doc.rect(20, verticalShift + 8, 170, 8);
                        doc.text(number + ': ' + indicator.name + required, 21, verticalShift + 6);
                        doc.setTextColor(0);
                        if (!blank) {
                            doc.text(value, 21, verticalShift + 14);
                        }
                        verticalShift += 16;
                        break;
                    case 'textarea':
                        var fitSize = !blank ? lines * 2 * lineSpacing : 60;
                        doc.setFillColor(30, 70, 125);
                        doc.rect(20, verticalShift, 170, 8, 'FD');
                        if (fitSize >= height - 70) {
                            doc.rect(20, verticalShift + 8, 170, height - 12 - (verticalShift + 8));
                        }
                        doc.text(number + ': ' + indicator.name + required, 21, verticalShift + 6);
                        doc.setTextColor(0);
                        var start = verticalShift + 8;
                        verticalShift += lineSpacing;
                        if (!blank) {
                            for (var i = 0; i < splitText.length; i++) {
                                if (verticalShift >= height - 30) {
                                    pageFooter(false);
                                    doc.addPage();
                                    doc.setTextColor(255);
                                    doc.setDrawColor(0);
                                    doc.setFillColor(30, 70, 125);
                                    verticalShift = 30;
                                    start = 30;
                                    fitSize = (splitText.length - i) * lineSpacing;
                                    doc.rect(20, verticalShift, 170, 8, 'FD');
                                    doc.text(indicator.name + ' continued' + required, 21, verticalShift + 6);
                                }
                                doc.setTextColor(0);
                                doc.text(splitText[i], 30, verticalShift + (2 * lineSpacing));
                                verticalShift += lineSpacing;
                            }
                            verticalShift += lineSpacing;
                        } else {
                            verticalShift += 5 * lineSpacing;
                        }
                        doc.rect(20, start, 170, verticalShift - start);
                        break;
                    case 'radio':
                    case 'checkbox':
                    case 'checkboxes':
                        doc.setFillColor(30, 70, 125);
                        doc.rect(20, verticalShift, 170, 16, 'FD');
                        doc.setTextColor(255);
                        doc.text(number + ': ' + indicator.name + required, 21, verticalShift + 6);
                        for (var i = 0; i < indicator.options.length; i++) {
                            var sizeOfOption = indicator.options[i].length * 3.5;
                            doc.text(indicator.options[i], horizontalShift + 2, verticalShift + 12.5);
                            doc.rect(sizeOfOption + horizontalShift + 3, verticalShift + 8, 5, 5, 'F');
                            if (!blank && indicator.value.indexOf(indicator.options[i]) > -1) {
                                doc.setTextColor(0);
                                doc.text('x', sizeOfOption + horizontalShift + 4, verticalShift + 12.5);
                                doc.setTextColor(255);
                            }
                            horizontalShift += 20;
                        }
                        horizontalShift = 20;
                        doc.setFillColor(30, 70, 125);
                        verticalShift += 16;
                        break;
                    default:
                        doc.rect(20, verticalShift, 170, 8, 'FD');
                        doc.text(number + ': ' + indicator.name + required, 105, verticalShift + 6, null, null, 'center');
                        verticalShift += 8;
                        break;
                }
            }
            if (indicator.child !== undefined && indicator.child !== null) {
                subCount = 0;
                $.each(indicator.child, function () {
                    subCount += 1;
                    makeEntry(this, number, depth + 1, Object.keys(indicator.child).length);
                });
                subCount = storedSubCount;
            }
        }
        $.each(data, function() {
            makeEntry(this, null, 0, 0);
            if (this.child !== undefined && this.child !== null) {
                makeCount = 0;
                subNewRow();
            }
        });
        pageFooter(true);

        doc.text('* = required field', 170, verticalShift + 10, null, null, 'right');
        doc.save(requestTitle.text().replace(/(?:\r\n|\r|\n)/g, "") + '- ' + $('#requestTitle > span').text() +'.pdf');
    }
    var indicatorCount = 0;
    var index = 1;
    var indicators = new Object();
    function getIndicatorData(indicator) {
        $.ajax({
            method: 'GET',
            url: './api/form/' + recordID + '/rawIndicator/' + indicator.indicatorID + '/' + indicator.series,
            dataType: 'json',
            cache: false
        }).done(function(res) {
            if (index === indicatorCount) {
                makePdf(indicatorData);
            } else {
                if ("parentID" in res[index] && res[index].parentID === null) {
                    indicatorData.push(res[index]);
                }
                index++;
                getIndicatorData(indicators[index][1]);
            }
        }).fail(function(err) {
            console.log(err);
        });
    }
    $.ajax({
        method: 'GET',
        url: './api/form/' + recordID + '/data',
        dataType: 'json',
        cache: false
    }).done(function(res) {
        indicatorCount = Object.keys(res).length;
        indicators = res;
        getIndicatorData(indicators[index][1]);
    }).fail(function(err) {
        console.log(err);
    });
}

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
        data: {CSRFToken: '<!--{$CSRFToken}-->'},
        success: function(response) {
        	updateTags();
        }
    });
}

function removeBookmark() {
    $.ajax({
        type: 'POST',
        url: "ajaxIndex.php?a=removebookmark&recordID=<!--{$recordID|strip_tags}-->",
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
		url: 'ajaxIndex.php?a=getstatus&recordID=<!--{$recordID|strip_tags}-->',
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
            cache: false
		});
	});
	dialog_confirm.show();
}

function changeTitle() {
	dialog.setContent('Title: <input type="text" id="title" style="width: 300px" name="title" value="<!--{$title|escape:'quotes'}-->" /><input type="hidden" id="CSRFToken" name="CSRFToken" value="<!--{$CSRFToken}-->" />');
  //ie11 fix
  setTimeout(function () {
    dialog.show();
  }, 0);
    dialog.setSaveHandler(function() {
        $.ajax({
        	type: 'POST',
        	url: 'api/?a=form/<!--{$recordID|strip_tags}-->/title',
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
    //ie11 fix
    setTimeout(function () {
      dialog.show();
    }, 10);

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
                    url: 'api/?a=form/<!--{$recordID|strip_tags}-->/service',
                    data: {serviceID: $('#newService').val(),
                           CSRFToken: CSRFToken},
                    success: function() {
                        window.location.href="index.php?a=printview&recordID=<!--{$recordID|strip_tags}-->";
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
        url: 'api/?a=formWorkflow/<!--{$recordID|strip_tags}-->/currentStep',
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
                        if($('#showAllSteps').is(':checked')) {
                            $('#newStep').html(steps2);
                        }
                        else {
                            $('#newStep').html(steps);
                        }
                        $('#newStep').trigger('chosen:updated');
                    });
                    $('.chosen').chosen({disable_search_threshold: 6});
                    dialog.indicateIdle();
                    dialog.setSaveHandler(function() {
                        $.ajax({
                            type: 'POST',
                            url: 'api/?a=formWorkflow/<!--{$recordID|strip_tags}-->/step',
                            data: {stepID: $('#newStep').val(),
                            	   comment: $('#changeStep_comment').val(),
                                   CSRFToken: CSRFToken},
                            success: function() {
                                window.location.href="index.php?a=printview&recordID=<!--{$recordID|strip_tags}-->";
                            }
                        });
                        dialog.hide();
                    });
                },
                cache: false
        	});
        },
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
                    url: 'api/?a=form/<!--{$recordID|strip_tags}-->/types',
                    data: data,
                    success: function() {
                        window.location.href="index.php?a=printview&recordID=<!--{$recordID|strip_tags}-->";
                    }
                });
                dialog.hide();
            });

            // find current forms
            var query = {terms: [{id: 'recordID', operator: '=', match: '<!--{$recordID|strip_tags}-->'}],joins: ['categoryNameUnabridged']};
            $.ajax({
                type: 'GET',
                url: './api/?a=form/query',
                data: {q: JSON.stringify(query)},
                dataType: 'json',
                success: function(res) {
                	var temp = res[<!--{$recordID|strip_tags|escape}-->].categoryNamesUnabridged;
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
                url: './api/?a=form/<!--{$recordID|strip_tags}-->/initiator',
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

this.portalAPI = LEAFRequestPortalAPI();
this.portalAPI.setBaseURL('api/?a=');
this.portalAPI.setCSRFToken('<!--{$CSRFToken}-->');

$(function() {
    $('#progressBar').progressbar({max: 100});

    form = new LeafForm('formContainer');
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

});

</script>
