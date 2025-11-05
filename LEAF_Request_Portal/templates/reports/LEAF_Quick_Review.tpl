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
.buttonNorm {
    border-radius: 8px;
}
label {
    line-height: 1.3rem;
}
input, .input textarea, select {
    max-width: 30rem;
    width: 100%;
    padding: .5rem;
}
.input ul, .input li {
    margin-bottom: 1rem;
    list-style-type: none;
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

    let activeForms = await fetch('api/formStack/categoryList').then(res => res.json());
    let forms = '<option></option>';
    activeForms.forEach(form => {
        forms += `<option value="${form.workflowID}">${form.categoryName}</option>`;
    });
    
    document.querySelector('#forms').innerHTML = forms;
    document.querySelector('#forms').addEventListener('change', (evt) => {
        showSetupP2(evt.target.value);
    });
}

async function showSetupP2(workflowID) {
    document.querySelector('#setupP2').style.display = 'block';

    let formsObj = await fetch(`api/workflow/${workflowID}`).then(res => res.json());
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

function getDataHeader(colID, fieldData = null, indicator = null, isFinalProposal = false) {
    let fieldName = '';
    if(fieldData != null && fieldData[colID] != undefined) {
        fieldName = fieldData[colID].description == '' ? fieldData[colID].name : fieldData[colID].description;
        indicator = fieldData[colID];
    } else if (indicator != null) {
        fieldName = indicator.name;
    } else if (colID == 'service') {
        fieldName = 'Service';
    } else {
        console.error('unknown field');
        return;
    }

    let colRemovalBtn = '';
    if (!isFinalProposal) {
        colRemovalBtn = ` <img role="button" aria-label="remove column: ${colID}" src="dynicons/?img=process-stop.svg&w=16" style="cursor: pointer" data-id="${colID}">`;
    }

    fieldName = scrubHTML(fieldName);
    let newHeader = {};
    if(colID == 'service') {
        newHeader = {name: 'Service' + colRemovalBtn, indicatorID: 'service', sortable: false, editable: false, callback: function(data, blob) {
                    document.querySelector(`#${data.cellContainerID}`).innerHTML = blob[data.recordID].service;
                }};
    } else {
        newHeader = {name: fieldName + colRemovalBtn, indicatorID: colID, sortable: false, editable: false, callback: function(data, blob) {
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
            } else if(indicator.format == 'currency') {
                document.querySelector(`#${data.cellContainerID}`).innerHTML = Intl.NumberFormat(undefined, {style: 'currency', currency: 'USD'}).format(blob[data.recordID].s1[`id${colID}`]);
            } else {
                document.querySelector(`#${data.cellContainerID}`).innerHTML = blob[data.recordID].s1[`id${colID}`];
            }
        }};
    }
    return newHeader;
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
    document.querySelector('#stepName').innerHTML = `: ${stepInfo.stepTitle}`;

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
        document.querySelector('#selectDependency').style.display = 'list-item';
        document.querySelector('#selectDependency').innerHTML = '<label>Select a role <span style="color: #c00">*required</span><br /><select id="dependencySelect"><option value="">Select...</option></select></label>';
        dependencies.forEach(dep => {
            document.querySelector('#dependencySelect').innerHTML += `<option value="${dep.dependencyID}">${dep.description}</option>`;
        });
        document.querySelector('#dependencySelect').addEventListener('change', () => {
            dependencyID = document.querySelector('#dependencySelect').value;

            // If the step includes multiple requirements, filter out dependencyIDs that don't match
            let filteredData = {};
            for(let i in data) {
                if(data[i].unfilledDependencyData[dependencyID] != undefined) {
                    filteredData[i] = data[i];
                }
            }
            grid.setDataBlob(filteredData);
            grid.renderBody();
            initColRemovalListeners();
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
    query.addTerm('deleted', '=', 0);
    query.join('categoryName');
    query.join('unfilledDependencies');
    query.join('service');
    let data = await query.execute();
    
    if(Object.keys(data).length == 0) {
        alert('No records available for this step.');
        return;
    }

    // prep data for column customization
    let resFieldData = await fetch(`./api/form/indicator/list?x-filterData=indicatorID,name,description,format,categoryID,categoryName`).then(res => res.json());

    // add indexes
    let fieldData = {};
    for(let i in resFieldData) {
        let indicatorID = resFieldData[i].indicatorID;
        fieldData[indicatorID] = resFieldData[i];
    }
    
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
        query.addTerm('deleted', '=', 0);
        query.join('categoryName');
        query.join('unfilledDependencies');
        query.join('service');

        let indicatorList = indicatorIDs.split('-');
        indicatorList.forEach(colID => {
            if(Number.isFinite(+colID)) {
                query.getData(colID);
            }

            customColumns.push(colID);

            let newHeader = getDataHeader(colID, fieldData, null);
            headers = grid.headers();
            headers.splice(headers.length, 0, newHeader);
            grid.setHeaders(headers);
        });

        data = await query.execute();
        grid.setDataBlob(data);
        grid.renderBody();
        initColRemovalListeners();
    }
    else {
        grid.renderBody();
    }    

    // add options for column customization
    let unabridgedCategories = {}; // categories including internal use and stapled forms
    for(let i in data) {
        if(data[i].categoryIDs == undefined) {
            continue;
        }
        data[i].categoryIDs.forEach(category => {
            unabridgedCategories[category] = true;
        });
    }

    let fields = [];
    let fieldsByForm = {};
    for(let i in fieldData) {
        if(fieldData[i].format != '') {
            if(fieldsByForm[fieldData[i].categoryName] == undefined) {
                fieldsByForm[fieldData[i].categoryName] = [];
            }
            fieldData[i].name = fieldData[i].description == '' ? fieldData[i].name : fieldData[i].description;
            fieldData[i].name = scrubHTML(fieldData[i].name);
            fieldsByForm[fieldData[i].categoryName].push(fieldData[i]);
        }
    }

    // sort fields alphabetically
    let collator = new Intl.Collator('en', {numeric: true, sensitivity: 'base'});
    for(let i in fieldsByForm) {
        fieldsByForm[i].sort((a, b) => collator.compare(a.name, b.name));
    }
    let sortedForms = Object.keys(fieldsByForm).sort((a, b) => collator.compare(a, b));

    let columnsHTML = '<option value="service">Service</option>';
    sortedForms.forEach(form => {
        let hasFields = false;
        let temp = '';

        temp = `<optgroup label="${form}">`;
        fieldsByForm[form].forEach(field => {
            // skip non-applicable fields
            if(unabridgedCategories[field.categoryID] == undefined) {
                return;
            }
            hasFields = true;
            temp += `<option value="${field.indicatorID}">${field.name}</option>`;
        });
        temp += `</optgroup>`;

        if(hasFields) {
            columnsHTML += temp;
        }
    });
    document.querySelector('#fieldNames').innerHTML = columnsHTML;

    document.querySelector('#btn_addColumn').addEventListener('click', async () => {
        let colID = document.querySelector('#fieldNames').value;

        // prevent duplicate columns
        if(customColumns.indexOf(colID) != -1) {
            return;
        }
        customColumns.push(colID);

        let newHeader = getDataHeader(colID, fieldData);

        headers = grid.headers();
        headers.splice(headers.length, 0, newHeader);
        grid.setHeaders(headers);

        var query = new LeafFormQuery();
        query.addTerm('stepID', '=', stepID);
        query.addTerm('deleted', '=', 0);
        query.join('categoryName');
        query.join('unfilledDependencies');
        query.join('service');
        customColumns.forEach(col => {
            if(Number.isFinite(+col)) {
                query.getData(col);
            }
        });
        let data = await query.execute();

        if(dependencyID != null) {
            // If the step includes multiple requirements, filter out dependencyIDs that don't match
            let filteredData = {};
            for(let i in data) {
                if(data[i].unfilledDependencyData[dependencyID] != undefined) {
                    filteredData[i] = data[i];
                }
            }
            grid.setDataBlob(filteredData);
        } else {
            grid.setDataBlob(data);
        }

        grid.renderBody();
        updateUrlColumnState(customColumns);

        initColRemovalListeners();
    });

    document.querySelector('#btn_prepareProposal').addEventListener('click', () => {
        prepareProposal(stepInfo.stepTitle, actions, dependencyID, fieldData);
    });
}

function prepareProposal(stepTitle, actions, dependencyID, fieldData) {
    let numDecisions = 0;
    let decisions = {};
    let comments = {};

    const url = new URL(location);

    let cleanActions = [];
    
    // encode proposal
    if(dependencyID == null) {
        alert('Please select a role.');
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
            if(id == 'service') {
                fieldData['service'] = {};
                fieldData['service'][1] = {};
                fieldData['service'][1].description = 'Service';
                fieldData['service'][1].description = '';
                fieldData['service'][1].format = 'text';
            }
            let fieldName = fieldData[id].description == '' ? fieldData[id].name : fieldData[id].description;
            fieldName = scrubHTML(fieldName);
            proposal.indicatorIDs.push({
                indicatorID: id,
                name: fieldName,
                format: fieldData[id].format
            });
        });
    }
    proposal.title = stepTitle;
    proposal.description = '';
    let proposalParam = LZString.compressToBase64(JSON.stringify(proposal));;

    let newUrl = window.location.href.substring(0, window.location.href.indexOf('&'));
    newUrl += `&inbox=${encodeURIComponent(proposalParam)}`;

    let output = `<h1></h1>
        <p>Quick Review Link:</p><p><textarea aria-label="Quick Review Link" id="link" style="width: 95%; height: 5rem"/>${newUrl}</textarea></p>
        <button id="btn_copy" class="buttonNorm">Copy to Clipboard</button><span id="copyStatus"></span>`;

    let dialog = new dialogController('genericDialog', 'genericDialogxhr', 'genericDialogloadIndicator', 'genericDialogbutton_save', 'genericDialogbutton_cancelchange');
    dialog.setContent(output);
    dialog.setTitle('Quick Review Link');
    dialog.show();

    document.querySelector('#link').addEventListener('click', () => {
        document.execCommand("selectAll", false, null);
    });

    document.querySelector('#btn_copy').addEventListener('click', () => {
        navigator.clipboard.writeText(document.querySelector('#link').value);
        $("#copyStatus").show().text("Copied!");
        $("#copyStatus").fadeOut(3000);
    });
}

async function showProposal(encodedProposal) {
    document.querySelector('#proposal').style.display = 'block';

    let proposal = LZString.decompressFromBase64(encodedProposal);
    proposal = JSON.parse(proposal);
    
    document.querySelector('#reviewTitle').innerText = proposal.title;
    document.querySelector('#reviewDescription').innerText = proposal.description;

    let stepInfo = await fetch(`api/workflow/step/${proposal.stepID}`).then(res => res.json());

    let [routeInfo, activeCategoryData] = await Promise.all([
        fetch(`api/workflow/${stepInfo.workflowID}/route`).then(res => res.json()),
        fetch('api/formStack/categoryList').then(res => res.json())
    ]);

    let activeCategories = {};
    // need this to provide a cleaner view (e.g. avoid showing names of stapled forms)
    activeCategoryData.forEach(cat => {
        activeCategories[cat.categoryID] = cat;
    });

    let actionText = {};
    routeInfo.forEach(route => {
    	if(route.stepID == proposal.stepID) {
            actionText[route.actionType] = route.actionText;
        }
    });

    let query = new LeafFormQuery();
    query.addTerm('stepID', '=', proposal.stepID);
    query.addTerm('deleted', '=', 0);
    query.join('categoryName');
    query.join('unfilledDependencies');
    query.join('service');
    proposal.indicatorIDs.forEach(indicator => {
        if(Number.isFinite(+indicator.indicatorID)) {
            query.getData(indicator.indicatorID);
        }
    });
    let data = await query.execute();

    // If the step includes multiple requirements, filter out dependencyIDs that don't match
    for(let i in data) {
        if(data[i].unfilledDependencyData[proposal.dependencyID] == undefined) {
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
        {name: 'Action', indicatorID: 'decision', editable: false, callback: function(data, blob) {
            let htmlActions = `<select aria-label="Action for record # ${data.recordID}" class="recordDecision" data-record-id="${data.recordID}" style="text-align: center">`;
            htmlActions += '<option value=""></option>';
            Object.keys(actionText).forEach(actionType => {
                htmlActions += `<option value="${actionType}">${actionText[actionType]}</option>`;
            });
            htmlActions += '</select>';

            let proposedAction = actionText[proposal.decisions[data.recordID]];
            document.querySelector(`#${data.cellContainerID}`).style.backgroundColor = '#fee685';
            
            document.querySelector(`#${data.cellContainerID}`).innerHTML = htmlActions;
        }},
        {name: 'Comments', indicatorID: 'comments', editable: false, callback: function(data, blob) {
            document.querySelector(`#${data.cellContainerID}`).style.backgroundColor = '#e0e0e0';
            let comment = `<textarea class="recordComment" aria-label="Comment for record # ${data.recordID}" data-record-id="${data.recordID}">${scrubHTML(proposal.comments[data.recordID])}</textarea>`;
            document.querySelector(`#${data.cellContainerID}`).innerHTML = comment;
        }},
    ];

    proposal.indicatorIDs.forEach(indicator => {
        let newHeader = getDataHeader(indicator.indicatorID, null, indicator, true);
        headers.splice(headers.length - 2, 0, newHeader);
    });

    grid.setHeaders(headers);
    grid.renderBody();

    document.querySelector('#' + grid.getPrefixID() + 'header_decision').style.minWidth = '10rem';

    document.querySelector('#btn_approveProposal').addEventListener('click', async () => {
        let confirm_dialog = new dialogController('confirm_xhrDialog', 'confirm_xhr', 'confirm_loadIndicator', 'confirm_button_save', 'confirm_button_cancelchange');
        confirm_dialog.setContent('<img src="dynicons/?img=application-certificate.svg&amp;w=48" alt="" style="float: left; padding-right: 16px" /> <span style="font-size: 150%">Please confirm your actions.</span>');
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

            document.querySelectorAll('.recordDecision').forEach(decision => {
                let recordID = decision.getAttribute('data-record-id');
                if(decision.value == '') {
                    delete proposal.decisions[recordID];
                } else {
                    proposal.decisions[recordID] = decision.value;
                }
            });

            let errors = [];
            let queue = new intervalQueue();
            queue.setQueue(Object.keys(proposal.decisions));
            queue.setWorker(item => {
                let comment = '';
                if(comments[item] != undefined && comments[item] != '') {
                    comment = comments[item].trim();
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
                }).then(res => {
                    if(res.status != 200) {
                        errors.push(item);
                    }
                });
            });
            await queue.start();

            document.querySelector('#btn_approveProposal').style.display = 'none';
            if(errors.length == 0) {
                document.querySelector('#confirmProgress').innerHTML = '<br /><br /><img src="dynicons/?img=gnome-emblem-default.svg&w=48" alt="" style="vertical-align: middle"> All actions have been successfully applied.';
            } else {
                let errText = 'Error applying actions. Please review these individually:<br /><ul>';
                errors.forEach(err => {
                    errText += `<li><a href="index.php?a=printview&recordID=${err}" target="_blank">${err}</a> - Proposed action: ${actionText[proposal.decisions[err]]}</li>`;
                });
                errText += '</ul>';
                confirm_dialog.setContent(errText);
                confirm_dialog.hideButtons();
            }
        });
        confirm_dialog.show();
    });
}

async function main() {
    document.querySelector('title').innerText = 'Quick Review';

    const urlParams = new URLSearchParams(window.location.search);
    let stepID = urlParams.get('stepID');
    let proposal = urlParams.get('inbox');

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
<div id="setup" style="display: none" class="card">
    <h1>Create Quick Review Page</h1>
    <p>The Quick Review page contains a list of records ready for review. The actions can be applied all at once.</p>
    <p>The provided URL may be bookmarked or placed on the homepage.</p>

    <br /><br />
    <div class="card">
        <label>Select a form type:
            <select id="forms">Loading...</select>
        </label>
    </div>
    <div id="setupP2" class="card" style="display: none">
        <label>Select a step:
            <select id="steps">Loading...</select>
        </label>
        <br /><br />

        <button id="create" class="buttonNorm">Setup Quick Review</button>
        <br /><br />
    </div>
</div>
<div id="setupProposals" style="display: none" class="card">
    <h1>Create Quick Review Page<span id="stepName">Loading...</span></h1>
    <ul class="input">
        <li id="selectDependency" style="display: none"></li>
    </ul>
    <h2>Customize Columns</h2>
    <p>Data columns may be added to provide relevant information during final review.</p>
    <ul>
        <li>
            <label>Field Name:
                <select id="fieldNames"></select>
            </label>
            <button id="btn_addColumn" class="buttonNorm">Add Column</button>
        </li>
    </ul>
    <div id="proposalGrid" style="margin-bottom: 3rem">Loading...</div>
    <button id="btn_prepareProposal" class="buttonNorm" style="position: fixed; bottom: 14px; margin: auto; left: 0; right: 0; font-size: 140%; height: 52px; padding-top: 8px; padding-bottom: 4px; width: 70%; margin: auto; text-align: center; box-shadow: 0 0 20px black"><img src="dynicons/?img=x-office-spreadsheet-template.svg&w=32" alt="" /> Create Quick Review Page</button>
</div>
<div id="proposal" style="display: none">
    <h1 style="text-align: center">Records pending <span id="reviewTitle">Loading...</span></h1>
    <p id="reviewDescription" style="margin: auto; width: 40vw; margin-bottom: 2rem">...</p>
    <div id="proposalStatus" style="text-align: center; margin: 2rem">
        <button id="btn_approveProposal" class="buttonNorm" style="font-size: 14pt; padding: 8px"><img src="dynicons/?img=gnome-emblem-default.svg&w=32" alt=""> Apply Actions</button>
    </div>
    <div style="display: flex; justify-content: center; align-items: center">
        <div id="grid" style="margin-bottom: 3rem; margin: auto; min-width: 0">Loading...</div>
    </div>
</div>

<div id="genericDialog" style="visibility: hidden; display: none">
    <div>
        <div id="genericDialogbutton_cancelchange" style="display: none"></div>
        <div id="genericDialogbutton_save" style="display: none"></div>
        <div id="genericDialogloadIndicator" style="visibility: hidden; z-index: 9000; position: absolute; text-align: center; font-size: 24px; font-weight: bold; background-color: #f2f5f7; padding: 16px; height: 400px; width: 526px"><img src="images/largespinner.gif" alt="" /></div>
        <div id="genericDialogxhr" style="min-width: 540px; min-height: 420px; padding: 8px; overflow: auto; font-size: 12px"></div>
    </div>
</div>

<div id="confirm_xhrDialog" style="background-color: #feffd1; border: 1px solid black; visibility: hidden; display: none">
    <form id="confirm_record" enctype="multipart/form-data" action="javascript:void(0);">
        <div>
            <div id="confirm_loadIndicator" style="visibility: hidden; position: absolute; text-align: center; font-size: 24px; font-weight: bold; background: white; padding: 16px; height: 100px; width: 360px">Loading... <img src="images/largespinner.gif" alt="" /></div>
            <div id="confirm_xhr" style="font-size: 130%; width: 400px; height: 120px; padding: 16px; overflow: auto"></div>
            <div style="position: absolute; left: 10px; font-size: 140%"><button type="button" class="buttonNorm" id="confirm_button_cancelchange" disabled><img src="dynicons/?img=edit-undo.svg&amp;w=32" alt="" /> Cancel</button></div>
            <div style="text-align: right; padding-right: 6px"><button type="button" class="buttonNorm" id="confirm_button_save" disabled><img src="dynicons/?img=dialog-apply.svg&amp;w=32" alt="" /><span id="confirm_saveBtnText"> Confirm Actions</span></button></div><br />
        </div>
    </form>
</div>
