<div class="section group">
    <div class="col span_1_of_5" id="container_left">
        <div id="navtree" style="border: 1px solid black"></div>
    </div>
    <div class="col span_3_of_5">
        <div style="background-color: white; border: 1px solid black; box-shadow: 0 2px 4px #8e8e8e">
            <div id="progressArea" style="height: 34px; background-color: #feffd2; padding: 4px; border-bottom: 1px solid black">
                <div id="progressControl" style="float: left">Form completion progress: <div tabIndex="0" id="progressBar" title="form progress bar" style="height: 14px; margin: 2px; border: 1px solid black; text-align: center"><div style="width: 300px; line-height: 120%; float: left; font-size: 12px" id="progressLabel"></div></div><div style="line-height: 30%"><!-- ie7 workaround --></div>
                </div>
                <div style="float: right"><button id="nextQuestion" type="button" class="buttonNorm nextQuestion" disabled><img src="dynicons/?img=go-next.svg&amp;w=22" alt="" /> Next Question</button></div>
                <br style="clear: both" />
            </div>
            <div>
                <img src="images/indicator.gif" id="loadIndicator" style="visibility: hidden; float: right" alt="" />
                <form id="record" enctype="multipart/form-data" action="javascript:void(0);">
                    <div>
                        <div id="xhr" style="padding: 16px"></div>
                    </div>
                    <input type="submit" value="Submit" aria-disabled="true" aria-label="Previous" hidden>
                </form>
            </div>
            <div id="progressArea2" style="height: 34px; background-color: #feffd2; padding: 4px; border-top: 1px solid black">
                <div style="float: left"><button id="prevQuestion" type="button" class="buttonNorm prevQuestion"><img src="dynicons/?img=go-previous.svg&amp;w=22" alt="" aria-label="Previous"/> Previous Question</button></div>
                <div style="float: right"><button id="nextQuestion2" type="button" class="buttonNorm nextQuestion" disabled><img src="dynicons/?img=go-next.svg&amp;w=22" alt="" aria-label="Next"/> Next Question</button></div>
            </div>
        </div>
        <br />
        <div id="container_center"></div>
    </div>
    <div class="col span_1_of_5" style="float: left">
        <div id="tools" class="tools"><h1 style="font-size: 12px; text-align: center; margin: 0; padding: 2px">Tools</h1>
            <button type="button" id="showSinglePage" onclick="window.location='?a=printview&amp;recordID=<!--{$recordID}-->'" title="View full form"><img src="dynicons/?img=edit-find-replace.svg&amp;w=32" alt=""  /> Show single page</button>
            <br /><br />
            <button class="tools" onclick="cancelRequest()"><img src="dynicons/?img=process-stop.svg&amp;w=16" alt="" title="Cancel Request" style="vertical-align: middle"/> Cancel Request</button>
        </div>
    </div>
</div>


<!-- DIALOG BOXES -->
<div id="formContainer"></div>
<div id="xhrDialog" style="display: none"></div>
<div id="button_save" style="display: none"></div>
<div id="button_cancelchange" style="display: none"></div>
<!--{include file="site_elements/generic_confirm_xhrDialog.tpl"}-->

<script type="text/javascript">
/* <![CDATA[ */

var currIndicatorID = 0;
var currSeries = 0;
var CSRFToken = '<!--{$CSRFToken}-->';

$('#showSinglePage').keypress(function(event) {
    if(event.keyCode === 32) {
        $('#showSinglePageLink')[0].click();
        $('#showSinglePageLink').trigger('click');
    }
});

$('#showSinglePage').on('focusin', function(event) {
    $('#showSinglePage').css('background', '#2372b0');
    $('#showSinglePage').css('color', 'white');
});

$('#showSinglePage').on('focusout', function(event) {
    $('#showSinglePage').css('background', '#e8f2ff');
    $('#showSinglePage').css('color', 'black');
});

function getForm(indicatorID, series) {
    $('.question').removeClass('buttonNormSelected');
    $('#q' + currFormPosition).addClass('buttonNormSelected');

    form.getForm(indicatorID, series);
}

function getNext() {
    currFormPosition++;
    if(currFormPosition < formStructure.length) {
        getForm(formStructure[currFormPosition].indicatorID, formStructure[currFormPosition].series);
    }
    else {
    	var iframeURL = '';
    	if(<!--{$isIframe}-->) {
    		iframeURL = '&iframe=1';
    	}
        window.location.href="index.php?a=printview&recordID=<!--{$recordID}-->" + iframeURL;
    }

    return true;
}

function getPrev() {
    currFormPosition--;
    if(currFormPosition < 0) {
        currFormPosition = 0;
    }
    getForm(formStructure[currFormPosition].indicatorID, formStructure[currFormPosition].series);

    return true;
}

function treeClick(indicatorID, series) {
    form.setPostModifyCallback(function() {
        getForm(indicatorID, series);
        updateProgress();
    });
    form.dialog().clickSave();
}
function onKeyPressClick(event){
    if(event?.keyCode === 13 || event?.keyCode === 32) {
        $(event.target).trigger('click');
    }
}

function updateProgress(focusNext=false) {
    $.ajax({
        type: 'GET',
        url: "./api/form/<!--{$recordID}-->/progress",
        dataType: 'json',
        success: function(response) {
            if(response < 100) {
                $('#progressBar').progressbar('option', 'value', response);
                $('#progressLabel').text(response + '%');
            }
            else {
                savechange = '<div tabindex="0" class="buttonNorm" onkeydown="if(event.keyCode === 13){ manualSaveChange(); }" onclick="manualSaveChange();"><div id="save_indicator"><img src="dynicons/?img=media-floppy.svg&amp;w=22" alt="" style="vertical-align: middle" /> Save Change</div></button>';
                $('#progressControl').html(savechange);
            }
            window.scrollTo(0,0);
            if(focusNext===true){
                $('#nextQuestion').focus();
            }
        },
        error: function(err) {
            console.log('an error occurred during form progress checking', err);
        },
        error: function(e) {
            console.log(e);
        },
        cache: false
    });
}

function cancelRequest() {
    dialog_confirm.setContent('<img src="dynicons/?img=process-stop.svg&amp;w=48" alt="" style="float: left; padding-right: 24px" /> Are you sure you want to cancel this request?');

    dialog_confirm.setSaveHandler(function() {
        $.ajax({
            type: 'POST',
            url: './api/form/<!--{$recordID}-->/cancel',
            data: {CSRFToken: '<!--{$CSRFToken}-->'},
            success: function(response) {
                if(response > 0) {
                    window.location.href="index.php?a=cancelled_request&cancelled=<!--{$recordID}-->";
                }
            },
            cache: false
        });
    });
    dialog_confirm.show();
}

function manualSaveChange()
{
    $("#save_indicator").html('<img src="images/indicator.gif" alt="" /> Saving...');
    setTimeout("$('#save_indicator').html('<img src=\"dynicons/?img=media-floppy.svg&amp;w=22\" alt=\"save\" style=\"vertical-align: middle\"/> Save Change')", 1000);
    form.setPostModifyCallback(function() {
        getForm(formStructure[currFormPosition].indicatorID, formStructure[currFormPosition].series);
    });
    form.dialog().clickSave();
}

//attempt to force a consistent width for the sidebar if there is enough desktop resolution
var lastScreenSize = null;
function sideBar() {
  if(lastScreenSize != window.innerWidth) {
      lastScreenSize = window.innerWidth;

      var tempNavtree = '';
      if($('#container_center').html() != '') {
    	  tempNavtree = $('#container_center').html();
      }
      if($('#container_left').html() != '') {
    	  tempNavtree = $('#container_left').html();
      }
      if(lastScreenSize <= 768) {
    	  $('#container_left').html('');
    	  $('#container_center').html(tempNavtree);
      }
      else {
          $('#container_center').html('');
          $('#container_left').html(tempNavtree);
      }
  }
}

var form;
var formValidator = {};
var formStructure = Array();
var currFormPosition = 0;
$(function() {
    $('#progressBar').progressbar({max: 100});

    form = new LeafForm('formContainer');
    form.initCustom('xhrDialog', 'xhr', 'loadIndicator', 'button_save', 'button_cancelchange');
    form.setRecordID(<!--{$recordID}-->);
    dialog_confirm = new dialogController('confirm_xhrDialog', 'confirm_xhr', 'confirm_loadIndicator', 'confirm_button_save', 'confirm_button_cancelchange');

    updateProgress();

    // load form structure
    $.ajax({
        type: 'GET',
        url: './api/form/<!--{$recordID}-->',
        success: function(res) {
            for(var i in res.items) {
                for(var j in res.items[i].children) {
                    var tmp = {};
                    tmp.category = res.items[i].name;
                    tmp.desc = res.items[i].children[j].desc;
                    tmp.indicatorID = res.items[i].children[j].indicatorID;
                    tmp.series = res.items[i].children[j].series;
                    formStructure.push(tmp);
                }
            }

            var buffer = '';
            var counter = 1;
            for(var i in formStructure) {
                var description = '';
                if(formStructure[i].desc.length > 25) {
                    description = formStructure[i].desc.substr(0, 25) + '...';
                }
                else {
                    description = formStructure[i].desc;
                }
                buffer += '<div tabindex="0" id="q'+ i +'" class="buttonNorm question" style="border: 0px" onclick="currFormPosition='+i+';treeClick('+ formStructure[i].indicatorID +', '+ formStructure[i].series +');" onkeydown="onKeyPressClick(event)">' + counter + '. ' + description + '</div>';
                counter++;
            }
            $('#navtree').html(buffer);

            getForm(formStructure[0].indicatorID, formStructure[0].series);
        },
        error: function(e) {
            console.log(e);
        }
    });

    $('.nextQuestion').on('click', function() {
        form.dialog().indicateBusy();
        form.setPostModifyCallback(function() {
            getNext();
            updateProgress(true);
        });
        form.dialog().clickSave();
    });
    document.querySelectorAll('.nextQuestion').forEach(button => {
        button.removeAttribute('disabled');
    });

    $('.prevQuestion').on('click', function() {
        form.dialog().indicateBusy();
        form.setPostModifyCallback(function() {
            getPrev();
            updateProgress(true);
        });
        form.dialog().clickSave();
    });

    sideBar();
    setInterval("sideBar()", 500);
});

/* ]]> */
</script>
