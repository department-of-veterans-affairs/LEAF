<script src="../libs/js/sha1.js"></script>
<script>
    let CSRFToken = '<!--{$CSRFToken}-->';

    /**
     * This is the section of the script where you add the LEAF's you want added to this combined inbox.
     * - url: Define the full url with backslash at end.
     * - name: Title of the LEAF in the combined inbox.
     * - fontColor: Color of title font.
     * - icon: Icon you would like next to the name of the inbox.
     *      Icon Repository: https://leaf.va.gov/libs/dynicons/gallery.php
     * - nonadmin: Set to true if you want Admins to see only their own info and not all requests
     * Find the Icon you want to use and copy its .svg name and simply put it into the icon: field below.
     * To add multiple sites just copy template from the brackets and comma like Demo 2 { },
     */
    let sites = [
        {
            url: './',
            name: 'Demo 1',
            backgroundColor: 'Green',
            fontColor: 'white',
            icon: 'internet-web-browser.svg',
            nonadmin: false
        },
        {
            url: './another_portal',
            name: 'Demo 2',
            backgroundColor: 'Blue',
            fontColor: 'white',
            icon: 'applications-system.svg',
            nonadmin: false
        }
    ];

    // Do Not Edit!! (Only Edit Sites Above)

    // Initiate script and set loading wheel
    function renderInbox() {
        for (let i in sites) {
            for (let j in dataInboxes[sites[i].url]) {
                buildDepInbox(dataInboxes[sites[i].url], j, sites[i]);
            }
        }
        $('#loading').slideUp();
        $('#inboxContainer').fadeIn();
    }

    // Get site icons and name
    function getIcon(icon, name) {
        if (icon != '') {
            if (icon.indexOf('/') != -1) {
                icon = '<img src="' + icon + '" alt="icon for ' + name + '" style="vertical-align: middle" />';
            } else {
                icon = '<img src="../libs/dynicons/?img=' + icon + '&w=76" alt="icon for ' + name + '" style="vertical-align: middle" />';
            }
        }
        return icon;
    }

    // Build forms and grids for the inbox's requests and import to html tags
    function buildDepInbox(res, depID, site) {
        let hash = Sha1.hash(site.url);
        let dependencyName = res[depID].dependencyDesc;
        if (String(depID).substr(0, 2) == '-1') {
            dependencyName = res[depID].approverName != null ? res[depID].approverName : 'Person designated by requestor';
        }
        let icon = getIcon(site.icon, site.name);
        if (document.getElementById('siteContainer' + hash) == null) {
            $('#indexSites').append('<li style="font-size: 120%; line-height: 150%"><a href="#' + hash + '">' + site.name + '</a></li>');
            $('#inbox').append('<div id="siteContainer' + hash + '" style="border-left: 4px solid ' + site.backgroundColor + '; border-right: 4px solid ' + site.backgroundColor + '; border-bottom: 4px solid ' + site.backgroundColor + '; margin: 0px auto 8px">'
                + '<a name="' + hash + '" />'
                + '<div style="font-weight: bold; font-size: 200%; line-height: 240%; background-color: ' + site.backgroundColor + '; color: ' + site.fontColor + '; ">' + icon + ' ' + site.name + '</div>'
                + '</div>');
        }
        $('#siteContainer' + hash).append('<div id="depContainer' + hash + '_' + depID + '" style="border: 1px solid black; background-color: ' + res[depID].dependencyBgColor + '; cursor: pointer; margin: 4px">'
            + '<div id="depLabel' + hash + '_' + depID + '" class="depInbox" style="padding: 8px"><span style="float: right; text-decoration: underline; font-weight: bold">View ' + res[depID].count + ' requests</span>'
            + '<span style="font-size: 120%; font-weight: bold">' + dependencyName + '</span>'
            + '</div>'
            + '<div id="depList' + hash + '_' + depID + '" style="width: 90%; margin: auto; display: none"></div></div><br />');
        $('#depLabel' + hash + '_' + depID).on('click', function () {
            if ($('#depList' + hash + '_' + depID).css('display') == 'none') {
                $('#depList' + hash + '_' + depID).css('display', 'inline');
            } else {
                $('#depList' + hash + '_' + depID).css('display', 'none');
            }
        });
        let formGrid = new LeafFormGrid('depList' + hash + '_' + depID);
        formGrid.disableVirtualHeader(); // TODO: figure out why headers aren't sized correctly
        formGrid.setDataBlob(res);
        formGrid.hideIndex();
        formGrid.setHeaders([
            {name: 'UID', indicatorID: 'uid', editable: false, callback: function(data, blob) {
            $('#'+data.cellContainerID).html('<a href="'+ site.url +'?a=printview&recordID=' + data.recordID + '">'+ data.recordID +'</a>');
            }}
            ,
            {name: 'Type', indicatorID: 'type', editable: false, callback: function(data, blob) {
            let categoryNames = '';
            if(blob[depID]['records'][data.recordID].categoryNames != undefined) {
                categoryNames = blob[depID]['records'][data.recordID].categoryNames.replace(' | ', ', ');
            }
            else {
                categoryNames = '<span style="color: #ff0000">Warning: This request is based on an old or deleted form.</span>';
            }
            $('#' + data.cellContainerID).html(categoryNames);
            $('#' + data.cellContainerID).attr('tabindex', '0');
            }
            },
            {name: 'Service', indicatorID: 'service', editable: false, callback: function(data, blob) {
            $('#'+data.cellContainerID).html(blob[depID]['records'][data.recordID].service);
            $('#'+data.cellContainerID).attr('tabindex', '0');
            }},
            {name: 'Title', indicatorID: 'title', editable: false, callback: function(data, blob) {
            $('#'+data.cellContainerID).attr('tabindex', '0');
            $('#'+data.cellContainerID).attr('aria-label', blob[depID]['records'][data.recordID].title);
            $('#'+data.cellContainerID).html('<a href="index.php?a=printview&recordID='+ data.recordID + '" target="_blank">'
                + blob[depID]['records'][data.recordID].title + '</a>'
                + ' <button id="'+ data.cellContainerID +'_preview" class="buttonNorm">Quick View</button>'
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
                    }
                })
            }
            })
            }
            },
            {name: 'Status', indicatorID: 'currentStatus', editable: false, callback: function(data, blob) {
                let listRecord = blob[depID]['records'][data.recordID];
                let cellContainer = $('#'+data.cellContainerID);
                let waitText = listRecord.blockingStepID == 0 ? 'Pending ' : 'Waiting for ';
                let status = '';
                if(listRecord.stepID == null && listRecord.submitted == '0') {
                    status = '<span style="color: #e00000">Not Submitted</span>';
                }
                else if(listRecord.stepID == null) {
                    let lastStatus = listRecord.lastStatus;
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
            let depDescription = 'Take Action';
            $('#'+data.cellContainerID).html('<button id="btn_action'+ hash +'_'+depID+'_'+data.recordID + '" class="buttonNorm" style="text-align: center; font-weight: bold; white-space: normal">'+ depDescription +'</button>');
            $('#btn_action'+ hash +'_'+depID+'_'+data.recordID).on('click', function() {
            loadWorkflow(data.recordID, depID, formGrid.getPrefixID(), site.url);
            })
            }
            }
        ])
        let tGridData = [];
        let hasServices = false;
        for (let i in res[depID].records) {
            if (res[depID].records[i].service != null) {
                hasServices = true;
            }
            tGridData.push(res[depID].records[i]);
        }
        // remove service column if there's no services
        if (hasServices == false) {
            let tHeaders = formGrid.headers();
            tHeaders.splice(1, 1);
            formGrid.setHeaders(tHeaders);
        }
        formGrid.setData(tGridData);
        formGrid.sort('recordID', 'desc');
        formGrid.renderBody();
        $('#' + formGrid.getPrefixID() + 'table').css('width', '99%');
        $('#' + formGrid.getPrefixID() + 'header_title').css('width', '60%');
        $('#depContainerIndicator_' + depID).css('display', 'none');
    }
    let dataInboxes = {};
    let sitesLoaded = [];

    // API Requests for inbox data from each site
    function loadInboxData(site, nonadmin) {
        site = site == undefined ? '' : site;
        let siteURL = site + './api/?a=inbox/dependency/_';

        if (nonadmin) {
            siteURL += '/nonadmin';
        }
        $.ajax({
            type: 'GET',
            url: siteURL,
            success: function (res) {
                dataInboxes[site] = res;
                sitesLoaded.push(site);
            },
            error: function (err) {
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
        workflow.setActionSuccessCallback(function () {
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
                let to = Object(target);
                for (let index = 1; index < arguments.length; index++) {
                    let nextSource = arguments[index];
                    if (nextSource != null) { // Skip over if undefined or null
                        for (let nextKey in nextSource) {
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
    let dialog_message;
    // Script Start
    $(function () {
        dialog_message = new dialogController('genericDialog', 'genericDialogxhr', 'genericDialogloadIndicator', 'genericDialogbutton_save', 'genericDialogbutton_cancelchange');
        sites.forEach(function (site) {
            loadInboxData(site.url, site.nonadmin);
        });
        let checkLoaded = setInterval(function () {
            if (sitesLoaded.length == sites.length) {
                clearInterval(checkLoaded);
                renderInbox();
                $('#btn_expandAll').on('click', function () {
                    $('.depInbox').click();
                    if ($('#btn_expandAll').html() == 'Expand all sections') {
                        $('#btn_expandAll').html('Hide all sections');
                    } else {
                        $('#btn_expandAll').html('Expand all sections');
                    }
                });
            }
        }, 250);
        setInterval(function () {
            let scrollPos = $(window).scrollTop();
            if (scrollPos > 120) {
                $('#index').css({
                    'position': 'absolute',
                    'top': scrollPos
                });
            } else {
                $('#index').css({
                    'position': 'inline',
                    'top': 120
                });
            }
        }, 100);
        $('#headerTab').html('My Inbox');
    });
</script>
<style>
    /*responsive grid*/
    .group:after, .section{clear:both}.section{padding:0;margin:0}.col{display:block;float:left;margin:1% 0 1% 1.6%}.col:first-child{margin-left:0}.group:after, .group:before{content:"";display:table}.group{zoom:1}.span_4_of_4{width:100%}.span_3_of_4{width:74.6%}.span_2_of_4{width:49.2%}.span_1_of_4

    {width:23.8%}@media only screen and (max-width: 480px)

    {.col{margin:1% 0}.span_1_of_4,.span_2_of_4,.span_3_of_4,.span_4_of_4{width:100%}}
</style>
<div id="genericDialog" style="visibility: hidden; display: none">
    <div>
        <div id="genericDialogbutton_cancelchange" style="display: none"></div>
        <div id="genericDialogbutton_save" style="display: none"></div>
        <div id="genericDialogloadIndicator"
             style="visibility: hidden; z-index: 9000; position: absolute; text-align: center; font-size: 24px; font-weight: bold; background-color: #f2f5f7; padding: 16px; height: 400px; width: 526px">
            <img src="images/largespinner.gif" alt="loading..."/></div>
        <div id="genericDialogxhr"
             style="width: 540px; height: 420px; padding: 8px; overflow: auto; font-size: 12px"></div>
    </div>
</div>
<div id="loading" class="card" style="text-align: center; padding: 16px; font-size: 140%"><img
            src="images/largespinner.gif" alt="loading indicator" style="vertical-align: middle"/> Loading...
</div>
<div id="inboxContainer" style="display: none">
    <button id="btn_expandAll" class="buttonNorm" style="float: right">Expand all sections</button>
    <div class="section group">
        <div class="col span_1_of_4" style="margin-right: -5%">
            <div id="index" style="margin-top: 25px">Jump to section:
                <ul id="indexSites"></ul>
            </div>
        </div>
        <div id="inbox" class="col span_3_of_4">
        </div>
    </div>
</div>