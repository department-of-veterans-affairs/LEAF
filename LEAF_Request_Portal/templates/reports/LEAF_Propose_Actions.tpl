<script src="../libs/js/LEAF/intervalQueue.js"></script>
<style>
#content {
    margin: 1rem;
}
p, .card {
    font-size: 1rem;
}
.card {
    padding: 1rem;
    margin-bottom: 1rem;
}
table.leaf_grid > tbody > tr > td, table select {
    font-size: 14pt;
    padding: 1rem;
    line-height: 1.7rem;
}
.file {
    background-color: #e0e0e0;
    border-radius: 10px;
    padding: 4px;
    margin: 4px;
    font-size: 12pt;
}
</style>
<script>
function scrubHTML(input) {
    if(input == undefined) {
        return '';
    }
    let t = new DOMParser().parseFromString(input, 'text/html').body;
    while(input != t.textContent) {
        return scrubHTML(t.textContent);
    }
    return t.textContent;
}

async function showSetup() {
    document.querySelector('#setup').style.display = 'block';

    let formsObj = await fetch('api/workflow/steps').then(res => res.json());
    let forms = [];
    for(let i in formsObj) {
        forms.push(formsObj[i]);
    }
    let collator = new Intl.Collator('en', {numeric: true, sensitivity: 'base'});
    forms.sort((a, b) => collator.compare(a.stepTitle, b.stepTitle));
    let buf = '';
    for(let i in forms) {
        buf += `<option value="${forms[i].stepID}">${scrubHTML(forms[i].stepTitle)}</option>`;
    }

    document.querySelector('#steps').innerHTML = buf;
    document.querySelector('#create').addEventListener('click', () => {
        let stepID = document.querySelector('#steps').value;
        let url = window.location.href;
        
        url += `&stepID=${stepID}`;

        window.location = url;
    });
}

function getPrimaryCategory(activeCategories, categoryIDlist) {
    for(let i in categoryIDlist) {
        let tCat = categoryIDlist[i];
        if(activeCategories[tCat] != undefined) {
            return {
                categoryID: activeCategories[tCat].categoryID,
                categoryName: activeCategories[tCat].categoryName
            };
        }
    }
    return 'Unknown form type';
}

function updateUrlColumnState(customColumns) {
    const url = new URL(location);
    url.searchParams.set("indicatorIDs", customColumns.join('-'));
    history.pushState({}, "", url);
}

async function setupProposals(stepID) {

    function initColRemovalListeners() {
        let btns_removeColumn = document.querySelectorAll('#' + grid.getPrefixID() + 'thead_tr>th>img');
        btns_removeColumn = Array.from(btns_removeColumn);
        headers = grid.headers();
        for(let i in btns_removeColumn) {
            btns_removeColumn[i].addEventListener('click', () => {
                let removeID = btns_removeColumn[i].dataset.id;
                customColumns.splice(customColumns.indexOf(removeID), 1);
                let newHeaders = headers.filter(header => {
                    return header.indicatorID != removeID;
                });
   
                grid.setHeaders(newHeaders);
                grid.renderBody();
                initColRemovalListeners();
                updateUrlColumnState(customColumns);
            });
        }
    }

    document.querySelector('#setupProposals').style.display = 'block';

    let customColumns = [];
    let stepInfo = await fetch(`api/workflow/step/${stepID}`).then(res => res.json());
    let promiseData = [];
    promiseData.push(fetch(`api/workflow/${stepInfo.workflowID}/route`).then(res => res.json()));
    promiseData.push(fetch('api/formStack/categoryList').then(res => res.json()));
    promiseData.push(fetch(`api/workflow/step/${stepID}/dependencies`).then(res => res.json()));
    let [routeInfo, activeCategoryData, dependencies] = await Promise.all(promiseData);
    let activeCategories = {};
    let actions = [];

    routeInfo.forEach(route => {
    	if(route.stepID == stepID) {
            actions.push(route);
        }
    });
    
    // get dependencyID or prompt user to select it
    let dependencyID = null;
    if(dependencies.length > 1) {
        document.querySelector('#selectDependency').style.display = 'inline';
        document.querySelector('#selectDependency').innerHTML = 'Select a role: <select id="dependencySelect"><option value="">Select...</option></select>';
        dependencies.forEach(dep => {
            document.querySelector('#dependencySelect').innerHTML += `<option value="${dep.dependencyID}">${dep.description}</option>`;
        });
        document.querySelector('#dependencySelect').addEventListener('change', () => {
            dependencyID = document.querySelector('#dependencySelect').value;
        });
    } else {
        dependencyID = dependencies[0].dependencyID;
    }

    // need this to provide a cleaner view (e.g. avoid showing names of stapled forms)
    activeCategoryData.forEach(cat => {
        activeCategories[cat.categoryID] = cat;
    });
    
    let htmlActions = '<option value=""></option>';
    actions.forEach(action => {
    	htmlActions += `<option value="${action.actionType}">${action.actionText}</option>`;
    });
    
    let query = new LeafFormQuery();
    query.addTerm('stepID', '=', stepID);
    query.join('categoryName');
    let data = await query.execute();
    
    if(Object.keys(data).length == 0) {
        alert('No records available for this step.');
        return;
    }

    // prep data for column customization
    let firstRecordCategories = data[Object.keys(data)[0]].categoryIDs;
    console.log(firstRecordCategories);
    let catID = getPrimaryCategory(activeCategories, firstRecordCategories).categoryID;
    let fieldData = {};
    let fieldPromises = [];
    firstRecordCategories.forEach(catID => {
        fieldPromises.push(fetch(`./api/form/_${catID}/flat`).then(res => res.json()));
    });
    let promiseResults = await Promise.all(fieldPromises);
    promiseResults.forEach(result => {
        for(let i in result) {
            fieldData = {...fieldData, ...result};
        }
    });
    
    let headers = [
        {name: '#', indicatorID: 'uid', editable: false, callback: function(data, blob) {
            document.querySelector(`#${data.cellContainerID}`).innerHTML = `<span style="background-color: black; color: white; padding: 4px; margin: 4px">${data.recordID}</span>`;
        }},
		{name: 'Type', indicatorID: 'type', editable: false, callback: function(data, blob) {
            let primaryCategory = getPrimaryCategory(activeCategories, blob[data.recordID].categoryIDs);
            document.querySelector(`#${data.cellContainerID}`).innerHTML = primaryCategory.categoryName;
        }},
        {name: 'Title', indicatorID: 'title', editable: false, callback: function(data, blob) {
            document.querySelector(`#${data.cellContainerID}`).innerHTML = `<a href="index.php?a=printview&recordID=${data.recordID}" target="_blank">${blob[data.recordID].title}</a>`;
        }},
        {name: 'Propose Action', indicatorID: 'decision', editable: false, sortable: false, callback: function(data, blob) {
            document.querySelector(`#${data.cellContainerID}`).style.backgroundColor = '#fee685';
            let options = `<select class="recordDecision" data-record-id="${data.recordID}">
    				${htmlActions}
    			</select>`;
            document.querySelector(`#${data.cellContainerID}`).innerHTML = options;
            document.querySelector(`#${data.cellContainerID}>select`).addEventListener('change', (evt) => {
                if(evt.target.value != '') {
                    document.querySelector(`#${grid.getPrefixID()}${data.recordID}_comments>textarea`).style.display = 'inline';
                } else {
                    document.querySelector(`#${grid.getPrefixID()}${data.recordID}_comments>textarea`).style.display = 'none';
                }
            });
        }},
        {name: 'Comments', indicatorID: 'comments', editable: false, sortable: false, callback: function(data, blob) {
            let options = `<textarea style="display: none" class="recordComment" data-record-id="${data.recordID}"></textarea>`;
            document.querySelector(`#${data.cellContainerID}`).innerHTML = options;
        }}
    ];

    let grid = new LeafFormGrid('proposalGrid');
    grid.hideIndex();
    grid.setDataBlob(data);
    grid.setHeaders(headers);

    // Load previous proposal from URL if it exists
    let indicatorIDs = new URLSearchParams(window.location.search).get('indicatorIDs');
    if(indicatorIDs) {
        let query = new LeafFormQuery();
        query.addTerm('stepID', '=', stepID);
        query.join('categoryName');

        let indicatorList = indicatorIDs.split('-');
        indicatorList.forEach(colID => {
            query.getData(colID);
            customColumns.push(colID);
            let fieldName = fieldData[colID][1].description == '' ? fieldData[colID][1].name : fieldData[colID][1].description;
            let format = fieldData[colID][1].format;
            fieldName = scrubHTML(fieldName);
            let newHeader = {name: fieldName + ` <img src="dynicons/?img=process-stop.svg&w=16" style="cursor: pointer" data-id="${colID}">`, indicatorID: colID, sortable: false, editable: false, callback: function(data, blob) {
                if(format == 'fileupload' && blob[data.recordID].s1[`id${colID}`] != null) {
                    let files = blob[data.recordID].s1[`id${colID}`].split("\n");
                    let output = '';
                    let i = 0;
                    files.forEach(file => {
                        if(file.length > 20) {
                            file = file.substring(0, 17) + '...' + file.substring(file.length-10, file.length);
                        }
                        output += `<div class="file"><img src="dynicons/?img=mail-attachment.svg&w=24" alt=""><a href="file.php?form=${data.recordID}&id=${colID}&series=1&file=${i}" target="_blank">${file}</a></div>`;
                        i++;
                    });
                    document.querySelector(`#${data.cellContainerID}`).innerHTML = output;
                } else{
                    document.querySelector(`#${data.cellContainerID}`).innerHTML = blob[data.recordID].s1[`id${colID}`];
                }
            }};
            headers = grid.headers();
            headers.splice(headers.length - 2, 0, newHeader);
            grid.setHeaders(headers);
        });

        let data = await query.execute();
        grid.setDataBlob(data);
        grid.renderBody();
        initColRemovalListeners();
    }
    else {
        grid.renderBody();
    }
    

    // add options for column customization
    let fields = [];
    for(let i in fieldData) {
        if(fieldData[i].format != '') {
            fields.push(fieldData[i][1]);
        }
    }
    let collator = new Intl.Collator('en', {numeric: true, sensitivity: 'base'});
    fields.sort((a, b) => collator.compare(a.name, b.name));

    let columnsHTML = '';
    fields.forEach(field => {
        if(field.format != '') {
            let fieldName = field.description == '' ? field.name : field.description;
            fieldName = scrubHTML(fieldName);
            columnsHTML += `<option value="${field.indicatorID}">${field.name}</option>`;
        }
    });
    document.querySelector('#fieldNames').innerHTML = columnsHTML;

    document.querySelector('#btn_addColumn').addEventListener('click', async () => {
        let colID = document.querySelector('#fieldNames').value;

        if(customColumns.indexOf(colID) != -1) {
            return;
        }
        customColumns.push(colID);
        let fieldName = fieldData[colID][1].description == '' ? fieldData[colID][1].name : fieldData[colID][1].description;
        let indicator = fieldData[colID][1];
        fieldName = scrubHTML(fieldName);
        let newHeader = {name: fieldName + ` <img src="dynicons/?img=process-stop.svg&w=16" style="cursor: pointer" data-id="${colID}">`, indicatorID: colID, sortable: false, editable: false, callback: function(data, blob) {
            if(indicator.format == 'fileupload' && blob[data.recordID].s1[`id${colID}`] != null) {
                let files = blob[data.recordID].s1[`id${colID}`].split("\n");
                let output = '';
                let i = 0;
                files.forEach(file => {
                    if(file.length > 20) {
                        file = file.substring(0, 17) + '...' + file.substring(file.length-10, file.length);
                    }
                    output += `<div class="file"><img src="dynicons/?img=mail-attachment.svg&w=24" alt=""><a href="file.php?form=${data.recordID}&id=${colID}&series=1&file=${i}" target="_blank">${file}</a></div>`;
                    i++;
                });
                document.querySelector(`#${data.cellContainerID}`).innerHTML = output;
            } else {
                document.querySelector(`#${data.cellContainerID}`).innerHTML = blob[data.recordID].s1[`id${colID}`];
            }
        }};
        headers = grid.headers();
        headers.splice(headers.length - 2, 0, newHeader);
        grid.setHeaders(headers);

        var query = new LeafFormQuery();
        query.addTerm('stepID', '=', stepID);
        query.join('categoryName');
        customColumns.forEach(col => {
            query.getData(col);
        });
        let data = await query.execute();

        grid.setDataBlob(data);
        grid.renderBody();
        updateUrlColumnState(customColumns);

        initColRemovalListeners();
    });

    document.querySelector('#btn_prepareProposal').addEventListener('click', () => {
        prepareProposal(actions, dependencyID, fieldData);
    });
}

function prepareProposal(actions, dependencyID, fieldData) {
    let numDecisions = 0;
    let decisions = {};
    let comments = {};
    document.querySelectorAll('.recordDecision').forEach(decision => {
        let recordID = decision.getAttribute('data-record-id');
        if(decision.value != '') {
            decisions[recordID] = decision.value;
            numDecisions++;
        }
    });
    document.querySelectorAll('.recordComment').forEach(comment => {
        let recordID = comment.getAttribute('data-record-id');
        if(comment.value != '') {
            comments[recordID] = comment.value;
        }
    });

    if(numDecisions == 0) {
        alert("No proposed actions have been prepared.");
        return;
    }

    const url = new URL(location);

    let cleanActions = [];
    actions.forEach(action => {
        cleanActions.push({
            type: action.actionType,
            text: action.actionText
        });
    });
    
    // encode proposal
    if(dependencyID == null) {
        alert('Pleae select a role.');
        return;
    }

    let proposal = {};
    proposal.stepID = url.searchParams.get('stepID');
    proposal.dependencyID = dependencyID;
    proposal.actions = cleanActions;
    let indicatorIDs = url.searchParams.get('indicatorIDs');
    proposal.decisions = decisions;
    proposal.comments = comments;
    proposal.indicatorIDs = [];
    if(indicatorIDs != null && indicatorIDs != '') {
        indicatorIDs = indicatorIDs.split('-');
        indicatorIDs.forEach(id => {
            let fieldName = fieldData[id][1].description == '' ? fieldData[id][1].name : fieldData[id][1].description;
            fieldName = scrubHTML(fieldName);
            proposal.indicatorIDs.push({
                indicatorID: id,
                name: fieldName,
                format: fieldData[id][1].format
            });
        });
    }
    proposal.title = document.querySelector('#proposalTitle').value;
    proposal.description = document.querySelector('#proposalDescription').value;
    let proposalParam = LZString.compressToBase64(JSON.stringify(proposal));;

    let newUrl = window.location.href.substring(0, window.location.href.indexOf('&'));
    newUrl += `&proposal=${encodeURIComponent(proposalParam)}`;

    window.location.href = newUrl;
}

async function showProposal(encodedProposal) {
    document.querySelector('#proposal').style.display = 'block';

    let proposal = LZString.decompressFromBase64(encodedProposal);
    proposal = JSON.parse(proposal);
    
    document.querySelector('#reviewTitle').innerText = proposal.title;
    document.querySelector('#reviewDescription').innerText = proposal.description;

    let activeCategoryData = await fetch('api/formStack/categoryList').then(res => res.json());
    let activeCategories = {};
    // need this to provide a cleaner view (e.g. avoid showing names of stapled forms)
    activeCategoryData.forEach(cat => {
        activeCategories[cat.categoryID] = cat;
    });

    let htmlActions = '';
    let actionText = {};
    proposal.actions.forEach(action => {
        htmlActions += `<option value="${action.type}">${action.text}</option>`;
        actionText[action.type] = action.text;
    });

    let query = new LeafFormQuery();
    query.addTerm('stepID', '=', proposal.stepID);
    query.join('categoryName');
    proposal.indicatorIDs.forEach(indicator => {
        query.getData(indicator.indicatorID);
    });
    let data = await query.execute();

    // filter out data, only show ones with proposed decisions
    for(let i in data) {
        if(proposal.decisions[i] == undefined) {
            delete data[i];
        }
    }

    if(Object.keys(data).length == 0) {
        document.querySelector('#grid').style.display = 'none';
        document.querySelector('#proposalStatus').innerHTML = '<p>There are no actionable records in this proposal.</p>';
        return;
    }

    let grid = new LeafFormGrid('grid');
    grid.setDataBlob(data);
    grid.hideIndex();

    let headers = [
        {name: '#', indicatorID: 'uid', editable: false, callback: function(data, blob) {
            document.querySelector(`#${data.cellContainerID}`).innerHTML = `<span style="background-color: black; color: white; padding: 4px; margin: 4px">${data.recordID}</span>`;
        }},
		{name: 'Type', indicatorID: 'type', editable: false, callback: function(data, blob) {
            let primaryCategory = getPrimaryCategory(activeCategories, blob[data.recordID].categoryIDs);
            document.querySelector(`#${data.cellContainerID}`).innerHTML = primaryCategory.categoryName;
        }},
        {name: 'Title', indicatorID: 'title', editable: false, callback: function(data, blob) {
            document.querySelector(`#${data.cellContainerID}`).innerHTML = `<a href="index.php?a=printview&recordID=${data.recordID}" target="_blank">${blob[data.recordID].title}</a>`;
        }},
        {name: 'Proposed Action', indicatorID: 'decision', editable: false, callback: function(data, blob) {
            let proposedAction = actionText[proposal.decisions[data.recordID]];
            document.querySelector(`#${data.cellContainerID}`).style.textAlign = 'center';
            document.querySelector(`#${data.cellContainerID}`).style.backgroundColor = '#fee685';
            
            document.querySelector(`#${data.cellContainerID}`).innerHTML = proposedAction;
        }},
        {name: 'Comments', indicatorID: 'comments', editable: false, callback: function(data, blob) {
            document.querySelector(`#${data.cellContainerID}`).style.backgroundColor = '#e0e0e0';
            let comment = `<textarea class="recordComment" data-record-id="${data.recordID}">${scrubHTML(proposal.comments[data.recordID])}</textarea>`;
            document.querySelector(`#${data.cellContainerID}`).innerHTML = comment;
        }},
    ];

    proposal.indicatorIDs.forEach(indicator => {
        let newHeader = {name: indicator.name, indicatorID: indicator.indicatorID, editable: false, callback: function(data, blob) {
                if(indicator.format == 'fileupload' && blob[data.recordID].s1[`id${indicator.indicatorID}`] != null) {
                    let files = blob[data.recordID].s1[`id${indicator.indicatorID}`].split("\n");
                    let output = '';
                    let i = 0;
                    files.forEach(file => {
                        if(file.length > 20) {
                            file = file.substring(0, 17) + '...' + file.substring(file.length-10, file.length);
                        }
                        output += `<div class="file"><img src="dynicons/?img=mail-attachment.svg&w=24" alt=""><a href="file.php?form=${data.recordID}&id=${indicator.indicatorID}&series=1&file=${i}" target="_blank">${file}</a></div>`;
                        i++;
                    });
                    document.querySelector(`#${data.cellContainerID}`).innerHTML = output;
                } else {
                    document.querySelector(`#${data.cellContainerID}`).innerHTML = blob[data.recordID].s1[`id${indicator.indicatorID}`];
                }
            }
        };
        headers.splice(headers.length - 2, 0, newHeader);
    });

    grid.setHeaders(headers);
    grid.renderBody();

    document.querySelector('#btn_approveProposal').addEventListener('click', async () => {
        let confirm_dialog = new dialogController('confirm_xhrDialog', 'confirm_xhr', 'confirm_loadIndicator', 'confirm_button_save', 'confirm_button_cancelchange');
        confirm_dialog.setContent('<img src="dynicons/?img=application-certificate.svg&amp;w=48" alt="" style="float: left; padding-right: 16px" /> <span style="font-size: 150%">Please confirm your approval of this proposal.</span>');
        confirm_dialog.setTitle('Confirmation');
        confirm_dialog.setSaveHandler(async function() {
            confirm_dialog.setContent('Applying actions...<br /><div id="confirmProgress"></div>');
            confirm_dialog.hideButtons();

            let comments = {};
            document.querySelectorAll('.recordComment').forEach(comment => {
                let recordID = comment.getAttribute('data-record-id');
                if(comment.value != '') {
                    comments[recordID] = comment.value;
                }
            });

            // clear out old decisions on repeat runs
            for(let i in proposal.decisions) {
                if(data[i] == undefined) {
                    delete proposal.decisions[i];
                }
            }

            let queue = new intervalQueue();
            queue.setQueue(Object.keys(proposal.decisions));
            queue.setWorker(item => {
                let comment = '(Decision as per proposal)';
                if(comments[item] != undefined && comments[item] != '') {
                    comment = comments[item].trim() + "\n" + comment;
                }
                document.querySelector('#confirmProgress').innerHTML = `Confirmed ${queue.getLoaded()}/${Object.keys(proposal.decisions).length}`;
                let formData = new FormData();
                formData.append('actionType', proposal.decisions[item]);
                formData.append('dependencyID', proposal.dependencyID);
                formData.append('comment', comment);
                formData.append('CSRFToken', '<!--{$CSRFToken}-->');
                return fetch(`./api/formWorkflow/${item}/apply`, {
                    method: 'POST',
                    body: formData
                });
            });
            await queue.start();
            window.location.reload();
        });
        confirm_dialog.show();
    });
}

async function main() {
    document.querySelector('title').innerText = 'Proposed Actions';

    const urlParams = new URLSearchParams(window.location.search);
    let stepID = urlParams.get('stepID');
    let proposal = urlParams.get('proposal');

    if(proposal != null) {
        showProposal(proposal);
    }
    else if(stepID != null) {
        setupProposals(stepID);
    }
    else {
        showSetup();
    }
}

document.addEventListener('DOMContentLoaded', main);
</script>
<div id="setup" style="display: none">
    <h1>Create Proposal</h1>
    <p>This will create a custom page to help an approving official review and execute proposed actions.</p>

    <br /><br />
    <div class="card">
        Select a step: <select id="steps"><option>Loading...</option></select>
        <br /><br />

        <button id="create" class="buttonNorm">Setup Proposed Actions</button>
        <br /><br />
    </div>
</div>
<div id="setupProposals" style="display: none" class="card">
    <h1>Create Proposal</h1>
    <p>Records without a proposed action will not be listed during final review.</p>
    <ul>
        <li id="selectDependency" style="display: none"></li>
        <li>Title of proposal: <input type="text" id="proposalTitle" /></li>
        <li>Description: <textarea id="proposalDescription"></textarea></li>
    </ul>
    <h2>Customize View</h2>
    <p>Data columns may be added to provide relevant information during final review.</p>
    <p>Tip: Save the URL to use your customizations for future reviews.</p>
    <ul>
        <li>
            <select id="fieldNames"></select>
            <button id="btn_addColumn" class="buttonNorm">Add Column</button>
        </li>
    </ul>
    <div id="proposalGrid" style="margin-bottom: 3rem">Loading...</div>
    <button id="btn_prepareProposal" class="buttonNorm" style="position: fixed; bottom: 14px; margin: auto; left: 0; right: 0; font-size: 140%; height: 52px; padding-top: 8px; padding-bottom: 4px; width: 70%; margin: auto; text-align: center; box-shadow: 0 0 20px black"><img src="dynicons/?img=x-office-spreadsheet-template.svg&w=32" alt="" /> Prepare Proposal</button>
</div>
<div id="proposal" style="display: none">
    <h1 id="reviewTitle" style="text-align: center">Loading...</h1>
    <p id="reviewDescription" style="margin: auto; width: 40vw; margin-bottom: 2rem">...</p>
    <div style="display: flex; justify-content: center; align-items: center">
        <div id="grid" style="margin-bottom: 3rem; margin: auto; min-width: 0">Loading...</div>
    </div>
    <div id="proposalStatus" style="text-align: center; margin-top: 2rem">
        <button id="btn_approveProposal" class="buttonNorm" style="font-size: 14pt; padding: 8px"><img src="dynicons/?img=gnome-emblem-default.svg&w=32" alt=""> Approve this Proposal</button>
    </div>
</div>

<div id="confirm_xhrDialog" style="background-color: #feffd1; border: 1px solid black; visibility: hidden; display: none">
    <form id="confirm_record" enctype="multipart/form-data" action="javascript:void(0);">
        <div>
            <div id="confirm_loadIndicator" style="visibility: hidden; position: absolute; text-align: center; font-size: 24px; font-weight: bold; background: white; padding: 16px; height: 100px; width: 360px">Loading... <img src="images/largespinner.gif" alt="" /></div>
            <div id="confirm_xhr" style="font-size: 130%; width: 400px; height: 120px; padding: 16px; overflow: auto"></div>
            <div style="position: absolute; left: 10px; font-size: 140%"><button type="button" class="buttonNorm" id="confirm_button_cancelchange" disabled><img src="dynicons/?img=edit-undo.svg&amp;w=32" alt="" /> Cancel</button></div>
            <div style="text-align: right; padding-right: 6px"><button type="button" class="buttonNorm" id="confirm_button_save" disabled><img src="dynicons/?img=dialog-apply.svg&amp;w=32" alt="" /><span id="confirm_saveBtnText"> Approve this Proposal</span></button></div><br />
        </div>
    </form>
</div>
