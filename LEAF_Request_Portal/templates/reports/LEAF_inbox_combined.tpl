<script src="../libs/js/sha1.js"></script>
<script>
var CSRFToken = '<!--{$CSRFToken}-->';
    
var sites = [
    {
        url: './',
        name: 'Demo 1 Site',
        backgroundColor: '#112e51',
        fontColor: 'white',
        icon: '../libs/dynicons/?img=internet-web-browser.svg&w=76'
    },
    {
        url: '../../LEAF_demo/LEAF_Request_Portal/',
        name: 'Demo 2 Site',
        backgroundColor: '#04B404',
        fontColor: 'white',
        icon: '../libs/dynicons/?img=package-x-generic.svg&w=76'
    },
];
    
function renderInbox() {
    for(var i in sites) {
        for(var j in dataInboxes[sites[i].url]) {
            buildDepInbox(dataInboxes[sites[i].url], j, sites[i]);
        }
    }

    $('#loading').slideUp();
    $('#inbox').fadeIn();
}

function buildDepInbox(res, depID, site) {
    var hash = Sha1.hash(site.url);
    var dependencyName = res[depID].dependencyDesc;
    if(String(depID).substr(0,2) == '-1') {
        dependencyName = res[depID].approverName;
    }

    var icon = site.icon == '' ? '' : '<img src="'+ site.icon +'" alt="icon for '+ site.name +'" style="vertical-align: middle" />';
    if(document.getElementById('siteContainer'+ hash) == null) {
        $('#inbox').append('<div id="siteContainer'+ hash +'" style="border-left: 4px solid '+ site.backgroundColor +'; margin: auto; width: 75%">'
                           + '<div style="font-weight: bold; font-size: 200%; line-height: 240%; background-color: '+ site.backgroundColor +'; color: '+ site.fontColor +'; ">' + icon + ' ' + site.name + '</div>'
                           + '</div>');
    }

    $('#siteContainer'+ hash).append('<div id="depContainer'+ hash +'_' + depID + '" style="border: 1px solid black; background-color: '+ res[depID].dependencyBgColor +'; cursor: pointer; margin: 4px">'
                       + '<div id="depLabel'+ hash +'_'+ depID + '" class="depInbox" style="padding: 8px"><span style="float: right; text-decoration: underline; font-weight: bold">View '+ res[depID].count +' requests</span>'
                       + '<span style="font-size: 120%; font-weight: bold">'+ dependencyName +'</span>'
                       + '</div>'
                       + '<div id="depList'+ hash +'_' + depID + '" style="width: 90%; margin: auto; display: none"></div></div><br />');
    $('#depLabel'+ hash +'_'+ depID).on('click', function() {
        if($('#depList'+ hash +'_'+ depID).css('display') == 'none') {
            $('#depList'+ hash +'_'+ depID).css('display', 'inline');
        }
        else {
            $('#depList'+ hash +'_'+ depID).css('display', 'none');
        }
    });
    
    var formGrid = new LeafFormGrid('depList'+ hash +'_' + depID);
    formGrid.setDataBlob(res);
    formGrid.setHeaders([
        {name: 'Type', indicatorID: 'type', editable: false, callback: function(data, blob) {
            var categoryNames = '';
            if(blob[depID]['records'][data.recordID].categoryNames != undefined) {
                categoryNames = blob[depID]['records'][data.recordID].categoryNames.replace(' | ', ', ');
            }
            else {
                categoryNames = '<span style="color: red">Warning: This request is based on an old or deleted form.</span>';
            }
            $('#'+data.cellContainerID).html(categoryNames);
            $('#'+data.cellContainerID).attr('tabindex', '0');
        }},
        {name: 'Service', indicatorID: 'service', editable: false, callback: function(data, blob) {
            $('#'+data.cellContainerID).html(blob[depID]['records'][data.recordID].service);
            $('#'+data.cellContainerID).attr('tabindex', '0');
        }},
        {name: 'Title', indicatorID: 'title', editable: false, callback: function(data, blob) {
            $('#'+data.cellContainerID).attr('tabindex', '0');
            $('#'+data.cellContainerID).attr('aria-label', blob[depID]['records'][data.recordID].title);
            $('#'+data.cellContainerID).html(blob[depID]['records'][data.recordID].title
                + ' <button id="'+ data.cellContainerID +'_preview" class="buttonNorm">View Request</button>'
                + '<div id="inboxForm'+ hash +'_' + depID + '_' + data.recordID +'" style="background-color: white; display: none; height: 300px; overflow: scroll"></div>');
            $('#'+data.cellContainerID + '_preview').on('click', function() {
                $('#'+data.cellContainerID + '_preview').hide();
                if($('#inboxForm'+ hash +'_'+depID+'_'+data.recordID).html() == '') {
                    $('#inboxForm'+ hash +'_'+depID+'_'+data.recordID).html('Loading...');
                    $('#inboxForm'+ hash +'_'+depID+'_'+data.recordID).slideDown();
                    $.ajax({
                        type: 'GET',
                        url: site.url + 'ajaxIndex.php?a=printview&recordID=' + data.recordID,
                        success: function(res) {
                            $('#inboxForm'+ hash +'_'+depID+'_'+data.recordID).html(res);
                            $('#inboxForm'+ hash +'_'+depID+'_'+data.recordID).slideDown();
                            $('#requestTitle').attr('tabindex', '0');
                            $('#requestInfo').attr('tabindex', '0');
                        ariaSubIndicators(1);
                        }
                    });
                }
            });
        }},
        {name: 'Action', indicatorID: 'action', editable: false, sortable: false, callback: function(data, blob) {
            var depDescription = 'Take Action';
            $('#'+data.cellContainerID).html('<button id="btn_action'+ hash +'_'+depID+'_'+data.recordID + '" class="buttonNorm" style="text-align: center; font-weight: bold; white-space: normal">'+ depDescription +'</button>');
            $('#btn_action'+ hash +'_'+depID+'_'+data.recordID).on('click', function() {
                loadWorkflow(data.recordID, depID, formGrid.getPrefixID(), site.url);
            });
        }}
    ]);

    var tGridData = [];
    for(var i in res[depID].records) {
        tGridData.push(res[depID].records[i]);
    }
    formGrid.setData(tGridData);
    formGrid.sort('recordID', 'desc');
    formGrid.renderBody();
    $('#' + formGrid.getPrefixID() + 'table').css('width', '99%');
    $('#' + formGrid.getPrefixID() + 'header_title').css('width', '60%');
    $('#depContainerIndicator_' + depID).css('display', 'none');
}

var dataInboxes = {};
var sitesLoaded = [];
function loadInboxData(site) {
    site = site == undefined ? '' : site;
    $.ajax({
        type: 'GET',
        url: site + './api/?a=inbox/dependency/_',
        success: function(res) {
            dataInboxes[site] = res;
            sitesLoaded.push(site);
        },
        error: function(err) {
            alert('Error: ' + err.statusText);
        },
        cache: false,
        timeout: 5000
    });
}

function loadWorkflow(recordID, dependencyID, prefixID, rootURL) {
    dialog_message.setTitle('Apply Action to #' + recordID);

    currRecordID = recordID;
    dialog_message.setContent('<div id="workflowcontent"></div><div id="currItem"></div>');
    workflow = new LeafWorkflow('workflowcontent', '<!--{$CSRFToken}-->');
    workflow.setRootURL(rootURL);
    workflow.setActionSuccessCallback(function() {
        dialog_message.hide();
        $('#' + prefixID + 'tbody_tr' + recordID).fadeOut(1500);
    });
    workflow.getWorkflow(recordID);
    dialog_message.show();
}

// Polyfill for IE
if (typeof Object.assign != 'function') {
  // Must be writable: true, enumerable: false, configurable: true
  Object.defineProperty(Object, "assign", {
    value: function assign(target, varArgs) { // .length of function is 2
      'use strict';
      if (target == null) { // TypeError if undefined or null
        throw new TypeError('Cannot convert undefined or null to object');
      }

      var to = Object(target);

      for (var index = 1; index < arguments.length; index++) {
        var nextSource = arguments[index];

        if (nextSource != null) { // Skip over if undefined or null
          for (var nextKey in nextSource) {
            // Avoid bugs when hasOwnProperty is shadowed
            if (Object.prototype.hasOwnProperty.call(nextSource, nextKey)) {
              to[nextKey] = nextSource[nextKey];
            }
          }
        }
      }
      return to;
    },
    writable: true,
    configurable: true
  });
}

var dialog_message;
$(function() {
    dialog_message = new dialogController('genericDialog', 'genericDialogxhr', 'genericDialogloadIndicator', 'genericDialogbutton_save', 'genericDialogbutton_cancelchange');
    sites.forEach(function(site) {
        loadInboxData(site.url);
    });

    var checkLoaded = setInterval(function() {
        if(sitesLoaded.length == sites.length) {
            clearInterval(checkLoaded);

            renderInbox();
            
            $('#btn_expandAll').on('click', function() {
                $('.depInbox').click();
                if($('#btn_expandAll').html() == 'Expand all sections') {
                    $('#btn_expandAll').html('Hide all sections');
                }
                else {
                    $('#btn_expandAll').html('Expand all sections');
                }
            });
        }
    }, 250);

    $('#headerTab').html('My Inbox');
});

</script>

<div id="genericDialog" style="visibility: hidden; display: none">
    <div>
        <div id="genericDialogbutton_cancelchange" style="display: none"></div>
        <div id="genericDialogbutton_save" style="display: none"></div>
        <div id="genericDialogloadIndicator" style="visibility: hidden; z-index: 9000; position: absolute; text-align: center; font-size: 24px; font-weight: bold; background-color: #f2f5f7; padding: 16px; height: 400px; width: 526px"><img src="images/largespinner.gif" alt="loading..." /></div>
        <div id="genericDialogxhr" style="width: 540px; height: 420px; padding: 8px; overflow: auto; font-size: 12px"></div>
    </div>
</div>

<div id="loading" class="card" style="text-align: center; padding: 16px; font-size: 140%"><img src="images/largespinner.gif" alt="loading indicator" style="vertical-align: middle" /> Loading...</div>
<div id="inbox" style="display: none">
    <button id="btn_expandAll" class="buttonNorm" style="float: right">Expand all sections</button>
</div>