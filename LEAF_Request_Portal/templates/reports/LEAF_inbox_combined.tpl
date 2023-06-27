<script src="../libs/js/sha1.js"></script>
<script src="../libs/js/LEAF/intervalQueue.js"></script>
<script>
    let CSRFToken = '<!--{$CSRFToken}-->';

    /**
     * This script creates a combined inbox of multiple LEAF sites, organized by form type.
     * 
     * You may configure the sites that will be loaded in the "sites" variable.
     * 
     * Additionally, each site may be configured with the following custom properties:
     * - url:             Define the full url with backslash at end.
     * - name:            Title of the LEAF in the combined inbox.
     * - backgroundColor: Background color of the site's section
     * - fontColor:       Font color of the site's title
     * - icon:            (Optional) This is an image used to represent the site's section, sourced from the
     *                    Icon Repository: https://leaf.va.gov/libs/dynicons/gallery.php
     * - nonAdmin:        (Optional) Set to true if you want Admins to see only their own info and not all requests
     * - columns:         (Optional) Columns may be customized for each type of form within a site.
     *                    Columns are specified by pairing the category ID with a CSV list of columns.
     *                    Available columns include: 'UID,service,dateinitiated,title,status,days_since_last_action'
     *                    Columns may also include field indicator IDs within a form. Example: 'UID,service,title,123,status'
     *				      If a field indicator ID is used, ensure the field has a Short Label defined to populate headings.
     *   
     */

    let sites = [];

    // End of configuration

    let today = new Date();
    let headerDefinitions = {
            'UID': function(site) {
                return {
                    name: 'UID',
                    indicatorID: 'uid',
                    editable: false,
                    callback: function(data, blob) {
                        $('#' + data.cellContainerID).html('<a href="' + site.url + '?a=printview&recordID=' +
                            data.recordID + '">' + data.recordID + '</a>');
                    }
                }
            },
            'service': function(site) {
                return {
                    name: 'Service',
                    indicatorID: 'service',
                    editable: false,
                    callback: function(data, blob) {
                        $('#' + data.cellContainerID).html(blob[data.recordID].service);
                        $('#' + data.cellContainerID).attr('tabindex', '0');
                    }
                }
            },
            'dateInitiated': function(site) {
                return {
                    name: 'Date Initiated',
                    indicatorID: 'dateInitiated',
                    editable: false,
                    callback: function(data, blob) {
                        var date = new Date(blob[data.recordID].date * 1000);
                        $('#' + data.cellContainerID).html(date.toLocaleDateString().replace(/[^ -~]/g,
                            '')); // IE11 encoding workaround: need regex replacement
                    }
                }
            },
            'title': function(site) {
                let hash = Sha1.hash(site.url);
                return {
                    name: 'Title',
                    indicatorID: 'title',
                    editable: false,
                    callback: function(data, blob) {
                        $('#' + data.cellContainerID).attr('tabindex', '0');
                        $('#' + data.cellContainerID).attr('aria-label', blob[data.recordID].title);
                        $('#' + data.cellContainerID).html('<a href="' + site.url +
                            'index.php?a=printview&recordID=' + data.recordID + '" target="_blank">' +
                            blob[data.recordID].title + '</a>' +
                            ' <button id="' + data.cellContainerID +
                            '_preview" class="buttonNorm">Quick View</button>' +
                            '<div id="inboxForm' + hash + '_' + data.recordID +
                            '" style="background-color: white; display: none; height: 300px; overflow: scroll"></div>'
                        );
                        $('#' + data.cellContainerID + '_preview').on('click', function() {
                            $('#' + data.cellContainerID + '_preview').hide();
                            if ($('#inboxForm' + hash + '_' + data.recordID).html() == '') {
                                $('#inboxForm' + hash + '_' + data.recordID).html('Loading...');
                                $('#inboxForm' + hash + '_' + data.recordID).slideDown();
                                $.ajax({
                                    type: 'GET',
                                    url: site.url + 'ajaxIndex.php?a=printview&recordID=' + data
                                        .recordID,
                                    success: function(res) {
                                        $('#inboxForm' + hash + '_' + data.recordID).html(
                                            res);
                                        $('#inboxForm' + hash + '_' + data.recordID)
                                            .slideDown();
                                        $('#requestTitle').attr('tabindex', '0');
                                        $('#requestInfo').attr('tabindex', '0');
                                    }
                                })
                            }
                        })
                    }
                }
            },
            'status': function(site) {
                return {
                    name: 'Status',
                    indicatorID: 'currentStatus',
                    editable: false,
                    callback: function(data, blob) {
                        let listRecord = blob[data.recordID];
                        let cellContainer = $('#' + data.cellContainerID);
                        let waitText = listRecord.blockingStepID == 0 ? 'Pending ' : 'Waiting for ';
                        let status = '';
                        if (listRecord.stepID == null && listRecord.submitted == '0') {
                            status = '<span style="color: #e00000">Not Submitted</span>';
                        } else if (listRecord.stepID == null) {
                            let lastStatus = listRecord.lastStatus;
                            if (lastStatus == '') {
                                lastStatus = '<a href="index.php?a=printview&recordID=' + data.recordID +
                                    '">Check Status</a>';
                            }
                            status = '<span style="font-weight: bold">' + lastStatus + '</span>';
                        } else {
                            status = waitText + listRecord.stepTitle;
                        }

                        if (listRecord.deleted > 0) {
                            status += ', Cancelled';
                        }

                        cellContainer.html(status).attr('tabindex', '0').attr('aria-label', status);
                        if (listRecord.userID == '<!--{$userID}-->') {
                        cellContainer.css('background-color', '#feffd1');
                    }
                }
            }
        },
        'days_since_last_action': function(site) {
            return {
                name: 'Days Since Last Action',
                indicatorID: 'daysSinceLastAction',
                editable: false,
                callback: function(data, blob) {
                    let daysSinceAction;
                    let recordBlob = blob[data.recordID];
                    if (recordBlob.action_history != undefined) {
                        // Get Last Action no matter what (could change for non-comment)
                        let lastActionRecord = recordBlob.action_history.length - 1;
                        let lastAction = recordBlob.action_history[lastActionRecord];
                        let date = new Date(lastAction.time * 1000);

                        daysSinceAction = Math.round((today.getTime() - date.getTime()) / 86400000);
                        if (recordBlob.submitted == 0) {
                            daysSinceAction = "Not Submitted";
                        }
                    } else {
                        let dateSubmitted = new Date(recordBlob.submitted * 1000);
                        daysSinceAction = Math.round((today.getTime() - dateSubmitted.getTime()) / 86400000);
                    }
                    $('#' + data.cellContainerID).html(daysSinceAction);
                }
            }
        },
        'email_reminder': function(site) {
            return {
                name: 'Email Reminder',
                indicatorID: 'emailReminder',
                editable: false,
                callback: function(data, blob) {
                    let daysSinceAction;
                    let recordBlob = blob[data.recordID];
                    if (recordBlob.action_history != undefined) {
                        // Get Last Action no matter what (could change for non-comment)
                        let lastActionRecord = recordBlob.action_history.length - 1;
                        let lastAction = recordBlob.action_history[lastActionRecord];
                        let date = new Date(lastAction.time * 1000);

                        daysSinceAction = Math.round((today.getTime() - date.getTime()) / 86400000);
                        if (recordBlob.submitted == 0) {
                            daysSinceAction = "Not Submitted";
                        }
                    } else {
                        let dateSubmitted = new Date(recordBlob.submitted * 1000);
                        daysSinceAction = Math.round((today.getTime() - dateSubmitted.getTime()) / 86400000);
                    }
                    $('#' + data.cellContainerID).html('TBD');
                }
            }
        },
    };

    function checkAdminView(url) {
        for (let i in sites) {
            if (sites[i].url == url) {
                return sites[i].nonAdmin;
            }
        }
    }

    // renderInbox iterates through the specified sites and renders the view
    async function renderInbox() {
        for (let i in sites) {
            // sort by dependency description
            let depDesc = {};
            let categoryIDs = {};
            for (let j in dataInboxes[sites[i].url]) {
                if (dataInboxes[sites[i].url][j].categoryNames == undefined) {
                    dataInboxes[sites[i].url][j].categoryNames = ['DELETED OR INACTIVE FORM'];
                }

                // select probable category based on workflow
                let categoryName = 'DELETED OR INACTIVE FORM';
                let tCatIDs = dataInboxes[sites[i].url][j].categoryIDs;
                for (let k in tCatIDs) {
                    if (dataWorkflowCategories[tCatIDs[k]] != undefined) {
                        categoryName = dataInboxes[sites[i].url][j].categoryNames[k];
                        break;
                    }
                }

                categoryIDs[categoryName] = dataInboxes[sites[i].url][j].categoryIDs;
                if (depDesc[categoryName] == undefined) {
                    depDesc[categoryName] = [];
                }
                depDesc[categoryName].push(j);
            }
            let sortedDepDesc = Object.keys(depDesc).sort();

            sortedDepDesc.forEach(categoryName => {
                let recordIDs = depDesc[categoryName];
                buildDepInbox(dataInboxes[sites[i].url], categoryIDs[categoryName], categoryName, recordIDs,
                    sites[i]);
            });
        }
        $('#progressContainer').slideUp();
        $('#loading').slideUp();
        $('.inbox').fadeIn();
    }

    // Get site icons and name
    function getIcon(icon, name) {
        if (icon != '') {
            if (icon.indexOf('/') != -1) {
                icon = '<img src="' + icon + '" alt="icon for ' + name +
                    '" style="vertical-align: middle; width: 76px; height:76px;" />';
            } else {
                icon = '<img src="../libs/dynicons/?img=' + icon + '&w=76" alt="icon for ' + name +
                    '" style="vertical-align: middle" />';
            }
        }
        return icon;
    }

    // waiting for element to update
    function waitForElm(selector, subSelector = false) {
        return new Promise(resolve => {
            if (document.querySelector(selector)) {
                if (subSelector == false) {
                    return resolve(document.querySelector(selector));
                }
            }

            const observer = new MutationObserver(mutations => {
                if (document.querySelector(selector)) {
                    resolve(document.querySelector(selector));
                    observer.disconnect();
                }
            });

            document.querySelector('.ui-dialog-titlebar-close').addEventListener("click", observer.disconnect());

            observer.observe(document.body, {
                childList: true,
                subtree: true
            });
        });
    }

    // Build forms and grids for the inbox's requests and import to html tags
    function buildDepInbox(res, categoryIDs, categoryName, recordIDs, site) {
        let hash = Sha1.hash(site.url);
        if (categoryIDs == undefined) {
            categoryIDs = ['DELETED OR INACTIVE FORM'];
        }
        let depID = Sha1.hash(categoryIDs.join(','));

        let icon = getIcon(site.icon, site.name);
        if (document.getElementById('siteContainer' + hash) == null) {
            $('#indexSites').append('<li style="font-size: 130%; line-height: 150%"><a href="#' + hash + '">' + site
                .name + '</a></li>');
            $('#inbox').append('<div id="siteContainer' + hash +
                '" style="box-shadow: 0 2px 3px #a7a9aa; border-radius: 4px; border-left: 8px solid ' + site
                .backgroundColor + '; border-right: 8px solid ' + site.backgroundColor +
                '; border-bottom: 8px solid ' + site.backgroundColor + '; margin: 0px auto 1.5rem">' +
                '<a name="' + hash + '" />' +
                '<div style="margin-bottom: 1rem; font-weight: bold; font-size: 200%; line-height: 240%; background-color: ' +
                site
                .backgroundColor + '; color: ' + site.fontColor + '; ">' + icon + ' ' + site.name + '</div>' +
                '</div>');
        }
        $('#siteContainer' + hash).append('<div id="depContainer' + hash + '_' + depID +
            '" style="border: 1px solid black; background-color: #e6e4b9; cursor: pointer;">' +
            '<div id="depLabel' + hash + '_' + depID +
            '" class="depInbox" style="padding: 8px"><span style="float: right; text-decoration: underline; font-weight: bold">View ' +
            recordIDs.length + ' requests</span>' +
            '<span style="font-size: 130%; font-weight: bold">' + categoryName + '</span>' +
            '</div>' +
            '<div id="depList' + hash + '_' + depID +
            '" style="width: 90%; margin: auto; display: none"></div></div><br />');
        $('#depLabel' + hash + '_' + depID).on('click', function() {
            if ($('#depList' + hash + '_' + depID).css('display') == 'none') {
                $('#depList' + hash + '_' + depID).css('display', 'inline');
            } else {
                $('#depList' + hash + '_' + depID).css('display', 'none');
            }
        });

        let headers = [{
            name: 'Action',
            indicatorID: 'action',
            editable: false,
            sortable: false,
            callback: function(data, blob) {
                let depDescription = 'Take Action';
                $('#' + data.cellContainerID).css('text-align', 'center');
                $('#' + data.cellContainerID).html('<button id="btn_action' + hash + '_' + depID + '_' +
                    data.recordID +
                    '" class="buttonNorm" style="text-align: center; font-weight: bold; white-space: normal">' +
                    depDescription + '</button>');
                $('#btn_action' + hash + '_' + depID + '_' + data.recordID).on('click', function() {
                    loadWorkflow(data.recordID, formGrid.getPrefixID(), site.url);
                    waitForElm('iframe').then((el) => {
                        if (!sites.some(site => el.getAttribute('src').includes(site.url))) {
                            el.setAttribute('src', site.url + el.getAttribute('src'));
                            el.addEventListener('load', () => {
                                if (!sites.some(site => el.contentWindow?.document?.querySelector('#record').getAttribute('action').includes(site.url))) {
                                    el.contentWindow?.document?.querySelector('#record').setAttribute('action', site.url + el.contentWindow?.document?.querySelector('#record').getAttribute('action'));
                                }
                            });
                        }
                    });
                })
            }
        }];

        let customColumns = false;
        if (categoryIDs != undefined) {
            categoryIDs.forEach(categoryID => {
                if (site.columns != undefined && 
                    Array.isArray(site.columns) &&
                    site.columns[categoryID] != undefined) {
                    let customCols = [];
                    site.columns[categoryID].split(',').forEach(col => {
                        // assign standard headers
                        if (isNaN(parseInt(col)) &&
                            headerDefinitions[col] != undefined) {
                            customCols.push(headerDefinitions[col](site));
                        } else if (parseInt(col) > 0) { // assign custom data headers
                            let label = dataDictionary[site.url]?. [col]?.description;
                            if (label == undefined) {
                                label = dataDictionary[site.url]?. [col]?.name;
                            }
                            customCols.push({name: label, indicatorID: parseInt(col), editable: false});
                        }
                    });
                    headers = customCols.concat(headers);
                    customColumns = true;
                }
            });
        }
        let customCols = [];
        if (customColumns == false) {
            site.columns = site.columns ?? 'UID,service,title,status';
        }
        site.columns.split(',').forEach(col => {
            customCols.push(headerDefinitions[col](site));
        });

        headers = customCols.concat(headers);

        let formGrid = new LeafFormGrid('depList' + hash + '_' + depID);
        formGrid.setRootURL(site.url);
        formGrid.disableVirtualHeader(); // TODO: figure out why headers aren't sized correctly
        formGrid.setDataBlob(res);
        formGrid.hideIndex();
        formGrid.setHeaders(headers);
        let tGridData = [];
        let hasServices = false;
        recordIDs.forEach(recordID => {
            if (res[recordID].service != null) {
                hasServices = true;
            }
            tGridData.push(res[recordID]);
        });
        // remove service column if there's no services
        if (hasServices == false) {
            let tHeaders = formGrid.headers();
            for (let i = 0; i < tHeaders.length; i++) {
                if (tHeaders[i].indicatorID == 'service') {
                    tHeaders.splice(i, 1);
                }
            }
            formGrid.setHeaders(tHeaders);
        }
        formGrid.setData(tGridData);
        formGrid.sort('recordID', 'asc');
        formGrid.renderBody();
        //formGrid.loadData(tGridData.map(v => v.recordID).join(','));
        $('#' + formGrid.getPrefixID() + 'table').css('width', '99%');
        $('#' + formGrid.getPrefixID() + 'header_title').css('width', '60%');
        $('#depContainerIndicator_' + depID).css('display', 'none');
    }
    let dataInboxes = {};
    let dataDictionary = {};
    let dataWorkflowCategories = {};
    let batchSize = 500;

    // loadInboxData retrieves active requests, and stores the result in dataInboxes
    function loadInboxData(site, offset) {
        if (site.url == undefined) {
            alert('Site URL has not been set');
            return;
        }
        let nonAdminParam = '';
        if (site.nonAdmin) {
            nonAdminParam = '&masquerade=nonAdmin';
        }

        if (offset == undefined) {
            offset = 0;
        } else {
            offset += batchSize;
            $('#progressCount').html(`~${offset} `);
        }

        let query = new LeafFormQuery();
        query.setRootURL(site.url);
        query.setLimit(offset, batchSize);
        query.setExtraParams(
            '&x-filterData=recordID,categoryIDs,categoryNames,date,title,service,submitted,deleted,stepID,blockingStepID,lastStatus,stepTitle,action_history.time' +
            nonAdminParam);
        query.addTerm('stepID', '=', 'actionable');
        query.addTerm('deleted', '=', 0);
        query.join('service');
        query.join('categoryName');
        query.join('status');

        // get data for any custom fields
        let getData = [];
        if (site.columns != undefined && Array.isArray(site.columns)) {
            for (let i in site.columns) {
                let cols = site.columns[i].split(',');
                for (let j in cols) {
                    if (!isNaN(parseInt(cols[j]))) {
                        getData.push(parseInt(cols[j]));
                    } else {
                        switch (cols[j].toLowerCase()) {
                            case 'days_since_last_action':
                            case 'email_reminder':
                                query.join('action_history');
                                break;
                            default:
                                break;
                        }
                    }
                }
            }
        }
        if (getData.length > 0 && offset == 0) {
            getData.forEach(id => query.getData(id));
            let formList = Object.keys(site.columns).join(',');
            return $.ajax({
                    type: 'GET',
                    url: site.url + `api/form/indicator/list?forms=${formList}&x-filterData=indicatorID,name,description`,
                    success: function(res) {
                        let dict = {};
                        res.forEach(ind => {
                            dict[ind.indicatorID] = {name: ind.name, description: ind.description};
                        });
                        dataDictionary[site.url] = dict;
                    }
                })
                .then(() => query.execute().then(res => {
                    if (dataInboxes[site.url] == undefined) {
                        dataInboxes[site.url] = {};
                    }
                    dataInboxes[site.url] = Object.assign(dataInboxes[site.url],
                        res);
                    if (Object.keys(res).length == batchSize) {
                        return loadInboxData(site, offset);
                    }
                }));
        }

        return query.execute().then(res => {
            if (dataInboxes[site.url] == undefined) {
                dataInboxes[site.url] = {};
            }
            dataInboxes[site.url] = Object.assign(dataInboxes[site.url], res);
            if (Object.keys(res).length == batchSize) {
                return loadInboxData(site, offset);
            }
        });
    }

    function buildWorkflowCategoryCache(site) {
        return $.ajax({
            type: 'GET',
            url: site.url + 'api/workflow/categories?x-filterData=categoryID',
            success: function(res) {
                res.forEach(w => {
                    dataWorkflowCategories[w.categoryID] = 1;
                });
            }
        });
    }

    function loadWorkflow(recordID, prefixID, rootURL) {
        return new Promise((resolve, reject) => {
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
            resolve(document.querySelector('#workflowcontent'));
        });
    }

    const getMapSites = new Promise((resolve, reject) => {
        $.ajax({
            type: 'GET',
            url: './api/site/settings/sitemap_json',
            success: function(res) {
                if (res === 'Admin access required') {
                    return {};
                }

                let siteMap = Object.values(JSON.parse(res[0].data))[0];
                let formattedSiteMap = siteMap.map((site) => {
                    return {
                        url: site.target.endsWith('/') ? site.target: site.target + '/',
                        name: site.title,
                        backgroundColor: site.color,
                        icon: site.icon,
                        fontColor: site.fontColor,
                        cols: site.cols,
                        nonAdmin: true,
                        order: site.order,
                        columns: 'UID' + (site.columns?.length > 0 ? ',' + site.columns : ''),
                    };
                }).filter((site) => site.url.includes(window.location.hostname));

                sites.push(...formattedSiteMap);
                resolve();
            },
            fail: function(err) {
                console.log(err);
                reject();
            }
        });
    });

    let dialog_message;
    // Script Start
    $(function() {
        getMapSites.then((value) => {
            dialog_message = new dialogController('genericDialog', 'genericDialogxhr',
                'genericDialogloadIndicator', 'genericDialogbutton_save',
                'genericDialogbutton_cancelchange');
            let progressbar = $('#progressbar').progressbar();
            $('#progressbar').progressbar('option', 'max', Object.keys(sites).length);
            let queue = new intervalQueue();
            queue.setWorker(site => {
                $('#progressbar').progressbar('option', 'value', queue.getLoaded());
                $('#progressDetail').html(`Retrieving <span id="progressCount"></span>records from ${site.name}...`);
                return buildWorkflowCategoryCache(site)
                    .then(() => loadInboxData(site));
            });
            queue.onComplete(() => {
                renderInbox();
            });

            sites.forEach(site => queue.push(site));

            queue.start();

            $('#btn_expandAll').on('click', function() {
                $('.depInbox').click();
            });

            $('#headerTab').html('My Inbox');
        });
    });
</script>
<style>
    #inboxContainer {
        display: grid;
        margin-top: 25px;
        grid-template-columns: min-content 1fr;
        grid-column-gap: 1rem;
    }

    #index {
        position: sticky;
        top: 0;
        overflow-y: auto;
        max-height: 75vh;
        width: 20vw;
        background-color: white;
        border: 1px solid black;
        padding: 1rem;
    }

    .inbox {
        display: none;
    }
</style>
<div id="genericDialog" style="visibility: hidden; display: none">
    <div>
        <div id="genericDialogbutton_cancelchange" style="display: none"></div>
        <div id="genericDialogbutton_save" style="display: none"></div>
        <div id="genericDialogloadIndicator"
            style="visibility: hidden; z-index: 9000; position: absolute; text-align: center; font-size: 24px; font-weight: bold; background-color: #f2f5f7; padding: 16px; height: 400px; width: 526px">
            <img src="images/largespinner.gif" alt="loading..." />
        </div>
        <div id="genericDialogxhr" style="width: 540px; height: 420px; padding: 8px; overflow: auto; font-size: 12px">
        </div>
    </div>
</div>
<div id="progressContainer"
    style="width: 50%; border: 1px solid black; background-color: white; margin: auto; padding: 16px">
    <h1 style="text-align: center">Loading...</h1>
    <div id="progressbar"></div>
    <h2 id="progressDetail" style="text-align: center"></h2>
</div>
<div id="inboxContainer">
    <div id="index" class="inbox">Jump to section:
        <ul id="indexSites"></ul>
    </div>

    <div id="inbox" class="inbox">
        <button id="btn_expandAll" class="buttonNorm" style="float: right">Toggle sections</button>
    </div>
</div>

<h2 style="text-align: center; padding-top: 3em">End of inbox</h2>