<!--{if $deleted > 0}-->
    <div style="font-size: 36px"><img src="dynicons/?img=emblem-unreadable.svg&amp;w=96" alt=""
            style="float: left" /> Notice: This request has been marked as cancelled and will be permanently deleted.<br />
        <span class="buttonNorm" onclick="restoreRequest(<!--{$recordID|strip_tags}-->)"><img
                src="dynicons/?img=document-open.svg&amp;w=32" /> Restore request</span>
    </div><br style="clear: both" />
    <hr />
<!--{/if}-->

<!-- Main content area (anything under the heading) -->
<div id="maincontent">
    <div id="workflow_body">
        <!--{if $submitted == 0}-->
            <div id="progressSidebar" style="border: 1px solid black">
                <div
                    style="background-color: #b74141; padding: 8px; margin: 0px; color: white; text-shadow: black 0.1em 0.1em 0.2em; font-weight: bold; text-align: center; font-size: 120%">
                    Form completion progress</div>
                <div id="progressControl"
                    style="padding: 16px; text-align: center; background-color: #ffaeae; font-weight: bold; font-size: 120%">
                    <div tabIndex="0" id="progressBar" title="Progress Bar"
                        style="height: 30px; border: 1px solid black; text-align: center; width: 80%; margin: auto">
                        <div style="width: 100%; line-height: 200%; float: left; font-size: 14px" id="progressLabel"></div>
                    </div>
                    <div style="line-height: 30%">
                        <!-- ie7 workaround -->
                    </div>
                </div>
            </div>
        <!--{/if}-->
        <span
            style="position: absolute; width: 60%; height: 1px; margin: -1px; padding: 0; overflow: hidden; clip: rect(0,0,0,0); border: 0;"
            aria-atomic="true" aria-live="polite" id="submitStatus" role="status"></span>
        <div id="submitContent" class="noprint"></div>
        <div id="workflowcontent"></div>
    </div>
    <div id="formcontent">
        <div
            style="border: 2px solid black; text-align: center; font-size: 24px; font-weight: bold; background: white; padding: 16px; width: 95%">
            Loading... <img src="images/largespinner.gif" alt="" /></div>
    </div>
</div>

<!-- Toolbar -->
<!-- Toolbar -->
<div id="toolbar" class="toolbar_right toolbar noprint">
    <div id="tools" class="tools">
        <h1>Tools</h1>
        <!--{if $submitted == 0}-->
            <button type="button" class="tools" onclick="window.location='?a=view&amp;recordID=<!--{$recordID|strip_tags}-->'"><img
                    src="dynicons/?img=edit-find-replace.svg&amp;w=32" alt="" title="Guided editor" aria-hidden="true"
                    style="vertical-align: middle" /> Edit this form</button>
            <br />
            <br />
        <!--{/if}-->
        <button type="button" class="tools" onclick="viewHistory()"><img title="View History" aria-hidden="true"
                src="dynicons/?img=appointment.svg&amp;w=32" alt="" style="vertical-align: middle" /> View
            History</button>
        <button type="button" class="tools"
            onclick="window.location='mailto:?subject=FW:%20Request%20%23<!--{$recordID|strip_tags}-->%20-%20<!--{$title|escape:'url'}-->&amp;body=Request%20URL:%20<!--{if $smarty.server.HTTPS == on}-->https<!--{else}-->http<!--{/if}-->://<!--{$smarty.server.SERVER_NAME}--><!--{$smarty.server.REQUEST_URI|escape:'url'}-->%0A%0A'"><img
                src="dynicons/?img=internet-mail.svg&amp;w=32" title="Write Email" alt="" aria-hidden="true" style="vertical-align: middle" /> Write
            Email</button>
        <button type="button" class="tools" id="btn_printForm" title="Print this Form"><img
                src="dynicons/?img=printer.svg&amp;w=32" alt="" style="vertical-align: middle" /> Print
            to PDF <span
                style="font-style: italic; background-color: white; color: #d00; border: 1px solid black; padding: 4px">BETA</span></button>
        <input type='hidden' id='abs_portal_path' value='<!--{$abs_portal_path}-->' />
        <!--{if $bookmarked == ''}-->
            <button type="button" class="tools" onclick="toggleBookmark()" id="tool_bookmarkText" title="Add Bookmark">
                <img src="dynicons/?img=bookmark-new.svg&amp;w=32" alt=""
                    style="vertical-align: middle" /> <span role="status" aria-live="polite">Add Bookmark</span></button>
        <!--{else}-->
            <button type="button" class="tools" onclick="toggleBookmark()" id="tool_bookmarkText" title="Delete Bookmark">
                <img src="dynicons/?img=bookmark-new.svg&amp;w=32" alt=""
                    style="vertical-align: middle" /> <span role="status" aria-live="polite">Delete Bookmark</span></button>
        <!--{/if}-->
        <button  type="button" class="tools" onclick="copyRequest()" title="Copy Request"
            style="vertical-align: middle; background-image: url(dynicons/?img=edit-copy.svg&amp;w=32); background-repeat: no-repeat; background-position: left; text-align: left; text-indent: 35px; height: 38px">
            Copy Request</button>
        <br />
        <br />
        <!--{if $submitted == 0 || $is_admin}-->
        <button type="button" class="tools" id="btn_cancelRequest" title="Cancel Request" onclick="cancelRequest()"><img
                src="dynicons/?img=process-stop.svg&amp;w=16" alt="" style="vertical-align: middle" />
            Cancel Request</button>
        <!--{/if}-->
    </div>


    <div id="comments" style="display: none">
        <h1 id='comment_header'><label for="note">Comments</label></h1>
        <div id="notes">
            <form id='note_form'>
                <input type='hidden' name='userID' value='<!--{$userID|strip_tags}-->' />
                <input type='text' id='note' name='note' placeholder='Enter a note!' />
                <button type="button" id='add_note' class='button' onclick="submitNote(<!--{$recordID|strip_tags}-->)">Post</button>
            </form>
        </div>
        <!--{section name=i loop=$comments}-->
            <div class='comment_block'>
                <span class="comments_time">
                    <!--{$comments[i].time|date_format:' %b %e'|escape}-->
                </span>
                <span class="comments_name">
                    <!--{$comments[i].actionTextPasttense|sanitize}-->
                    <!--{if $comments[i].name != ''}--> by
                    <!--{/if}-->
                    <!--{$comments[i].name}-->
                </span>
                <div class="comments_message">
                    <!--{$comments[i].comment|sanitize}-->
                </div>
            </div>
        <!--{/section}-->
    </div>


    <div id="category_list">
        <h1>Internal Use</h1>
        <button class="IUbutton"
            onclick="scrollPage('formcontent');openContent('ajaxIndex.php?a=printview&amp;recordID=<!--{$recordID|strip_tags}-->'); "
            style="vertical-align: middle; background-image: url(dynicons/?img=text-x-generic.svg&amp;w=16); background-repeat: no-repeat; background-position: left; text-align: left; text-indent: 20px;">
            Main Request</button>
        <!--{section name=i loop=$childforms}-->
            <button class="IUbutton"
                onclick="scrollPage('formcontent');openContent('ajaxIndex.php?a=internalonlyview&amp;recordID=<!--{$recordID|strip_tags}-->&amp;childCategoryID=<!--{$childforms[i].childCategoryID|strip_tags}-->');"
                style="vertical-align: middle; background-image: url(dynicons/?img=text-x-generic.svg&amp;w=16); background-repeat: no-repeat; background-position: left; text-align: center">
                <!--{$childforms[i].childCategoryName|sanitize}-->
            </button>
        <!--{/section}-->
    </div>

    <div id="metaContainer" style="display: none">
        <div id="metaLabel"></div>
        <div id="metaContent"></div>
    </div>

    <!--{if $is_admin}-->
        <div id="adminTools" class="tools">
            <h1>Administrative Tools</h1>
            <!--{if $submitted != 0}-->
                <button class="AdminButton" onclick="admin_changeStep()" title="Change Current Step"
                    style="vertical-align: middle; background-image: url(dynicons/?img=go-jump.svg&w=32); background-repeat: no-repeat; background-position: left; text-align: left; text-indent: 35px; height: 38px">
                    Change Current Step</button>
            <!--{/if}-->
            <button class="AdminButton" onclick="changeService()" title="Change Service"
                style="vertical-align: middle; background-image: url(dynicons/?img=user-home.svg&amp;w=32); background-repeat: no-repeat; background-position: left; text-align: left; text-indent: 35px; height: 38px">
                Change Service</button>
            <button class="AdminButton" onclick="admin_changeForm()" title="Change Forms"
                style="vertical-align: middle; background-image: url(dynicons/?img=system-file-manager.svg&amp;w=32); background-repeat: no-repeat; background-position: left; text-align: left; text-indent: 35px; height: 38px">
                Change Form(s)</button>
            <button class="AdminButton" onclick="admin_changeInitiator()" title="Change Initiator"
                style="vertical-align: middle; background-image: url(dynicons/?img=gnome-stock-person.svg&amp;w=32); background-repeat: no-repeat; background-position: left; text-align: left; text-indent: 35px; height: 38px">
                Change Initiator</button>
        </div>
    <!--{/if}-->
    <div class="toolbar_security">
        <h1 role="heading">Security Permissions</h1>
        <button class="buttonPermission" onclick="viewAccessLogsRead()">
            <!--{if $canRead}-->
                <img src="dynicons/?img=edit-find.svg&amp;w=32" alt="" style="vertical-align: middle" /> You have
                read access
            <!--{else}-->
                <img src="dynicons/?img=emblem-readonly.svg&amp;w=32" alt="" style="vertical-align: middle"
                    tabindex="0" /> You do not have read access
            <!--{/if}-->
        </button>
        <button class="buttonPermission" onclick="viewAccessLogsWrite()">
            <!--{if $canWrite}-->
                <img src="dynicons/?img=accessories-text-editor.svg&amp;w=32" alt=""
                    style="vertical-align: middle" /> You have write access
            <!--{else}-->
                <img src="dynicons/?img=emblem-readonly.svg&amp;w=32" alt=""
                    style="vertical-align: middle" /> You do not have write access
            <!--{/if}-->
        </button>
    </div>
</div>

<!-- DIALOG BOXES -->
<div id="formContainer"></div>
<!--{include file="site_elements/generic_xhrDialog.tpl"}-->
<!--{include file="site_elements/generic_confirm_xhrDialog.tpl"}-->
<!--{include file="site_elements/generic_dialog.tpl"}-->
<!--{include file="site_elements/generic_OkDialog.tpl"}-->

<script type="text/javascript" src="js/functions/toggleZoom.js"></script>
<script type="text/javascript" src="<!--{$app_js_path}-->/LEAF/sensitiveIndicator.js"></script>
<script type="text/javascript">

    $(document).ready(function() {
        let step = parseInt(<!--{$stepID|strip_tags}-->);

        $(window).keydown(function(event) {
            if (event.keyCode == 13 && ($('#note').is(":focus") || $('#add_note').is(":focus"))) {
                event.preventDefault();
                submitNote(<!--{$recordID|strip_tags}-->);
                return false;
        }
    });

    if (step > 0) {
        $('#comments').css({'display': "block"});
        $('#notes').css({'display': "block"});
    } else if (step == 0 && $(".comment_block")[0]) {
        $('#comments').css({'display': "block"});
        $('#notes').css({'display': "none"});
    } else {
        $('#comments').css({'display': "none"});
        $('#notes').css({'display': "none"});
    }
});

let currIndicatorID;
let currSeries;
var recordID = <!--{$recordID|strip_tags}-->;
var serviceID = <!--{$serviceID|strip_tags}-->;
let CSRFToken = '<!--{$CSRFToken}-->';
let formPrintConditions = {};

function doSubmit(recordID) {
    $('#submitControl').empty().html('<img alt="" src="./images/indicator.gif" />Submitting...');
    $.ajax({
        type: 'POST',
        url: "./api/form/" + recordID + "/submit",
        data: {CSRFToken: '<!--{$CSRFToken}-->'},
        success: function(response) {
            if(response?.errors?.length === 0) {
                $('#submitStatus').text('Request submmited');
                $('#submitControl').empty().html('Submitted');
                $('#submitContent').hide('blind', 500);
                $('#comments').css({'display': "block"});
                $('#notes').css({'display': "block"});
                const isAdmin = '<!--{$is_admin}-->';
                if (isAdmin !== "1") {
                    $('#btn_cancelRequest').hide();
                }
                workflow.setExtraParams('masquerade=nonAdmin');
                workflow.getWorkflow(recordID);
            } else {
                let errors = '';
                for(let i in response.errors) {
                    errors += response.errors[i] + '<br />';
                }

                $('#submitControl').empty().html('Error: ' + errors);
                $('#submitStatus').text('Request can not be submmited');
                }
            },
            error: function(res) {
                console.log(res);
            }
        });
    }

    function submitNote(recordID) {
        if ($('#note').val().trim() !== '') {
            var form = $("#note_form").serialize();

            $.ajax({
                type: 'POST',
                url: "./api/note/" + recordID,
                data: {form,
                CSRFToken: '<!--{$CSRFToken}-->'},
                success: function(response) {
                    $("#note").val('');

                    addNote(response);

                    dialog_ok.setTitle('Note Posted Successfully');
                    dialog_ok.setContent(
                        'Your note has been posted. <b style="color: red">Please keep in mind this does not send notifications.</b>'
                    );
                    dialog_ok.setSaveHandler(function() {
                        dialog_ok.clearDialog();
                        dialog_ok.hide();
                    });
                    dialog_ok.show();
                },
                error: function(res) {
                    console.log(res);
                }
            });
        }
    }

    function addNote(response) {
        if (typeof response === 'object' && response !== null) {
            let new_note;

            new_note = '<div class="comment_block"> <span class="comments_time"> ' + response.date +
                '</span> <span class="comments_name">Note Added by ' + response.user_name +
                '</span> <div class="comments_message">' + response.note + '</div> </div>';

            $(new_note).insertAfter("#notes");
        } else {
            console.log('An object was not returned');
        }

    }

    function updateTags() {
        $('#tags').fadeOut(250);
        $.ajax({
            type: 'GET',
            url: "./api/form/<!--{$recordID|strip_tags}-->/tags",
            success: function(res) {
                let buffer = '';
                if (res.length > 0) {
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
        form.dialog().show();
        form.setPostModifyCallback(function() {
            getIndicator(indicatorID, series);
            updateProgress();
            form.dialog().hide();
        });
        form.getForm(indicatorID, series);
    }

    function getIndicatorLog(indicatorID, series) {
        dialog_message.setContent(
            'Modifications made to this field:<table class="agenda" style="background-color: white"><thead><tr><th>Date/Author</th><th>Data</th></tr></thead><tbody id="history_' +
            indicatorID + '"></tbody></table>');
        dialog_message.indicateBusy();
        dialog_message.show();

        $.ajax({
            type: 'GET',
            url: "api/form/<!--{$recordID|strip_tags}-->/" + indicatorID + "/" + series + '/history',
            success: function(res) {
                let numChanges = res.length;
                let prev = '';
                for (let i = 0; i < numChanges; i++) {
                    curr = res.pop();
                    date = new Date(curr.timestamp * 1000);
                    data = curr.data;

                    if (i != 0) {
                        data = diffString(prev, data);
                    }

                    $('#history_' + indicatorID).prepend('<tr><td>' + date.toString() + '<br /><b>' + curr
                        .name + '</b></td><td><span class="printResponse" style="font-size: 16px">' +
                        data + '</span></td></tr>');
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
                if (currentPHindicator.hasClass("printheading_missing")) {
                    currentPHindicator.removeClass("printheading_missing");
                    currentPHindicator.addClass("printheading");
                }
                let xhrIndicator = $("#xhrIndicator_" + indicatorID + "_" + series);
                xhrIndicator.empty().html(response);
                xhrIndicator.fadeOut(250, function() {
                    xhrIndicator.fadeIn(250);
                });
                handlePrintConditionalIndicators(formPrintConditions);
            },
            error: function(res) {
                console.log(res);
            },
            error: function() { console.log('There was an error getting the indicator!'); },
            cache: false
        });
    }

    function updateProgress() {
        $.ajax({
                type: 'GET',
                url: "./api/form/<!--{$recordID|strip_tags}-->/progress",
                dataType: 'json',
                success: function(response) {
                    if (response < 100) {
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
            error: function() { console.log('There was an error getting the progress!'); },
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
                if (response > 0) {
                    window.location.href="index.php?a=printview&recordID=<!--{$recordID|strip_tags}-->";
                }
            },
            error: function() { console.log('There was an error restoring the request!'); }
        });
    }

    <!--{if $bookmarked == ''}-->
        let bookmarkStatus = 0;
    <!--{else}-->
        let bookmarkStatus = 1;
    <!--{/if}-->

    function toggleBookmark() {
        if (bookmarkStatus == 0) {
            addBookmark();
            bookmarkStatus = 1;
            $('#tool_bookmarkText span').empty().html('Delete Bookmark');
        } else {
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
            error: function() { console.log('There was an error adding the bookmark!'); }
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
            error: function() { console.log('There was an error removing the bookmark!'); }
        });
    }

    const valIncludesMultiselOption = (values = [], arrOptions = []) => {
        let result = false;
        let vals = values.map(v => v.replaceAll('\r', '').trim());
        vals.forEach(v => {
            if (arrOptions.includes(v)) {
                result = true;
            }
        });
        return result;
    }

    function handlePrintConditionalIndicators(formPrintConditions = {}) {
        const multiChoiceFormats = ['multiselect', 'checkboxes'];

        for (let c in formPrintConditions) {
            const childFormat = formPrintConditions[c].format; //current format of the controlled question
            const childFormatIsEnabled = childFormat !== 'raw_data';
            const conditions = formPrintConditions[c].conditions;

            let comparison = false;

            for (let i in conditions) {
                /* Validate outcome:
                confirm child, i, has hide/show conditions that need to be processed.
                Log a message to assist with debugging if it is configured with both directives. */
                let outcomes = [];
                if (conditions.some(c => c.selectedOutcome.toLowerCase() === "hide")) outcomes.push("hide");
                if (conditions.some(c => c.selectedOutcome.toLowerCase() === "show")) outcomes.push("show");
                if (outcomes.length > 1) {
                    console.warn("Conflicting display conditions: check setup for", c);
                }
                if (outcomes.length < 1) {
                    continue;
                }
                const outcome = outcomes[0];

                const parentFormat = conditions[i].parentFormat.toLowerCase();
                const elParentInd = document.getElementById('data_' + conditions[i].parentIndID +
                    '_1'); //dropdown, text and radio elements
                const selectedParentOptionsLI = Array.from(document.querySelectorAll(`#xhrIndicator_${conditions[i].parentIndID}_1 > span > ul > li`)); //multiselect and checkboxes li elements

                let arrParVals = [];
                selectedParentOptionsLI.forEach(li => arrParVals.push(li.textContent.trim()));

                const elChildInd = document.getElementById('subIndicator_' + conditions[i].childIndID + '_1');

                if (childFormatIsEnabled && (elParentInd !== null ||
                        selectedParentOptionsLI !== null)) {

                    if (comparison !== true) { //no need to re-assess if it has already become true
                        let val = multiChoiceFormats.includes(parentFormat) ?
                            arrParVals :
                            [
                                (elParentInd?.textContent || '').trim()
                            ];
                        val = val.filter(v => v !== '');

                        let compVal = $('<div/>').html(conditions[i].selectedParentValue).text().trim().split('\n');
                        compVal = compVal.map(v => v.trim());

                        const op = conditions[i].selectedOp;
                        switch (op) {
                            case '==':
                                comparison = valIncludesMultiselOption(val, compVal);
                                break;
                            case '!=':
                                comparison = !valIncludesMultiselOption(val, compVal);
                                break;
                            case 'lt':
                            case 'lte':
                            case 'gt':
                            case 'gte':
                                const arrNumVals = val
                                    .filter(v => !isNaN(v))
                                    .map(v => +v);
                                const arrNumComp = compVal
                                    .filter(v => !isNaN(v))
                                    .map(v => +v);
                                const orEq = op.includes('e');
                                const gtr = op.includes('g');
                                if(arrNumComp.length > 0) {
                                    for (let i = 0; i < arrNumVals.length; i++) {
                                        const currVal = arrNumVals[i];
                                        if(gtr === true) {
                                            //unlikely to be set up with more than one comp val, but checking just in case
                                            comparison = orEq === true ? currVal >= Math.max(...arrNumComp) : currVal > Math.max(...arrNumComp);
                                        } else {
                                            comparison = orEq === true ? currVal <= Math.min(...arrNumComp) : currVal < Math.min(...arrNumComp);
                                        }
                                        if(comparison === true) {
                                            break;
                                        }
                                    }
                                }
                                break;
                            default:
                                console.log(conditions[i].selectedOp);
                                break;
                        }
                    }

                    switch (outcome) {
                        case 'hide':
                            if (elChildInd !== null) {
                                elChildInd.style.display = comparison === true ? 'none' : 'block';
                            }
                            break;
                        case 'show':
                            if (elChildInd !== null) {
                                elChildInd.style.display = comparison === true ? 'block' : 'none';
                            }
                            break;
                        default:
                            console.log(conditions[i].selectedOutcome);
                            break;
                    }
                }
            }
        }
    }

    function openContent(url) {
        $("#formcontent").html(
            '<div style="border: 2px solid black; text-align: center; font-size: 24px; font-weight: bold; background: white; padding: 16px; width: 95%">Loading... <img src="images/largespinner.gif" alt="" /></div>'
        );
        $.ajax({
            type: 'GET',
            url: url,
            dataType: 'text', // IE9 issue
            success: function(res) {
                $('#formcontent').empty().html(res);
                // make box size more predictable
                $('.printmainblock').each(function() {
                    let boxSizer = {};
                    $(this).find('.printsubheading').each(function() {
                        layer = $(this).position().top;
                        if (boxSizer[layer] == undefined) {
                            boxSizer[layer] = $(this).height();
                        }
                        if ($(this).height() > boxSizer[layer]) {
                            boxSizer[layer] = $(this).height();
                        }
                    });
                    $(this).find('.printsubheading').each(function() {
                        layer = $(this).position().top;
                        if (boxSizer[layer] != undefined) {
                            $(this).height(boxSizer[layer]);
                        }
                    });
                });
                handlePrintConditionalIndicators(formPrintConditions);
            },
            error: function(res) {
                $('#formcontent').empty().html(res);
            },
            cache: false,
        });
    }

    function openContentForPrint(){
        $('#formcontent').empty().html('');
        $.ajax({
            type: 'GET',
            url: 'ajaxIndex.php?a=printview&recordID=<!--{$recordID|strip_tags}-->',
            dataType: 'text', // IE9 issue
            success: function(res) {
                $('#formcontent').append(res);
                // make box size more predictable
                $('.printmainblock').each(function() {
                    let boxSizer = {};
                    $(this).find('.printsubheading').each(function() {
                        layer = $(this).position().top;
                        if (boxSizer[layer] == undefined) {
                            boxSizer[layer] = $(this).height();
                        }
                        if ($(this).height() > boxSizer[layer]) {
                            boxSizer[layer] = $(this).height();
                        }
                    });
                    $(this).find('.printsubheading').each(function() {
                        layer = $(this).position().top;
                        if (boxSizer[layer] != undefined) {
                            $(this).height(boxSizer[layer]);
                        }
                    });
                });
                handlePrintConditionalIndicators(formPrintConditions);
            },
            error: function(res) {
                $('#formcontent').empty().html(res);
            },
            cache: false,
            async: false,
        });
      
        <!--{section name=i loop=$childforms}-->
            $.ajax({
                type: 'GET',
                url: 'ajaxIndex.php?a=internalonlyview&recordID=<!--{$recordID|strip_tags}-->&childCategoryID=<!--{$childforms[i].childCategoryID|strip_tags}-->',
                dataType: 'text', // IE9 issue
                success: function(res) {
                    $('#formcontent').append(res);
                    // make box size more predictable
                    $('.printmainblock').each(function() {
                        let boxSizer = {};
                        $(this).find('.printsubheading').each(function() {
                            layer = $(this).position().top;
                            if (boxSizer[layer] == undefined) {
                                boxSizer[layer] = $(this).height();
                            }
                            if ($(this).height() > boxSizer[layer]) {
                                boxSizer[layer] = $(this).height();
                            }
                        });
                        $(this).find('.printsubheading').each(function() {
                            layer = $(this).position().top;
                            if (boxSizer[layer] != undefined) {
                                $(this).height(boxSizer[layer]);
                            }
                        });
                    });
                    handlePrintConditionalIndicators(formPrintConditions);
                },
                error: function(res) {
                    //$('#formcontent').empty().html(res);
                },
                cache: false,
                async: false,
            });
        <!--{/section}-->

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
            error: function() { console.log('There was an error collecting the history!'); },
            cache: false
        });
    }

    function cancelRequest() {
        dialog_confirm.setContent(
            `<div style="margin-left:-0.75rem;">
                <div style="display:flex;align-items:center;gap:0.75rem;">
                    <img src="dynicons/?img=process-stop.svg&amp;w=48" alt="">
                    Are you sure you want to cancel this request?
                </div>
                <br>
                <label for="cancel_comment" style="font-size:14px;">Comments:</label><br>
                <textarea id="cancel_comment" cols=30 rows=3 placeholder="Enter Comment"
                    style="width:100%;resize: vertical;"></textarea>
            </div>`
        );

        dialog_confirm.setSaveHandler(function() {
            let comment = $('#cancel_comment').val();

            $.ajax({
                type: 'POST',
                url: 'api/form/<!--{$recordID|strip_tags|escape}-->/cancel',
                data: {CSRFToken: '<!--{$CSRFToken}-->',
                    comment: comment},
                success: function(response) {
                    if (response == 1) {
                        window.location.href="index.php?a=cancelled_request&cancelled=<!--{$recordID|strip_tags}-->";
                    } else {
                        alert(response);
                    }
                },
                error: function() { console.log('There was an error canceling the request!'); },
                cache: false
            });
        });
        dialog_confirm.show();
        $('#cancel_comment').focus();
    }

    function changeTitle() {
        dialog.setContent('<label for="title">Title:</label><br><input type="text" id="title" style="width: 300px" name="title" value="<!--{$title|escape:'quotes'}-->" /><input type="hidden" id="CSRFToken" name="CSRFToken" value="<!--{$CSRFToken}-->" />');

        dialog.show();
        dialog.setSaveHandler(function() {
            $.ajax({
                type: 'POST',
                url: 'api/form/<!--{$recordID|strip_tags}-->/title',
                data: {title: $('#title').val(),
                CSRFToken: '<!--{$CSRFToken}-->'},
                success: function(res) {
                    if (res != null) {
                        $('#requestTitle').empty().html(res);
                    }
                    dialog.hide();
                },
                error: function() { console.log('There was an error changing the title!'); }
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

        if (indicators !== null && typeof indicators === 'object') {
            Object.values(indicators).forEach(function(indicator) {

                // make sure indicatorID exists
                if (indicator.indicatorID !== undefined) {
                    children.push(indicator.indicatorID);
                }

                // make sure child exists
                if (indicator.child !== undefined) {
                    let subchildren = getChildrenIndicatorIDs(indicator.child);
                    children = children.concat(subchildren);
                }
            });
        }

        return children;
    }

    /**
     * popup for duplicating the current form
     * will allow an end user to choose which sections they would like to copy over
     */
    function copyRequest() {
        $('body').on('click', '.pickAndChooseAll', function(event) {
            $(".pickAndChoose").prop("checked", event.target.checked);
        }).on('click', '.pickAndChoose', function() {
            if ($(".pickAndChoose").length === $(".pickAndChoose:checked").length) {
                $(".pickAndChooseAll").prop("checked", true);
            } else {
                $(".pickAndChooseAll").prop("checked", false);
            }
        });

        dialog.setTitle('Copy Request <!--{$title|escape:'quotes'}-->');
        dialog.show();

        dialog.indicateBusy();
        // options for the service dropdown
        let serviceOptions = '';
        // how is this supposed to work? Old functionality that is no longer used?
        let series = 1;
        // allow the end user to choose what should be copied.
        let pickAndChoose = [];
        // give it all, make it a bit easier
        let pickAndChooseOptions =
            '<label class="checkable leaf_check" style="float: none"> <input class="ischecked leaf_check pickAndChooseAll" checked="checked" type="checkbox"> <span class="leaf_check"> </span>All</label>';

        let createData = {
            CSRFToken: '<!--{$CSRFToken}-->'
        };
        //get information needed for the modal.
        const requestInformation = [
            // get our service list
            $.ajax({
                type: 'GET',
                url: 'api/service',
                CSRFToken: '<!--{$CSRFToken}-->',
                success: function(res) {
                    Object.values(res).forEach(function(resultValue) {
                        let selected = (parseInt(resultValue.serviceID) === parseInt(serviceID)) ?
                            'selected="selected"' : '';
                        serviceOptions += '<option value="' + resultValue.serviceID + '" ' + selected +
                            '>' + resultValue.service + '</option>';
                    });
                },
                error: function() { console.log('Failed to gather services for dropdown!'); }
            }),

            //need the "categories" and attach them to the createData.
            $.ajax({
                type: 'GET',
                url: 'api/form/<!--{$recordID|strip_tags}-->/recordinfo',
                CSRFToken: '<!--{$CSRFToken}-->',
                success: function(res) {
                    // categories attached to the createData, need this to create a new form
                    const categories = Object.values(res.categories);
                    categories.forEach(c => createData['num' + c] = 'num' + c);
                },
                error: function() {
                    console.log('Failed to gather categories before creating new form');
                }
            }),

            $.ajax({
                type: 'GET',
                url: 'api/form/<!--{$recordID|strip_tags}-->/data/tree',
                CSRFToken: '<!--{$CSRFToken}-->',
                success: function(res) {
                    Object.values(res).forEach(function(resultValue) {
                        let children = getChildrenIndicatorIDs(resultValue.child);
                        pickAndChoose.push({
                            'name': resultValue.name,
                            // need to include the parent here as well.
                            'children': children.concat(resultValue.indicatorID)
                        });
                    });
                },
                error: function() { console.log('Failed to gather data to copy as well as make dropdowns'); }
            }),
        ];

        Promise.all(requestInformation).then(res => {
            if (pickAndChoose.length > 0) {
                pickAndChoose.forEach(function(option) {
                    let doc = new DOMParser().parseFromString(option.name, 'text/html');
                    let finalName = doc.body.textContent || "";
                    finalName = XSSHelpers.stripAllTags(finalName);

                    pickAndChooseOptions +=
                        '<label class="checkable leaf_check" style="float: none"> <input checked="checked" class="ischecked leaf_check pickAndChoose" name="pickAndChoose[]" type="checkbox" value="' +
                        JSON.stringify(option.children) + '"> <span class="leaf_check"> </span>' + finalName +
                        '</label>';
                });
            }

            dialog.setContent('' +
                '<div id="copy_request_error" style="display:none;margin:0.5rem 0;padding:0.5rem;background-color:#ffc;line-height:1.5"></div>' +
                '<label for="title">Title:</label><br />'
                + '<input id="title" name="title" type="text" value="<!--{$title|escape:'quotes'}-->" style="width:200px;"/><br /><br />'
                +
                '<div id="serviceWrapper"><label for="service">Service:</label><br />' +
                '<select class="chosen" id="service" name="service">' + serviceOptions + '</select><br /><br /></div>' +
                '<label for="priority">Priority:</label><br />' +
                '<select class="chosen" id="priority" name="priority"><option value="-10">EMERGENCY</option><option value="0" selected="selected">Normal</option></select><br /><br />' +
                '<fieldset><legend>Sections to Copy:</legend>' +
                pickAndChooseOptions +
                '</fieldset><br /><br />'
            );

            dialog.indicateIdle();

            // hide service options if they are not available to choose from.
            if (!(serviceOptions.length > 0)) {
                $('#serviceWrapper').hide();
            }
            $('.chosen').chosen({ disable_search_threshold: 6 });
            dialog.setSaveHandler(function() {

                // we will add on the categories in the first ajax call, this takes in what data the end user updates
                createData = {
                    ...createData,
                    title: $('#title').val(),
                    service: $('#service').val(),
                    priority: $('#priority').val(),
                };
                let updateData = {
                    series: series,
                    CSRFToken: '<!--{$CSRFToken}-->'
                };

                let chosenSections = [];
                let pickAndChooseValues = $("input[name='pickAndChoose[]']:checked")
                    .map(function(el) {
                        return chosenSections.concat(JSON.parse($(this).val()));
                    }).get();

                // create the new record, we will update the existing data once we get a complete.
                $.ajax({
                    type: 'POST',
                    url: './api/form/new',
                    data: createData,
                    success: function(res) {
                        let newRecordID = +res;
                        if (newRecordID > 0) {
                            //If the request was created, res is new request ID. Continue on with getting information to copy over.
                            if (pickAndChooseValues.length > 0) {
                                let fileData = [];
                                $.ajax({
                                    type: 'GET',
                                    url: 'api/form/<!--{$recordID|strip_tags}-->/data',
                                    CSRFToken: '<!--{$CSRFToken}-->',
                                    async: false, // I am not going to nest these to make things easier to follow.
                                    success: function(res) {
                                        Object.values(res).forEach(function(resultValue) {

                                            if (pickAndChooseValues.includes(resultValue[series].indicatorID)) {

                                                // uploaded files will need to have a special case done to them to copy them over to the new record
                                                if ((resultValue[series].format == 'fileupload' ||
                                                        resultValue[series].format == 'image') &&
                                                    Array.isArray(resultValue[series].value)) {
                                                    resultValue[series].value.forEach(function(
                                                        currentFile) {
                                                        let fileDat = {
                                                            fileName: currentFile,
                                                            series: series,
                                                            indicatorID: resultValue[series]
                                                                .indicatorID
                                                        }
                                                        fileData.push(fileDat);
                                                    });
                                                    // also need to pull this out of an array since it would then move this to an object which breaks everything.
                                                    updateData[resultValue[series].indicatorID] =
                                                        resultValue[series].value.join('\r\n');
                                                } else {
                                                    updateData[resultValue[series].indicatorID] =
                                                        resultValue[series].value;
                                                }

                                            }

                                        });
                                    },
                                    error: function() {
                                        console.log('Failed to gather data to copy as well as make dropdowns');
                                    }
                                });

                                $.ajax({
                                    type: 'POST',
                                    url: './api/form/' + newRecordID,
                                    data: updateData,
                                    async: false, // I am not going to nest these to make things easier to follow.
                                    success: function() {
                                        console.log('Questions copied over to new record.');
                                    },
                                    error: function() {
                                        console.log('Failed to copy data to new form!')
                                    }
                                });

                                // copy over files
                                if (fileData.length > 0) {
                                    fileData.forEach(function(theFile) {
                                        $.ajax({
                                            type: 'POST',
                                            url: './api/form/files/copy',
                                            data: {
                                                CSRFToken: '<!--{$CSRFToken}-->',
                                                recordID: <!--{$recordID|strip_tags}-->,
                                                newRecordID: newRecordID,
                                                indicatorID: theFile.indicatorID,
                                                fileName: theFile.fileName,
                                                series: theFile.series
                                            },
                                            async: false, // I am not going to nest these to make things easier to follow.
                                            success: function() {
                                                console.log(
                                                    'Files copied over to new record.'
                                                );
                                            },
                                            error: function() {
                                                console.log(
                                                    'Failed to copy data to new form!'
                                                )
                                            }
                                        });
                                    });
                                }
                            }

                            // then redirect, not sure how to really structure this since we do have a bit of if checking here.
                            window.location = "index.php?a=view&recordID=" + newRecordID;
                            dialog.hide();

                        } else {
                            //could not create new form.  Either an error or form is set to unpublished.
                            let elError = document.getElementById('copy_request_error');
                            if(elError !== null) {
                                elError.style.display = 'block';
                                elError.innerHTML = '<b>Request could not be copied:</b><br>' + res;
                            }
                        }
                    },
                    error: function() { console.log('Failed to create new form!'); }
                });

            });

        }).catch(err => console.log('an error has occurred', err));
    }

    function changeService() {
        dialog.setTitle('Change Service');
        dialog.setContent('<label id="newService_label" for="newService">Select new service: </label><br><div id="changeService"></div>');
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
                for (let i in res) {
                    services += '<option value="' + res[i].groupID + '">' + res[i].groupTitle + '</option>';
                }
                services += '</select>';
                $('#changeService').html(services);
                $('.chosen').chosen({ disable_search_threshold: 6 });
                $(`#newService_chosen input.chosen-search-input`).attr('role', 'combobox');
                $(`#newService_chosen input.chosen-search-input`).attr('aria-labelledby', 'newService_label');
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
                        error: function() { console.log('Failed to gather services!'); }
                    });
                    dialog.hide();
                });
            },
            error: function() { console.log('There was an error changing the service!'); },
            cache: false
        });
    }

    <!--{if $is_admin}-->
        var currentRecordID = <!--{$recordID|strip_tags}-->;

        async function admin_changeStep() {
            dialog.setTitle('Change Step');
            dialog.setContent('<label id="newStep_label" for="newStep">Set to this step:</label> <br />' +
                '<div id="changeStep"></div><br /><br />' +
                'Comments:<br />' +
                '<textarea id="changeStep_comment" type="text" style="width: 90%; padding: 4px" aria-label="Comments"></textarea>' +
                '<br /><br />' +
                '<fieldset>' +
                '<legend>Advanced Options</legend>' +
                '<input id="showAllSteps" type="checkbox" />' +
                '<label for="showAllSteps">Show steps from other workflows</label>' +
                '</fieldset>');
            dialog.show();
            dialog.indicateBusy();

            // Check the current step
            let currentStepData = await $.ajax({
                type: 'GET',
                url: `api/formWorkflow/${currentRecordID}/currentStep`,
                dataType: 'json',
                error: function() {
                    console.log('There was an error getting the current step!');
                },
                cache: false
            });

            // determine active workflows
            let workflows = {};
            for (let i in currentStepData) {
                workflows[currentStepData[i].workflowID] = 1;
            }

            // If no workflows, estimate workflow by only checking the previous action
            if(Object.keys(workflows).length == 0) {
                let lastAction = await $.ajax({
                    type: 'GET',
                    url: `api/formWorkflow/${currentRecordID}/lastAction`,
                    dataType: 'json',
                    error: function() {
                        console.log('There was an error getting the last action!');
                    },
                    cache: false
                });
                if(lastAction != null) {
                    workflows[lastAction.workflowID] = 1; // add workflow to the active workflow list
                }
            }

            // Get list of all steps
            $.ajax({
                type: 'GET',
                url: 'api/workflow/steps',
                dataType: 'json',
                success: function(res) {
                    let steps = '<select id="newStep" class="chosen">';
                    let steps2 = '';
                    let stepCounter = 0;
                    let allStepsData = res;

                    for (let i in allStepsData) {
                        let recordID = allStepsData[i].recordID;

                        if (
                            Object.keys(workflows).length == 0 ||
                            workflows[allStepsData[i].workflowID] != undefined
                        ) {
                            // keep track of steps that match the current workflow
                            steps += `<option value="${allStepsData[i].stepID}">${allStepsData[i].description}: ${allStepsData[i].stepTitle}</option>`;
                            stepCounter++;
                        }
                        // keep track of all steps in a different buffer
                        steps2 += `<option value="${allStepsData[i].stepID}">${allStepsData[i].description} - ${allStepsData[i].stepTitle}</option>`;
                    }

                    if (stepCounter == 0) {
                        steps += steps2;
                    }
                    steps += '</select>';
                    $('#changeStep').html(steps);

                    // This displays all steps from all the workflows when clicked
                    $('#showAllSteps').on('click', function() {
                        let newstep = $('#newStep');
                        if ($('#showAllSteps').is(':checked')) {
                            newstep.html(steps2);
                        } else {
                            newstep.html(steps);
                        }
                        newstep.trigger('chosen:updated');
                    });

                    $('.chosen').chosen({
                        width: '100%',
                        disable_search_threshold: 6
                    });
                    $(`#newStep_chosen input.chosen-search-input`).attr('role', 'combobox');
                    $(`#newStep_chosen input.chosen-search-input`).attr('aria-labelledby', 'newStep_label');
                    dialog.indicateIdle();
                    dialog.setSaveHandler(function() {
                        $.ajax({
                            type: 'POST',
                            url: `api/formWorkflow/${currentRecordID}/step`,
                            data: {
                                stepID: $('#newStep').val(),
                                comment: $('#changeStep_comment').val(),
                                CSRFToken: CSRFToken
                            },
                            success: function() {
                                window.location.href = `index.php?a=printview&recordID=${currentRecordID}`;
                            },
                            error: function() {
                                console.log(
                                    'There was an error saving the workflow step!'
                                );
                            }
                        });
                        dialog.hide();
                    });
                },
                error: function() {
                    console.log('There was an error getting workflow steps!');
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
                url: './api/workflow/categoriesUnabridged',
                dataType: 'json',
                success: function(res) {
                    let categories = '';
                    let adminUnpublishedWarn = '';
                    for (let i in res) {
                        adminUnpublishedWarn = res[i].visible === -1 ? '<span style="color:#c00;">&nbsp;(This form is unpublished)</span>' : '';
                        categories += '<label class="checkable leaf_check" for="category_' + res[i].categoryID +
                            '">';

                        categories +=
                            '<input type="checkbox" class="icheck admin_changeForm leaf_check" id="category_' +
                            res[i].categoryID + '" name="categories[]" value="' + res[i].categoryID + '" />';
                        categories += '<span class="leaf_check"></span>' + res[i].categoryName + adminUnpublishedWarn + '</label>';
                    }
                    $('#changeForm').html(categories);
                    dialog.indicateIdle();
                    dialog.setSaveHandler(function() {
                        let data = {
                            'categories[]': [],
                            CSRFToken: CSRFToken
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
                            let arrCatIDs = res[<!--{$recordID|strip_tags|escape}-->].categoryIDsUnabridged;
                            $('label.checkable input').each(function(idx, input) {
                                const formIsSelected = arrCatIDs.some(id => id === input.value);
                                $('#' + input?.id).prop('checked', formIsSelected);
                            });
                        },
                        error: function() {
                            console.log(
                                'There was an error getting the form via query!');
                        },
                        cache: false
                    });
                },
                error: function() { console.log('There was an error getting the categories!'); },
                cache: false
            });
        }

        function admin_changeInitiator() {
            dialog.setTitle('Change Initiator');
            dialog.setContent(
                'Select employee to be set as this request\'s initiator: <br /><div id="empSel_changeInitiator"></div><input type="hidden" id="changeInitiator" />'
            );
            dialog.show();
            dialog.indicateBusy();

            dialog.setSaveHandler(function() {
                let changeInitiator = $('#changeInitiator');
                if (changeInitiator.val() != '') {
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
                        error: function() { console.log('There was an error saving the initiator!'); }
                    });
                } else {
                    alert('An employee needs to be selected');
                }
            });

            let empSel;

            function init_empSel() {
                empSel = new employeeSelector('empSel_changeInitiator');
                empSel.apiPath = '<!--{$orgchartPath}-->/api/';
                empSel.rootPath = '<!--{$orgchartPath}-->/';

                empSel.setSelectHandler(function() {
                    if (empSel.selectionData[empSel.selection] != undefined) {
                        $('#changeInitiator').val(empSel.selectionData[empSel.selection].userName);
                    }
                });
                empSel.setResultHandler(function() {
                    if (empSel.selectionData[empSel.selection] != undefined) {
                        $('#changeInitiator').val(empSel.selectionData[empSel.selection].userName);
                    }
                });
                empSel.initialize();
                dialog.indicateIdle();
            }

            if (typeof employeeSelector == 'undefined') {
                $('head').append('<link type="text/css" rel="stylesheet" href="<!--{$orgchartPath}-->/css/employeeSelector.css" />');
                $.ajax({
                    type: 'GET',
                    url: "<!--{$orgchartPath}-->/js/employeeSelector.js",
                    dataType: 'script',
                    success: function() {
                        init_empSel();
                    },
                    error: function() { console.log('There was an error getting the employee selector!'); }
                });
            } else {
                init_empSel();
            }

        }
    <!--{/if}-->

    function scrollPage(id) {
        if ($(document).height() < $('#' + id).offset().top + 100) {
            $('html, body').animate({scrollTop: $('#'+id).offset().top}, 500);
        }
    }

    // attempt to force a consistent width for the sidebar if there is enough desktop resolution
    let lastScreenSize = null;

    function sideBar() {
        //    console.log(window.innerWidth);
        if (lastScreenSize != window.innerWidth) {
            lastScreenSize = window.innerWidth;
            let toolbar = $('#toolbar');
            let maincontent = $('#maincontent');
            if (lastScreenSize < 700) {
                toolbar.removeClass("toolbar_right");
                toolbar.addClass("toolbar_inline");
                maincontent.css("width", "98%");
                toolbar.css("width", "98%");
            } else {
                toolbar.removeClass("toolbar_inline");
                toolbar.addClass("toolbar_right");
                // effective width of toolbar becomes around 205px
                mywidth = Math.floor((1 - 250 / lastScreenSize) * 100);
                maincontent.css("width", mywidth + "%");
                toolbar.css("width", 98 - mywidth + "%");
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
            openContentForPrint();
            print.printForm(recordID);
        });
        form.setRecordID(<!--{$recordID|strip_tags|escape}-->);

        workflow = new LeafWorkflow('workflowcontent', '<!--{$CSRFToken}-->');
        <!--{if $submitted > 0}-->
            workflow.getWorkflow(<!--{$recordID|strip_tags|escape}-->);
        <!--{/if}-->

        /* General popup window */
        dialog = new dialogController('xhrDialog', 'xhr', 'loadIndicator', 'button_save',
            'button_cancelchange');
        dialog_message = new dialogController('genericDialog', 'genericDialogxhr', 'genericDialogloadIndicator',
            'genericDialogbutton_save', 'genericDialogbutton_cancelchange');
        dialog_ok = new dialogController('ok_xhrDialog', 'ok_xhr', 'ok_loadIndicator', 'confirm_button_ok',
            'confirm_button_cancelchange');
        dialog_confirm = new dialogController('confirm_xhrDialog', 'confirm_xhr', 'confirm_loadIndicator',
            'confirm_button_save', 'confirm_button_cancelchange');

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
        window.addEventListener('scroll', function() {
            if (elParentForm && elFormMenu) {
                let parent_Y = elParentForm.getBoundingClientRect().y;
                elFormMenu.style.top = parent_Y > 0 ? 0 : (-1 * parent_Y) + "px";
            }
        });
    });
</script>