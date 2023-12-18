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
                                    },
                                    fail: function() {
                                        triggerGenericLoadError();
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
                        if (listRecord.stepID == null) {
                            let lastStatus = listRecord.lastStatus;
                            if (lastStatus == '') {
                                lastStatus = '<a href="index.php?a=printview&recordID=' + data.recordID +
                                    '">Check Status</a>';
                            }
                            status = '<span style="font-weight: bold">' + lastStatus + '</span>';
                        } else {
                            status = waitText + listRecord.stepTitle;
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

    function scrubHTML(input) {
        let t = new DOMParser().parseFromString(input, 'text/html');
        return t.textContent;
    }

    function interfaceReady() {
        document.querySelector('#viewport').style.visibility = 'visible';
        $('#progressContainer').slideUp();
        $('#loading').slideUp();
        $('.inbox').fadeIn();
    }

    function triggerGenericLoadError() {
        alert('Error loading data. This error has been automatically reported. Please refresh the page and try again.');
    }

    // renderInbox iterates through the specified sites and renders the view, organized by form
    async function renderInbox() {
        for (let i in sites) {
            // sort by dependency description
            let depDesc = {};
            let categoryIDs = {};
            for (let j in dataInboxes[sites[i].url]) {
                if (dataInboxes[sites[i].url][j].categoryNames == undefined) {
                    dataInboxes[sites[i].url][j].categoryNames = ['INACTIVE FORM'];
                }

                // select probable category based on workflow
                let categoryName = 'INACTIVE FORM';
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

        interfaceReady();
    }

    function getSiteRoleData(sites, i) {
        let depDesc = {};
        let categoryIDs = {};

        for (let j in dataInboxes[sites[i].url]) {
            if (dataInboxes[sites[i].url][j].categoryNames == undefined) {
                dataInboxes[sites[i].url][j].categoryNames = ['INACTIVE FORM'];
            }

            // select probable category based on workflow
            let categoryName = 'INACTIVE FORM';
            let tCatIDs = dataInboxes[sites[i].url][j].categoryIDs;
            for (let k in tCatIDs) {
                if (dataWorkflowCategories[tCatIDs[k]] != undefined) {
                    categoryName = dataInboxes[sites[i].url][j].categoryNames[k];
                    dataInboxes[sites[i].url][j].categoryName = categoryName;
                    break;
                }
            }

            categoryIDs[categoryName] = dataInboxes[sites[i].url][j].categoryIDs;

            // index by roles
            for(let depID in dataInboxes[sites[i].url][j].unfilledDependencyData) {
                let uDD = dataInboxes[sites[i].url][j].unfilledDependencyData[depID];
                let roleID = depID;
                let description = uDD.description;
                if(roleID < 0 && uDD.approverUID != undefined) { // handle "smart requirements"
                    roleID = Sha1.hash(uDD.approverUID);
                    description = scrubHTML(uDD.approverName);
                }

                let stepHash = `${description}:;ROLEID${roleID}`;
                if (depDesc[stepHash] == undefined) {
                    depDesc[stepHash] = [];
                }
                j.categoryName = categoryName;
                depDesc[stepHash].push(j);
            }
        }

        return {
            depDesc: depDesc,
            categoryIDs: categoryIDs
        };
    }

    // renderInboxByRole iterates through the specified sites and renders the view, organized by workflow roles
    async function renderInboxByRole() {
        for (let i in sites) {
            // sort by workflow step
            let siteData = getSiteRoleData(sites, i);
            let depDesc = siteData.depDesc;
            let categoryIDs = siteData.categoryIDs;

            let sortedDepDesc = Object.keys(depDesc).sort();

            sortedDepDesc.forEach(hash => {
                let recordIDs = depDesc[hash];
                let stepName = hash.substring(0, hash.indexOf(':;ROLEID'));
                let stepID = hash.substring(hash.indexOf(':;ROLEID') + 8);
                buildDepInboxByStep(dataInboxes[sites[i].url], stepID, stepName, recordIDs,
                    sites[i]);
            });
        }

        interfaceReady();
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

    function triggerLoadWarning() {
        document.querySelector('#status').innerText = 'Not all records have been loaded. After you have reviewed the following records, refresh this page to load the remaining records.';
    }

    // Build forms and grids for the inbox's requests and import to html tags
    function buildDepInbox(res, categoryIDs, categoryName, recordIDs, site) {
        let hash = Sha1.hash(site.url);
        if (categoryIDs == undefined) {
            categoryIDs = ['INACTIVE FORM'];
        }
        let depID = Sha1.hash(categoryIDs.join(','));

        let icon = getIcon(site.icon, site.name);
        if (document.getElementById('siteContainer' + hash) == null) {
            $('#indexSites').append('<li style="font-size: 130%; line-height: 150%"><a href="#' + hash + '">' + site.name + '</a></li>');
            $('#inbox').append(`<a name="${hash}"></a>
				<div id="siteContainer${hash}" style="box-shadow: 0 2px 3px #a7a9aa; border: 1px solid black; 
				background-color: ${site.backgroundColor}; margin: 0px auto 1.5rem">
				<div style="font-weight: bold; font-size: 200%; line-height: 240%; background-color: ${site.backgroundColor}; color: ${site.fontColor}; ">${icon} ${site.name} </div>
				<div id="siteFormContainer${hash}" class="siteFormContainers"></div>
    			</div>`);
        }
        $(`#siteFormContainer${hash}`).append(`<div id="depContainer${hash}_${depID}" class="depContainer">
            <div id="depLabel${hash}_${depID}" class="depInbox" style="padding: 8px; background-color: ${site.backgroundColor}">
			<span style="float: right; text-decoration: underline; font-weight: bold; color: ${site.fontColor}">View ${recordIDs.length} requests</span>
			<span style="font-size: 130%; font-weight: bold; color: ${site.fontColor}">${categoryName}</span></div>
			<div id="depList${hash}_${depID}" style="width: 90%; margin: auto; display: none"></div></div>`);
        $('#depLabel' + hash + '_' + depID).on('click', function() {
            buildInboxGridView(res, depID, categoryName, recordIDs, site, hash, categoryIDs);
            if ($('#depList' + hash + '_' + depID).css('display') == 'none') {
                $('#depList' + hash + '_' + depID).css('display', 'inline');
            } else {
                $('#depList' + hash + '_' + depID).css('display', 'none');
            }
        });
    }

    function buildInboxGridView(res, stepID, stepName, recordIDs, site, hash, categoryIDs = undefined) {
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
                            let label = dataDictionary[site.url]?.[col]?.description;
                            if (label == undefined) {
                                label = dataDictionary[site.url]?.[col]?.name;
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
            if (isNaN(col)) {
                customCols.push(headerDefinitions[col](site));
            } else {
                customCols.push({
                    name: (dataDictionary[site.url]?.[col]?.name ?? dataDictionary[site.url]?.[col]?.description), indicatorID: parseInt(col), editable: false
                });
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
                $('#' + data.cellContainerID).html('<button id="btn_action' + hash + '_' + stepID + '_' +
                                                   data.recordID +
                                                   '" class="buttonNorm" style="text-align: center; font-weight: bold; white-space: normal">' +
                                                   depDescription + '</button>');
                $('#btn_action' + hash + '_' + stepID + '_' + data.recordID).on('click', function() {
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
        headers = customCols.concat(headers);

        let formGrid = new LeafFormGrid('depList' + hash + '_' + stepID);
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
        $('#depContainerIndicator_' + stepID).css('display', 'none');
    }

    // Build forms and grids for the inbox's requests based on the list of $recordIDs, organized by step
    function buildDepInboxByStep(res, stepID, stepName, recordIDs, site) {
        let hash = Sha1.hash(site.url);
		let categoryName = '';
        if(Object.keys(recordIDs).length > 0) {
            categoryName = `${res[recordIDs[0]].categoryName} - ${res[recordIDs[0]].stepTitle}`;
        }

        let icon = getIcon(site.icon, site.name);
        if (document.getElementById('siteContainer' + hash) == null) {
            $('#indexSites').append('<li style="font-size: 130%; line-height: 150%"><a href="#' + hash + '">' + site.name + '</a></li>');
            $('#inbox').append(`<a name="${hash}"></a>
				<div id="siteContainer${hash}" style="box-shadow: 0 2px 3px #a7a9aa; border: 1px solid black; 
				background-color: ${site.backgroundColor}; margin: 0px auto 1.5rem">
				<div style="font-weight: bold; font-size: 200%; line-height: 240%; background-color: ${site.backgroundColor}; color: ${site.fontColor}; ">${icon} ${site.name} </div>
				<div id="siteFormContainer${hash}" class="siteFormContainers"></div>
    			</div>`);
        }
        $(`#siteFormContainer${hash}`).append(`<div id="depContainer${hash}_${stepID}" class="depContainer">
            <div id="depLabel${hash}_${stepID}" class="depInbox" style="padding: 8px; background-color: ${site.backgroundColor}">
			<span style="float: right; text-decoration: underline; font-weight: bold; color: ${site.fontColor}">View ${recordIDs.length} requests</span>
			<span style="font-size: 130%; font-weight: bold; color: ${site.fontColor}">${stepName}</span><br />
            <span style="color: ${site.fontColor}">${categoryName}</span></div>
			<div id="depList${hash}_${stepID}" style="width: 90%; margin: auto; display: none"></div></div>`);
        $('#depLabel' + hash + '_' + stepID).on('click', function() {
            buildInboxGridView(res, stepID, stepName, recordIDs, site, hash);
            if ($('#depList' + hash + '_' + stepID).css('display') == 'none') {
                $('#depList' + hash + '_' + stepID).css('display', 'inline');
            } else {
                $('#depList' + hash + '_' + stepID).css('display', 'none');
            }
        });
    }

    let dataInboxes = {};
    let dataDictionary = {};
    let dataWorkflowCategories = {};

    // loadInboxData retrieves active requests, and stores the result in dataInboxes
    function loadInboxData(site) {
        if (site.url == undefined) {
            alert('Site URL has not been set');
            return;
        }
        let nonAdminParam = '';
        if (site.nonAdmin) {
            nonAdminParam = '&masquerade=nonAdmin';
        }

        let query = new LeafFormQuery();
        query.setRootURL(site.url);
        query.setExtraParams(
            '&x-filterData=recordID,categoryIDs,categoryNames,date,title,service,submitted,stepID,blockingStepID,lastStatus,stepTitle,action_history.time,unfilledDependencyData' +
            nonAdminParam);
        query.onProgress(progress => {
            $('#progressCount').html(`~${progress} `);
        });
        query.setAbortSignal(abortController.signal);
        query.addTerm('stepID', '=', 'actionable');
        query.addTerm('deleted', '=', 0);
        query.join('service');
        query.join('categoryName');
        query.join('status');
        if(organizeByRole) {
            query.join('unfilledDependencies');
        }

        // get data for any custom fields
        let getData = [];
        if (site.columns != undefined && Array.isArray(site.columns.split(','))) {
            let cols = site.columns.split(',');
            for (let i in site.columns.split(',')) {
                if (!isNaN(parseInt(cols[i]))) {
                    getData.push(parseInt(cols[i]));
                } else {
                    switch (cols[i].toLowerCase()) {
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
        
        if (getData.length > 0) {
            getData.forEach(id => query.getData(id));
            return $.ajax({
                    type: 'GET',
                    url: site.url + `api/form/indicator/list?x-filterData=indicatorID,name,description`,
                    success: function(res) {
                        let dict = [];
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
                    dataInboxes[site.url] = res;
                    return res;
                }).catch(err => triggerLoadWarning()));
        }

        return query.execute().then(res => {
            if (dataInboxes[site.url] == undefined) {
                dataInboxes[site.url] = {};
            }
            dataInboxes[site.url] = res;
            return res;
        }).catch(err => triggerLoadWarning());
    }

    function buildWorkflowCategoryCache(site) {
        return $.ajax({
            type: 'GET',
            url: site.url + 'api/workflow/categories?x-filterData=categoryID',
            success: function(res) {
                res.forEach(w => {
                    dataWorkflowCategories[w.categoryID] = 1;
                });
            },
            fail: function() {
                triggerGenericLoadError();
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
                        nonAdmin: nonAdmin,
                        order: site.order,
                        columns: 'UID' + (site.columns?.length > 0 ? ',' + site.columns : ''),
                    };
                }).filter((site) => site.url.includes(window.location.hostname));

                // Parse base URLs, order matters
                formattedSiteMap.map(site => {
                    if(site.url.indexOf('/admin/') != -1) {
                        site.url = site.url.substring(0, site.url.indexOf('/admin/') + 1);
                    }
                    else if(site.url.indexOf('/?') != -1) {
                        site.url = site.url.substring(0, site.url.indexOf('/?') + 1);
                    }
                    else if(site.url.indexOf('/index.php?') != -1) {
                        site.url = site.url.substring(0, site.url.indexOf('/index.php?') + 1);
                    }
                    else if(site.url.indexOf('/report.php?') != -1) {
                        site.url = site.url.substring(0, site.url.indexOf('/report.php?') + 1);
                    }
                    else if(site.url.indexOf('/api/open/form/query/') != -1) {
                        site.url = site.url.substring(0, site.url.indexOf('/api/open/form/query/') + 1);
                    }
                    else if(site.url.indexOf('/open.php?') != -1) {
                        site.url = site.url.substring(0, site.url.indexOf('/open.php?') + 1);
                    }
                });

                // Remove duplicate URLs
                let uniqueSites = {};
                formattedSiteMap.forEach(site => {
                    uniqueSites[site.url] = site;
                });

                sites.push(...Object.values(uniqueSites));
                resolve();
            },
            fail: function(err) {
                console.log(err);
                reject();
            }
        });
    });

	function getCurrLocation() {
        let hashIndex = window.location.href.indexOf('#');
        let currLocation = '';
        if(hashIndex > 0) {
            currLocation = window.location.href.substring(0, hashIndex);
        }
        else {
            currLocation = window.location.href;
        }
        return currLocation;
    }

    let dialog_message;
    let nonAdmin = true;
    let organizeByRole = false;
    let abortController = new AbortController();
    // Script Start
    $(function() {
        document.title = 'Inbox - ' + document.title;

        let urlParams = new URLSearchParams(window.location.search);
        if(urlParams.get('adminView') != null) {
            nonAdmin = false;
            document.querySelector('#btn_adminView').innerText = 'View as non-admin';
        }
        
        if(urlParams.get('organizeByRole') != null) {
            organizeByRole = true;
            document.querySelector('#btn_organize').innerText = 'Organize by Forms';
        }
        
        getMapSites.then((value) => {
            dialog_message = new dialogController('genericDialog', 'genericDialogxhr',
                'genericDialogloadIndicator', 'genericDialogbutton_save',
                'genericDialogbutton_cancelchange');
            dialog_ok = new dialogController('ok_xhrDialog', 'ok_xhr', 'ok_loadIndicator', 'confirm_button_ok', 'confirm_button_cancelchange');
            let progressbar = $('#progressbar').progressbar();
            $('#progressbar').progressbar('option', 'max', Object.keys(sites).length);
            let queue = new intervalQueue();
            queue.setWorker(site => {
                $('#progressbar').progressbar('option', 'value', queue.getLoaded());
                $('#progressDetail').html(`Searching <span id="progressCount"></span>records from ${site.name}...`);
                return loadInboxData(site).then(() => {
                    if(Object.keys(dataInboxes[site.url]).length > 0) {
                        return buildWorkflowCategoryCache(site);
                    }
                });
            });
            queue.onComplete(() => {
                if(urlParams.get('organizeByRole') != null) {
                   renderInboxByRole();
            	}
                else {             
                	renderInbox();
        		}
            });
            queue.setAbortSignal(abortController.signal);

            sites.forEach(site => queue.push(site));
            
            // If $sites is empty, load the local inbox
            if(Object.keys(sites).length == 0 || urlParams.get('local') != null) {
                let localSite = {
                    	url: './',
                        name: 'Inbox',
                        backgroundColor: '#e6e4b9',
                        icon: '../libs/dynicons/svg/internet-mail.svg',
                        fontColor: 'black',
                    	nonAdmin: nonAdmin,
                };
                sites.push(localSite);
                queue.setQueue([localSite]);
                document.querySelector('#index').style.visibility = 'hidden';
                document.querySelector('#inbox').style.width = '70%';
            }

            queue.start();

            $('#btn_expandAll').on('click', function() {
                $('.depInbox').click();
            });
            
            $('#btn_adminView').on('click', function() {
				let currLocation = getCurrLocation();

                if(nonAdmin) {
                    window.location.href = currLocation + '&adminView';
                }
                else {
                    window.location.href = currLocation.replace('&adminView', '');
                }
            });

            $('#btn_organize').on('click', function() {
				let currLocation = getCurrLocation();

                if(organizeByRole) {
                    window.location.href = currLocation.replace('&organizeByRole', '');
                }
                else {
                    window.location.href = currLocation + '&organizeByRole';
                }
            });

            $('#btn_progressStop').on('click', function() {
                abortController.abort();
                $('#progressDetail').html(`Cleaning up...`);
                triggerLoadWarning();
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
    
    .depInbox {
        padding: 8px;
        position: sticky;
        top: 0px;
    }
    
    .siteFormContainers {
        padding: 8px;
        background-color: white;
    }
    
    .depContainer {
        border: 1px solid black;
        cursor: pointer;
        margin: 1rem;
    }
</style>

<!--{include file="site_elements/generic_OkDialog.tpl"}-->

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
<div id="status" style="text-align: center; color: red; font-weight: bold"></div>
<div id="progressContainer"
    style="width: 50%; border: 1px solid black; background-color: white; margin: auto; padding: 16px; text-align: center">
    <h1>Loading...</h1>
    <div id="progressbar"></div>
    <h2 id="progressDetail"></h2>
    <button id="btn_progressStop" class="buttonNorm">Stop and show results</button>
</div>

<div id="viewport" style="visibility: hidden">
<button id="btn_adminView" class="buttonNorm" style="float: right; <!--{if !$empMembership['groupID'][1]}-->display: none<!--{/if}-->">View as Admin</button>
<button id="btn_organize" class="buttonNorm" style="float: right">Organize by Roles</button>
<button id="btn_expandAll" class="buttonNorm" style="float: right">Toggle sections</button>
<br />
<div id="inboxContainer">
    <div id="index" class="inbox">Jump to section:
        <ul id="indexSites"></ul>
    </div>
    <div id="inbox" class="inbox">
    </div>
</div>

<h2 style="text-align: center; padding-top: 5em">No more items in your inbox. Have a good day!</h2>

<a href="index.php?a=inbox" style="margin-top: 3em">View Original Inbox</a>
</div>
