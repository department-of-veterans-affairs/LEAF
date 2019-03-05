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
    doc.setFontSize(12);
    var blank = false;

    var width = doc.internal.pageSize.getWidth();
    var height = doc.internal.pageSize.getHeight();
    var verticalShift = 17;

    var indicatorData = [];
    var requestInfo = new Object();
    var homeQR = document.createElement('img');
    var homeURL = encodeURIComponent($('a[href="./"]')[0].href);
    homeQR.setAttribute('class', 'print nodisplay');
    homeQR.setAttribute('style', "width: 72px");
    homeQR.setAttribute('src', '../libs/qrcode/?encode=' + homeURL);

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

    function cleanTagsAndWhitespace(input) {
        if (typeof (input) !== "undefined" && input !== null) {
            input = input.replace(/(<li>)/ig, "- ");
            input = input.replace(/(<\/li>)/ig, "\n");
            return input.trim();
        } else {
            return '';
        }
    }

    function decodeHTMLEntities (str) {
        return $("<div/>").html(str).text();
    }

    function makePdf(data) {
        var makeCount = 0;
        var numInRow = 0;
        var horizontalShift = 10;
        var maxWidth = 190;
        var subCount = 1;
        var lineSpacing = doc.getFontSize() * 1.28 * 25.4 / 72;
        var page = 1;
        var htmlPattern = new RegExp('<([^>]+)>');
        var date = new Date().toJSON().slice(0,10).replace(/-/g,'/');
        var checkBoxShift = 0;

        // set to true for first sub question of each header
        var subShift = true;

        doc.setFont("Helvetica");
        doc.setFontSize(12);

        function pageFooter(isLast) {
            var originalColor = doc.getTextColor();
            doc.setTextColor(0);
            doc.line(10, height - 10, width - 10, height - 10);
            doc.setFontSize(10);
            doc.setFont("times");
            if (requestInfo['workflows'].length > 1) {
                doc.text("Multiple forms", 10, height - 7);
            } else {
                doc.text(requestInfo['workflows'][0][0]['categoryName'], 10, height - 7);
            }
            doc.text(page.toString(), 198, height - 7);
            if (!isLast) {
                doc.text('Continued on the next page.', 105, height - 7, null, null, 'center');
                page++;
            } else {
                doc.text('This form was generated by LEAF on ' + date, 105, height - 7, null, null, 'center');
            }
            doc.setFontSize(12);
            doc.setFont("Helvetica");
            doc.setTextColor(originalColor);
        }

        function subNewRow() {
            numInRow = 0;
            verticalShift += 12;
            horizontalShift = 10;
            maxWidth = 190;
        }

        function makeEntry(indicator, parentIndex, depth, numAtLevel, index) {
            var required = Number(indicator.required) === 1 ? ' *' : '';
            var number = depth === 0 ? index : parentIndex + '.' + subCount;
            var storedSubCount = subCount;
            var sizeOfBox = 0;
            var fitSize = 0;
            var verticalStart = 0;
            var horizontalStart = 0;
            var sizeOfOption = 0;

            if (depth === 0) {
                verticalShift += 10;
                doc.setTextColor(255);
                doc.setDrawColor(0);
            } else {
                doc.setTextColor(0);
            }

            if (verticalShift > height - 40) {
                pageFooter(false);
                doc.addPage();
                verticalShift = 10;
            }

            doc.setFillColor(30, 70, 125);
            var value = htmlPattern.test(indicator.value.toString()) ? decodeHTMLEntities(cleanTagsAndWhitespace(indicator.value)) : decodeHTMLEntities(indicator.value);
            var splitText = doc.splitTextToSize(value, 140);
            var lines = 1;

            $.each(splitText, function(i) {
                if (splitText[i].length !== 0) {
                    lines++;
                }
            });

            function textSub() {
                if (title.length > value.length) {
                    sizeOfBox = title.length * 3.5;
                } else {
                    sizeOfBox = value.length > 0 ? value.length * 3.5 : numInRow * 190 / numAtLevel;
                }
                if (sizeOfBox > maxWidth) {
                    if (title.length > value.length) {
                        sizeOfBox = title.length * 3.5;
                    } else {
                        sizeOfBox = value.length > 0 ? value.length * 3.5 : numInRow * 190 / numAtLevel;
                    }
                    subNewRow();
                }
                doc.rect(horizontalShift, verticalShift, maxWidth, 12);
                doc.setFontSize(8);
                doc.text(title + required, horizontalShift + 1, verticalShift + 3);
                doc.setFontSize(12);
                if (!blank && typeof (value) !== "undefined") {
                    doc.setFont("times");
                    doc.text(value, horizontalShift + 2, verticalShift + 10);
                }
                doc.setFont("Helvetica");
                maxWidth = maxWidth - sizeOfBox;
                horizontalShift += sizeOfBox;
                makeCount++;
                numInRow++;
            }

            function textHeader() {
                verticalShift += -4;
                var header = number + ': ' + decodeHTMLEntities(indicator.name) + required;
                var headerSplit = doc.splitTextToSize(header, 40);
                var shiftHeaderText = headerSplit.length * 8;
                doc.setFillColor(30, 70, 125);
                doc.rect(10, verticalShift, 190, shiftHeaderText, 'FD');
                doc.setFillColor(255);
                doc.rect(50, verticalShift, 150, shiftHeaderText, 'FD');
                for (var i = 0; i < headerSplit.length; i++) {
                    doc.text(headerSplit[i], 11, verticalShift + 6 + 8*i);
                }
                doc.setFillColor(30, 70, 125);
                doc.setTextColor(0);
                if (!blank && typeof (value) !== "undefined") {
                    doc.setFont("times");
                    doc.text(value, 51, verticalShift + 6);
                }
                doc.setFont("Helvetica");
                verticalShift += headerSplit.length * 8;
            }

            if (depth > 0) {
                var title = number + ': ' + decodeHTMLEntities(indicator.name);
                if (subShift) {
                    // verticalShift += 4;
                    subShift = false;
                }
                switch (indicator.format) {
                    case 'orgchart_employee':
                        value = value !== '' ? cleanTagsAndWhitespace($('#data_' + indicator.indicatorID + '_' + indicator.series).find('a').html()) : '';
                        textSub();
                        break;
                    case 'orgchart_group':
                        value = value !== '' ? cleanTagsAndWhitespace($('#data_' + indicator.indicatorID + '_' + indicator.series).text()) : '';
                        textSub();
                        break;
                    case 'orgchart_position':
                        value = value !== '' ? cleanTagsAndWhitespace($('#data_' + indicator.indicatorID + '_' + indicator.series + ' > div:first')
                            .clone()
                            .children()
                            .remove()
                            .end()
                            .text()) : '';
                        textSub();
                        break;
                    case 'date':
                    case 'currency':
                    case 'text':
                        textSub();
                        break;
                    case 'textarea':
                        if (maxWidth !== 190) {
                            subNewRow();
                        }
                        fitSize = !blank ? lines * lineSpacing : 60;
                        verticalStart = verticalShift;
                        doc.setFontSize(8);
                        doc.text(title + required, 11, verticalShift + 3);
                        doc.setFontSize(12);
                        if (!blank && typeof (value) !== "undefined") {
                            doc.setFont("times");
                            for (var i = 0; i < splitText.length; i++) {
                                if (verticalShift >= height - 40) {
                                    pageFooter(false);
                                    doc.addPage();
                                    doc.setTextColor(255);
                                    doc.setDrawColor(0);
                                    doc.setFillColor(30, 70, 125);
                                    verticalShift = 10;
                                    fitSize = (splitText.length - i) * lineSpacing;
                                    doc.rect(10, verticalShift, 190, fitSize + 20, 'FD');
                                    doc.rect(15, verticalShift + 8, 130, fitSize + 8, 'FD');
                                    doc.setFontSize(8);
                                    doc.setFont("helvetica");
                                    doc.text(decodeHTMLEntities(indicator.name) + ' continued' + required, 11, verticalShift + 6);
                                    doc.setFontSize(12);
                                    doc.setFont("times");
                                }
                                doc.setTextColor(0);
                                doc.text(splitText[i], 15, verticalShift + 16);
                                verticalShift += lineSpacing;
                            }
                        } else {
                            verticalShift += 5 * lineSpacing;
                        }
                        doc.setFont("Helvetica");
                        doc.rect(10, verticalStart, 190, verticalShift - verticalStart + 16);
                        verticalShift += 2.17 * (lineSpacing + 2);
                        break;
                    case 'radio':
                    case 'dropdown':
                    case 'checkbox':
                    case 'checkboxes':
                        $.each(indicator.options, function () {
                            sizeOfBox += this.length * 3.5 + 20;
                        });
                        doc.setFontSize(8);

                        if (sizeOfBox > maxWidth && maxWidth !== 190) {
                            subNewRow();
                        }
                        checkBoxShift = 0;
                        $.each(indicator.options, function() {
                            checkBoxShift = this.length > checkBoxShift ? this.length : checkBoxShift;
                        });
                        checkBoxShift = checkBoxShift * 3.5 > 20 ? checkBoxShift * 3.5 : 20;
                        doc.text(title + required, horizontalShift + 1, verticalShift + 3);
                        doc.setFontSize(12);
                        if (maxWidth > 190) {
                            horizontalShift = 15;
                        } else {
                            horizontalStart = horizontalShift;
                        }
                        verticalStart = verticalShift;
                        horizontalShift += 5;
                        for (var i = 0; i < indicator.options.length; i++) {
                            if (horizontalShift > 160) {
                                subNewRow();
                                horizontalShift += 5;
                            }
                            doc.rect(horizontalShift, verticalShift + 6, 5, 5);
                            if (!blank && indicator.value.indexOf(indicator.options[i]) > -1) {
                                doc.text('x', horizontalShift + 1.5, verticalShift + 9.5);
                            }
                            sizeOfOption = indicator.options[i].length * 2.5;
                            doc.setFont("times");
                            doc.text(decodeHTMLEntities(indicator.options[i]), horizontalShift + 6, verticalShift + 10.5);
                            doc.setFont("Helvetica");
                            horizontalShift += checkBoxShift;
                            sizeOfBox += sizeOfOption;
                        }
                        if (verticalStart === verticalShift) {
                            doc.rect(horizontalStart, verticalStart, maxWidth, 12);
                        } else {
                            doc.rect(10, verticalStart, maxWidth, 12 + verticalShift - verticalStart);
                        }
                        maxWidth = maxWidth - sizeOfBox;
                        horizontalShift += sizeOfBox;
                        makeCount++;
                        numInRow++;
                        break;
                    default:
                        if (maxWidth !== 190) {
                            subNewRow();
                        }
                        doc.rect(10, verticalShift, 190, 12, 'FD');
                        doc.setTextColor(255);
                        doc.setFont("helvetica");
                        doc.text(number + ': ' + decodeHTMLEntities(indicator.name) + required, 11, verticalShift + 8);
                        subNewRow();
                }
            } else {
                switch (indicator.format) {
                    case 'orgchart_employee':
                        value = value !== '' ? cleanTagsAndWhitespace($('#data_' + indicator.indicatorID + '_' + indicator.series).find('a').html()) : '';
                        textHeader();
                        break;
                    case 'orgchart_group':
                        value = value !== '' ? cleanTagsAndWhitespace($('#data_' + indicator.indicatorID + '_' + indicator.series).text()) : '';
                        textHeader();
                        break;
                    case 'orgchart_position':
                        value = value !== '' ? cleanTagsAndWhitespace($('#data_' + indicator.indicatorID + '_' + indicator.series + ' > div:first')
                            .clone()
                            .children()
                            .remove()
                            .end()
                            .text()) : '';
                        textHeader();
                        break;
                    case 'date':
                    case 'currency':
                    case 'text':
                        textHeader();
                        break;
                    case 'textarea':
                        verticalShift += -4;
                        fitSize = !blank ? lines * 2 * lineSpacing : 60;
                        doc.setFillColor(30, 70, 125);
                        doc.rect(10, verticalShift, 190, 8, 'FD');
                        if (fitSize >= height - 70) {
                            doc.rect(10, verticalShift + 8, 190, height - 12 - (verticalShift + 8));
                        }
                        doc.text(number + ': ' + decodeHTMLEntities(indicator.name) + required, 11, verticalShift + 6);
                        doc.setTextColor(0);
                        verticalStart = verticalShift + 8;
                        verticalShift += lineSpacing;
                        if (!blank && typeof (value) !== "undefined") {
                            doc.setFont("times");
                            for (var i = 0; i < splitText.length; i++) {
                                if (verticalShift >= height - 40) {
                                    pageFooter(false);
                                    doc.addPage();
                                    doc.setTextColor(255);
                                    doc.setDrawColor(0);
                                    doc.setFillColor(30, 70, 125);
                                    verticalShift = 10;
                                    verticalStart = 10;
                                    fitSize = (splitText.length - i) * lineSpacing;
                                    doc.rect(10, verticalShift, 190, 8, 'FD');
                                    doc.text(decodeHTMLEntities(indicator.name) + ' continued' + required, 11, verticalShift + 6);
                                    doc.setFont("times");
                                }
                                doc.setTextColor(0);
                                doc.text(splitText[i], 15, verticalShift + (2 * lineSpacing));
                                verticalShift += lineSpacing;
                            }
                            verticalShift += 2 * lineSpacing;
                        } else {
                            verticalShift += 5 * lineSpacing;
                        }
                        doc.setFont("Helvetica");
                        doc.rect(10, verticalStart, 190, verticalShift - verticalStart);
                        break;
                    case 'radio':
                    case 'dropdown':
                    case 'checkbox':
                    case 'checkboxes':
                        verticalShift += -4;
                        var header = number + ': ' + decodeHTMLEntities(indicator.name) + required;
                        var headerSplit = doc.splitTextToSize(header, 40);
                        var shiftHeaderText = headerSplit.length * 8;
                        checkBoxShift = 0;
                        $.each(indicator.options, function() {
                            checkBoxShift = this.length > checkBoxShift ? this.length : checkBoxShift;
                        });
                        checkBoxShift = checkBoxShift * 3.5 > 20 ? checkBoxShift * 3.5 : 20;
                        horizontalShift = 60;
                        verticalStart = verticalShift + 4;
                        doc.setTextColor(0);
                        doc.setFont("times");
                        for (var i = 0; i < indicator.options.length; i++) {
                            if (horizontalShift > maxWidth) {
                                verticalShift += 16;
                                horizontalShift = 60;
                            }
                            if (verticalShift >= height - 40) {
                                doc.setFont("helvetica");
                                doc.setFillColor(30, 70, 125);
                                if (verticalShift - verticalStart > shiftHeaderText) {
                                    doc.rect(10, verticalStart, 190, verticalShift - verticalStart);
                                    doc.rect(10, verticalStart, 40, verticalShift - verticalStart, 'FD');
                                } else {
                                    doc.rect(10, verticalStart, 190, shiftHeaderText);
                                    doc.rect(10, verticalStart, 40, shiftHeaderText, 'FD');
                                    verticalShift += shiftHeaderText;
                                }
                                doc.setTextColor(255);
                                doc.setFillColor(30, 70, 125);
                                doc.setFillColor(255);
                                for (var i = 0; i < headerSplit.length; i++) {
                                    doc.text(headerSplit[i], 11, verticalStart + 6 + 8*i);
                                }
                                doc.setTextColor(0);
                                doc.setFont("times");
                                pageFooter(false);
                                doc.addPage();
                                doc.setTextColor(255);
                                doc.setDrawColor(0);
                                doc.setFillColor(30, 70, 125);
                                verticalShift = 10;
                                verticalStart = 10;
                                header = decodeHTMLEntities(indicator.name) + ' continued' + required;
                                headerSplit = doc.splitTextToSize(header, 38);
                                shiftHeaderText = headerSplit.length * 8;
                            }
                            doc.rect(horizontalShift - 5, verticalShift + 6, 5, 5);
                            doc.setTextColor(0);
                            doc.setFont("helvetica");
                            if (!blank && indicator.value.indexOf(indicator.options[i]) > -1) {
                                doc.text('x', horizontalShift - 3.5, verticalShift + 9.5);
                            }
                            doc.setFont("times");
                            doc.text(decodeHTMLEntities(indicator.options[i]), horizontalShift + 1, verticalShift + 10.5);
                            horizontalShift += checkBoxShift;
                        }
                        doc.setFont("helvetica");
                        verticalShift += 16;
                        doc.setFillColor(30, 70, 125);
                        if (verticalShift - verticalStart > shiftHeaderText) {
                            doc.rect(10, verticalStart, 190, verticalShift - verticalStart);
                            doc.rect(10, verticalStart, 40, verticalShift - verticalStart, 'FD');
                        } else {
                            doc.rect(10, verticalStart, 190, shiftHeaderText);
                            doc.rect(10, verticalStart, 40, shiftHeaderText, 'FD');
                            verticalShift += shiftHeaderText;
                        }
                        doc.setTextColor(255);
                        doc.setFillColor(30, 70, 125);
                        doc.setFillColor(255);
                        for (var i = 0; i < headerSplit.length; i++) {
                            doc.text(headerSplit[i], 11, verticalStart + 6 + 8*i);
                        }
                        doc.setTextColor(0);
                        // verticalShift += -4;
                        horizontalShift = 10;
                        break;
                    default:
                        doc.rect(10, verticalShift, 190, 8, 'FD');
                        doc.setFont("helvetica");
                        doc.text(number + ': ' + decodeHTMLEntities(indicator.name) + required, 11, verticalShift + 6);
                        verticalShift += 4;
                        break;
                }
            }
            if (indicator.child !== undefined && indicator.child !== null) {
                subCount = 0;
                $.each(indicator.child, function () {
                    subCount += 1;
                    makeEntry(this, number, depth + 1, Object.keys(indicator.child).length, index);
                });
                subCount = storedSubCount;
            }
        }

        $.each(data, function (i) {
            makeEntry(this, null, 0, 0, i + 1);
            verticalShift += -4;
            subShift = true;
            if (this.child !== undefined && this.child !== null) {
                makeCount = 0;
                subNewRow();
            }
        });

        verticalShift += 16;
        doc.text('* = required field', 200, verticalShift, null, null, 'right');

        if (typeof (requestInfo['signatures']) !== "undefined" && requestInfo['signatures'].length > 0) {
            doc.text("Signatures:", 10, verticalShift);
            verticalShift += 14;
            $.each(requestInfo['signatures'], function () {
                if (verticalShift > height - 15) {
                    pageFooter(false);
                    doc.addPage();
                    doc.text("Signatures continued:", 10, 15);
                    verticalShift = 30;
                }

                if (typeof (this['signed']) !== "undefined") {
                    doc.setFontStyle("italic");
                    doc.setFontType("times");
                    var signedDate = new Date(Number(this['signed']['timestamp']) * 1000).toJSON().slice(0, 10).replace(/-/g, '/');
                    doc.text(this['signed']['userID'] + " on " + signedDate, 10, verticalShift - 5);
                    doc.setFontType("helvetica");
                    doc.setFontStyle("normal");
                }
                doc.line(10, verticalShift - 4, 90, verticalShift - 4);
                doc.text(this['stepTitle'], 10, verticalShift);
                verticalShift += 14;
            });
        }

        pageFooter(true);

        if (blank) {
            if (requestInfo['workflows'].length > 1) {
                doc.save('MultipleForms.pdf');
            } else {
                doc.save(requestInfo['workflows'][0][0]['categoryName'] + '.pdf');
            }
        } else {
            doc.save(requestInfo['title'] + '.pdf');
        }
    }

    var indicatorCount = 0;
    var index = 0;
    var indicators = new Object();
    var blankIndicators = 0;
    function checkBlankChild(indicator) {
        var children = Object.keys(indicator);

        for (var i = 0; i < children.length; i++) {
            var child = indicator[children[i]];
            if (child.value.length === 0) {
                blankIndicators++;
            }

            // process the children of the children...
            if (typeof (child.child) !== "undefined" && child.child != null) {
                checkBlankChild(child.child);
            }
        }
    }

    function getIndicatorData(indicator) {
        $.ajax({
            method: 'GET',
            url: './api/form/' + recordID + '/rawIndicator/' + indicator.indicatorID + '/' + indicator.series,
            dataType: 'json',
            cache: false
        }).done(function (res) {
            if ("parentID" in res[Object.keys(indicators)[index]] && res[Object.keys(indicators)[index]].parentID === null) {
                indicatorData.push(res[Object.keys(indicators)[index]]);
                if (res[Object.keys(indicators)[index]].value.length === 0) {
                    blankIndicators++;
                }
                if (typeof (res[Object.keys(indicators)[index]].child) !== "undefined" && res[Object.keys(indicators)[index]].child !== null) {
                    checkBlankChild(res[Object.keys(indicators)[index]].child);
                }
            }
            index++;
            if (index === indicatorCount) {
                blank = blankIndicators === indicatorCount;
                var submitted = Number(requestInfo['submitted']) > 0;
                var actionCompleted = typeof (requestInfo['lastAction']) !== "undefined";

                if (!blank || submitted) {
                    doc.text(requestInfo['title'], 35, verticalShift);
                    doc.text($('span#headerTab').text(), 200, verticalShift, null, null, 'right');
                    verticalShift += 7;
                    doc.text('Initiated by ' + requestInfo['name'], 200, 24, null, null, 'right');
                    doc.setTextColor(80, 80, 80);
                    doc.setFontStyle("italic");
                    $.each(requestInfo['workflows'], function () {
                        doc.text(this[0]['categoryName'], 35, verticalShift);
                        verticalShift += 7
                    });
                    doc.text($('#headerLabel').text(), 35, verticalShift);
                    doc.setTextColor(0, 0, 0);
                    doc.setFontType('normal');
                    if (!submitted) {
                        doc.text("Not submitted", 200, verticalShift, null, null, 'right');
                    } else {
                        var submitTime = new Date(Number(requestInfo['submitted']) * 1000).toJSON().slice(0, 10).replace(/-/g, '/');
                        doc.text("Submitted " + submitTime, 200, verticalShift, null, null, 'right');
                        if (actionCompleted) {
                            var actionTime = new Date(Number(requestInfo['lastAction']['time']) * 1000).toJSON().slice(0, 10).replace(/-/g, '/');
                            verticalShift += 7;
                            doc.text(requestInfo['lastAction']['description'] + ': ' + requestInfo['lastAction']['action'] + ' by ' + requestInfo['lastAction']['userID'] + ' ' + actionTime, 200, verticalShift, null, null, 'right');
                        }
                    }
                    doc.addImage(getBase64Image($('img[alt="QR code"]')[0]), 'PNG', 8.5, 8, 25, 25);
                } else {
                    doc.setFontSize(8);
                    doc.text("Name:", 150, verticalShift);
                    doc.line(160, verticalShift, 200, verticalShift);
                    doc.text("Date:", 152, verticalShift + 7);
                    doc.line(160, verticalShift + 7, 200, verticalShift + 7);
                    doc.setFontSize(12);
                    $.each(requestInfo['workflows'], function () {
                        doc.text(this[0]['categoryName'], 35, verticalShift);
                        verticalShift += 7
                    });
                    doc.setTextColor(80, 80, 80);
                    doc.setFontStyle("italic");
                    doc.text($('#headerLabel').text(), 35, verticalShift);
                    doc.setTextColor(0, 0, 0);
                    doc.setFontType('normal');
                    doc.addImage(getBase64Image(homeQR), 'PNG', 8.5, 8, 25, 25);
                }
                makePdf(indicatorData);
            } else {
                getIndicatorData(indicators[Object.keys(indicators)[index]][1]);
            }
        }).fail(function (err) {
            console.log(err);
        });
    }

    function getLastAction() {
        var fetchURL = './api/formWorkflow/' + recordID + '/lastAction';

        $.ajax({
            method: 'GET',
            url: fetchURL,
            dataType: "json",
            cache: false
        })
            .done(
                function (res) {
                    if (res !== null && res['actionType'] !== null) {
                        requestInfo['lastAction'] = {
                            'action': res['actionTextPasttense'],
                            'time': res['time'],
                            'description': res['description'],
                            'userID': res['userID']
                        };
                    }
                    getIndicatorData(indicators[Object.keys(indicators)[index]][1]);
                }
            )
            .fail(
                function (err) {
                    alert('Unable to get approval details.');
                    console.log(err);
                    getIndicatorData(indicators[Object.keys(indicators)[index]][1]);
                }
            );
    }

    function getWorkflowState() {
        if (requestInfo['submitted'] > 0) {
            var fetchURL = './api/formWorkflow/' + recordID + '/currentStep';

            $.ajax({
                method: 'GET',
                url: fetchURL,
                dataType: "json",
                cache: false
            })
                .done(
                    function (res) {
                        if (res === null) {
                            requestInfo['completed'] = true;
                        }
                        getLastAction();
                    }
                )
                .fail(
                    function (err) {
                        alert('Unable to get workflow details.');
                        console.log(err);
                        getLastAction();
                    }
                );
        } else {
            getIndicatorData(indicators[Object.keys(indicators)[index]][1]);
        }
    }

    function getSigned() {
        var fetchURL = './api/signature/' + recordID;

        $.ajax({
            method: 'GET',
            url: fetchURL,
            dataType: "json",
            cache: false
        })
            .done(
                function (res) {
                    $.each(requestInfo['signatures'], function (i) {
                        $.each(res, function () {
                            if (this.stepID === requestInfo['signatures'][i]['stepID']) {
                                requestInfo['signatures'][i]['signed'] = {
                                    'timestamp': this.timestamp,
                                    'userID': this.userID
                                };
                            }
                        });
                    });
                    getWorkflowState();
                }
            )
            .fail(
                function (err) {
                    alert('Unable to get form details.');
                    console.log(err);
                }
            );
    }

    function getSignatures(iteration) {
        var processed = iteration;
        if (processed === requestInfo['workflows'].length) {
            getSigned();
        } else {
            var test = requestInfo['workflows'][iteration][0]['workflowID'];
            var fetchURL = './api/workflow/' + test;

            $.ajax({
                method: 'GET',
                url: fetchURL,
                dataType: "json",
                cache: false
            })
                .done(
                    function (res) {
                        $.each(res, function () {
                            if (typeof (this['requiresDigitalSignature']) !== "undefined" && this['requiresDigitalSignature'] === "1") {
                                requestInfo['signatures'].push({
                                    'stepID': this.stepID,
                                    'stepTitle': this.stepTitle
                                });
                            }
                        });
                        processed++;
                        getSignatures(processed);
                    }
                )
                .fail(
                    function (err) {
                        alert('Unable to get form details.');
                        console.log(err);
                    }
                );
        }
    }

    function getWorkflowID(categoryIDs, iteration) {
        var processed = iteration;
        if (processed === categoryIDs.length) {
            requestInfo['signatures'] = [];
            getSignatures(0);
        } else {
            var fetchURL = './api/form/_' + categoryIDs[processed] + '/workflow';

            $.ajax({
                method: 'GET',
                url: fetchURL,
                dataType: "json",
                cache: false
            })
                .done(
                    function (res) {
                        processed++;
                        requestInfo['workflows'].push(res);
                        getWorkflowID(categoryIDs, processed);
                    }
                )
                .fail(
                    function (err) {
                        alert('Unable to get form details.');
                        console.log(err);
                    }
                );
        }
    }

    function getFormInfo() {
        var fetchURL = './api/form/' + recordID + '/recordinfo';

        $.ajax({
            method: 'GET',
            url: fetchURL,
            dataType: "json",
            cache: false
        })
            .done(
                function (res) {
                    requestInfo['title'] = res['title'];
                    requestInfo['name'] = res['name'];
                    requestInfo['date'] = res['date'];
                    requestInfo['submitted'] = res['submitted'];
                    requestInfo['categories'] = Object.keys(res['categories']);
                    requestInfo['workflows'] = [];
                    getWorkflowID(requestInfo['categories'], 0);
                }
            )
            .fail(
                function (err) {
                    alert('Unable to get form details.');
                    console.log(err);
                }
            );
    }

    $.ajax({
        method: 'GET',
        url: './api/form/' + recordID + '/data',
        dataType: 'json',
        cache: false
    }).done(function(res) {
        indicatorCount = Object.keys(res).length;
        indicators = res;
        getFormInfo();
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
