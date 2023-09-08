<style>
#access_matrix_container {
    padding: 8px;
}

#access_matrix {
    margin: auto;
    width: 80%;
}

.table td {
    font-size: 1rem;
}

button.buttonNorm {
    font-size: 1rem;
}
</style>

<div id="access_matrix_container" class="leaf-width-100pct">
    <h2>Access Matrix</h2>
    <div id="access_matrix"><img src="../images/indicator.gif" style="vertical-align: middle" /> Loading... <span id="loadingStatus"></span></div>
</div>

<!--{include file="site_elements/generic_xhrDialog.tpl"}-->
<!--{include file="site_elements/generic_confirm_xhrDialog.tpl"}-->
<script src="{$app_js_path}/LEAF/intervalQueue.js"></script>
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

async function getGroupMembers() {
    return fetch('../api/group/members')
        .then(res => res.json())
        .then(data => {
            let out = {};
            data.forEach(group => {
                out[group.groupID] = group.members;
            })
            return out;
    });
}

async function getActiveDependencies(workflows, dependencies) {
    let activeDependencies = {};
    let activeSteps = {};
    let queue = new intervalQueue();
    for(let i in workflows) {
        queue.push(workflows[i]);
    }
    queue.setWorker(item => {
        return fetch(`../api/workflow/${item.workflowID}`)
            .then(res => res.json())
            .then(data => {
                for(let i in data) {
                    activeSteps[data[i].stepID] = 1;
                }

                document.querySelector('#loadingStatus').innerHTML = `Checking workflows: ${queue.getLoaded()}/${Object.keys(workflows).length}`;
            });
    });

    await queue.start();

    queue = new intervalQueue();
    queue.setQueue(Object.keys(activeSteps));
    queue.setWorker(stepID => {
        return fetch(`../api/workflow/step/${stepID}/dependencies`)
            .then(res => res.json())
            .then(data => {
                for(let i in data) {
                    activeDependencies[data[i].dependencyID] = 1;
                }

                document.querySelector('#loadingStatus').innerHTML = `Checking requirements: ${queue.getLoaded()}/${Object.keys(activeSteps).length}`;
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
        if(document.querySelector(`#empty_${dependencyID}`) != null) {
            document.querySelector(`#empty_${dependencyID}`).style.display = 'none';
        }
        document.querySelector(`#dep${dependencyID}`)
            .insertAdjacentHTML('afterbegin', buildGroupRow(dependencyID, selectedGroupID, groups[selectedGroupID]));
        renderGroupPreview();

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

function buildGroupRow(depID, groupID, groupName) {
    return `<tr data-dep-group="${depID}_${groupID}">
                <td style="min-width: 30vw">${groupName}</td>
                <td data-group-preview="${groupID}"></td>
                <td><button class="buttonNorm" onclick="promptRemoveGroup(${depID}, ${groupID});">Remove Group</button></td>
            </tr>`;
}

function renderGroupPreview() {
    document.querySelectorAll("[data-group-preview]").forEach(elem => {
        if(groupMembers[elem.dataset.groupPreview] == undefined) {
            return;
        }
        let buf = `<span style="color: red">Empty group</span>`;
        let numMembers = groupMembers[elem.dataset.groupPreview].length;
        if(numMembers > 0) {
            let member = groupMembers[elem.dataset.groupPreview][0];
            buf = `${member.lastName}, ${member.firstName} ${member.middleName}`
        }
        if(numMembers > 1) {
            buf += ` + ${numMembers-1} others`
        }
        document.querySelectorAll(`[data-group-preview="${elem.dataset.groupPreview}"]`).forEach(prev => {
            prev.innerHTML = `<a href="?a=mod_groups">${buf}</a>`;
        });
    });
}

function renderView(dependencyGroups, activeDependencies) {
    let buf = '<table class="table"><thead><td>Task</td><td>Access List</td></thead><tbody>';
    for(let depID in activeDependencies) {
        let groupList = `<table id="dep${depID}" class="table">`;
        let numGroups = 0;
        if(dependencyGroups[depID].groups != undefined) {
            dependencyGroups[depID].groups.forEach(group => {
                groupList += buildGroupRow(depID, group.groupID, group.name);
                numGroups++;
            });
        }

        if(numGroups == 0) {
            groupList += `<tr id="empty_${depID}"><td colspan="2" style="color: red">Please add a group to this task</td></tr>`;
        }

        groupList += `<tr><td colspan="3"><button class="buttonNorm" onclick="promptAddGroup(${depID});">Add Group</button></td></tr>
                    </table>`;

        buf += `<tr>
                <td>${dependencyGroups[depID].description}</td>
                <td>${groupList}</td>
                </tr>`;
    }

    if(Object.keys(activeDependencies).length == 0) {
        buf += '<tr><td colspan="2">No tasks available for configuration</td></tr>';
    }

    buf += '</tbody></table>';

    document.querySelector('#access_matrix').innerHTML = buf;
    renderGroupPreview();
}

var dialog, dialog_confirm;
var groupMembers;
async function main() {
    dialog = new dialogController('xhrDialog', 'xhr', 'loadIndicator', 'button_save', 'button_cancelchange');
    dialog_confirm = new dialogController('confirm_xhrDialog', 'confirm_xhr', 'confirm_loadIndicator', 'confirm_button_save', 'confirm_button_cancelchange');

    document.querySelector('#loadingStatus').innerHTML = `Checking workflows.`;
    let [workflows, dependencyGroups, tGroupMembers] = await Promise.all([
        getActiveWorkflows(),
        getDependenciesAndGroups(), // Identify dependencies that have assignable groups
        getGroupMembers()
    ]);
    groupMembers = tGroupMembers;

    let activeDependencies = await getActiveDependencies(workflows, dependencyGroups);

    renderView(dependencyGroups, activeDependencies);
}

document.addEventListener('DOMContentLoaded', main);
</script>
