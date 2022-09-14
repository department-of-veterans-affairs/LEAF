<style>
#access_matrix {
    margin: auto;
    width: 80%;
    border: 1px solid black;
    background-color: white;
    padding: 8px;
}

.table td {
    font-size: 1rem;
}

li {
    line-height: 2rem;
}

button.buttonNorm {
    font-size: 1rem;
}
</style>

<div class="leaf-width-100pct">
    <h2>Access Matrix</h2>
    <div id="access_matrix"><img src="../images/indicator.gif" style="vertical-align: middle" /> Loading... </div>
</div>

<!--{include file="site_elements/generic_xhrDialog.tpl"}-->
<!--{include file="site_elements/generic_confirm_xhrDialog.tpl"}-->
<script src="../../libs/js/LEAF/intervalQueue.js"></script>
<script>
var CSRFToken = '<!--{$CSRFToken}-->';

async function getActiveWorkflows() {
    return fetch('../api/formStack/categoryList/all')
        .then(res => res.json())
        .then(forms => {
            let workflows = {};
            for(let i in forms) {
                if(forms[i].disabled == 0
                    && forms[i].workflowID > 0) {
                    workflows[forms[i].workflowID] = forms[i];
                }
            }
            return workflows;
        });
}

async function getDependenciesAndGroups() {
    return fetch('../api/workflow/dependencies/groups')
        .then(res => res.json());
}

async function getActiveDependencies(workflows, dependencies) {
    let activeDependencies = {};
    let queue = new intervalQueue();
    for(let i in workflows) {
        queue.push(workflows[i]);
    }
    queue.setWorker(item => {
        return fetch(`../api/workflow/${item.workflowID}/map/summary`)
            .then(res => res.json())
            .then(data => {
                for(let i in data) {
                    if(i > 0) {
                        for(let j in data[i].dependencies) {
                            activeDependencies[j] = 1;
                        }
                    }
                }
            });
    });
    return queue.start().then(() => {
        for(let i in activeDependencies) {
            if(dependencies[i] == undefined) {
                delete activeDependencies[i];
            }
        }
        return activeDependencies;
    });
}

function promptAddGroup(dependencyID) {
    dialog.setTitle('Add a group');
    dialog.indicateBusy();

    let groups = {};
    fetch('../api/system/groups')
        .then(result => result.json())
        .then(res => {
    		let buffer = 'Grant Privileges to Group:<br /><select id="groupID">' +
                '<optgroup label="User Groups">';

            for (let i in res) {
                if (res[i].parentGroupID === null) {
                    buffer += '<option value="' + res[i].groupID + '">' + res[i].name + '</option>';
                }
                groups[res[i].groupID] = res[i].name;
            }

            buffer += '</optgroup>';
            buffer += '<optgroup label="Service Groups">';

            for (let i in res) {
                if (res[i].parentGroupID !== null) {
                    buffer += '<option value="' + res[i].groupID + '">' + res[i].name + '</option>';
                }
            }

            buffer += '</optgroup></select>';

    		dialog.setContent(buffer);
    		dialog.indicateIdle();
    });

    dialog.setSaveHandler(function() {
        let selectedGroupID = document.querySelector('#groupID').value;
        document.querySelector(`#dep${dependencyID}`).insertAdjacentHTML('afterbegin', `<li>${groups[selectedGroupID]}</li>`);

        let formData = new FormData();
        formData.append('groupID', selectedGroupID);
        formData.append('CSRFToken', CSRFToken);
        fetch(`../api/workflow/dependency/${dependencyID}/privileges`, {
            method: 'POST',
            body: formData
        }).then(() => {
            dialog.hide();
        });
    });
    dialog.show();
}

function promptRemoveGroup(dependencyID, groupID) {
	dialog_confirm.setTitle('Remove group?');
	dialog_confirm.setContent('Are you sure you want to remove this group?');

	dialog_confirm.setSaveHandler(function() {
        let params = new URLSearchParams({'groupID': groupID,
                                          'CSRFToken': CSRFToken});
        fetch(`../api/workflow/dependency/${dependencyID}/privileges?${params.toString()}`,
            {method: 'DELETE'})
            .then(() => {
                document.querySelector(`[data-dep-group="${dependencyID}_${groupID}"]`).style.display = 'none';
                dialog_confirm.hide();
            });
	});
    dialog_confirm.show();
}

function renderView(dependencyGroups, activeDependencies) {
    // TODO: show users associated with groups
    let buf = '<table class="table"><thead><td>Task</td><td>Groups with access</td></thead><tbody>';
    for(let depID in activeDependencies) {
        let groupList = `<ul id="dep${depID}">`;
        if(dependencyGroups[depID].groups != undefined) {
            dependencyGroups[depID].groups.forEach(group => {
                groupList += `<li data-dep-group="${depID}_${group.groupID}">${group.name} <button class="buttonNorm" onclick="promptRemoveGroup(${depID}, ${group.groupID});">Remove</button></li>`;
            });
        }
        groupList += `<li><button class="buttonNorm" onclick="promptAddGroup(${depID});">Add Group</button></li></ul>`;

        buf += `<tr>
                <td>${dependencyGroups[depID].description}</td>
                <td>${groupList}</td>
                </tr>`;
    }

    buf += '</tbody></table>';

    document.querySelector('#access_matrix').innerHTML = buf;
}

var dialog, dialog_confirm;
async function main() {
    dialog = new dialogController('xhrDialog', 'xhr', 'loadIndicator', 'button_save', 'button_cancelchange');
    dialog_confirm = new dialogController('confirm_xhrDialog', 'confirm_xhr', 'confirm_loadIndicator', 'confirm_button_save', 'confirm_button_cancelchange');

    let [workflows, dependencyGroups] = await Promise.all([
        getActiveWorkflows(),
        getDependenciesAndGroups()
    ]);

    let activeDependencies = await getActiveDependencies(workflows, dependencyGroups);
    
    renderView(dependencyGroups, activeDependencies);
}

document.addEventListener('DOMContentLoaded', main);
</script>
