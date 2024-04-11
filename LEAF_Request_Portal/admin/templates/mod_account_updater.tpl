<style>
html {
    width: 100%;
}
body {
    min-width: fit-content;
}
h2, h3, h4 {
    margin: 0.5rem 0;
    color: black;
}
button.buttonNorm {
    font-size: 1rem;
    padding: 0.25rem 0.5rem;
    border-radius: 2px;
}
button.buttonNorm:focus, button.buttonNorm:active {
    border: 1px solid black !important;
}
#bodyarea {
    width: fit-content;
    margin: auto;
}
main {
    padding: 1rem;
    min-height: 100vh;
}
.sync_link {
    text-decoration: none;
    color: #049;
    font-weight: bold;
}
.grid_table {
    margin-bottom: 4rem;
}
label {
    display: flex;
    justify-content: center;
    align-items: center;
    font-family: "Source Sans Pro Web", sans-serif;
    font-size: 16px;
}
label input {
    margin-left: 0.25rem;
    cursor: pointer;
}
table th:not([id^="Vheader"]) {
    background-color: #252f3e;
    color: white;
    font-weight: normal;
    font-size: 1rem !important;
    padding: 0.25rem;
}
table.leaf_grid th, table.leaf_grid td {
    min-width: fit-content;
}
table.leaf_grid {
    table-layout: auto;
}
table.leaf_grid td {
    white-space: normal;
    vertical-align: middle;
    word-break: keep-all;
}
.updates_output {
    margin-bottom: 1.5rem;
}
.updates_output > div {
    line-height: 1.5;
    border-bottom: 1px solid #ccf;
}
.employeeSelectorName > div {
    font-weight: normal;
    padding: 2px 4px;
    margin-top: 4px;
    color: black;
    background-color: white;
    border-radius: 2px;
}
.employeeSelectorName > em {
    color: #c00;
}
#section3 {
    margin: 1rem 0;
    padding: 0.75rem;
    background-color: white;
    border-radius: 2px;
}
div [id^="LeafFormGrid"] table {
    background-color: white;
    margin: 0.5rem 0;
    width: 100%;
}
#account_input_area {
    display: flex;
}
.card {
    margin: 1rem 0;
    min-width: 400px;
    width: 50%;
    border: 1px solid rgb(44, 44, 44);
    border-radius: 3px;
    padding: 0.75rem; 
}
.card:first-child {
    margin-right: 1rem;
}
#employeeSelector div[id$="_border"], #newEmployeeSelector div[id$="_border"] {
    height: 30px;
}

@media only screen and (max-width: 600px) {
    #account_input_area {
        flex-direction: column;
    }
    .card {
        width: 90%;
    }
    .card:first-child {
        margin-right: 0;
        margin-bottom: 10px;
    }
}
</style>
<!-- importing this here, there are otherwise css override issues -->
<link rel="stylesheet" type="text/css" href="<!--{$orgchartPath}-->/css/employeeSelector.css" />

<main>
    <h2>New Account Updater</h2>
    <p style="max-width: 850px;">
    This utility will restore access for people who have been asigned a new Active Directory account.
    It can be used to update the initiator of requests created under the old account, update the content of
    orgchart employee format questions to refer to the new account, and update group memberships.
    </p>
    <h3>
        <b>Please <a href="./?a=admin_sync_services" target="_blank" class="sync_link">Sync Services</a> prior to scanning accounts.</b>
    </h3>
    <br/>

    <div id="section1">
        <div id="account_input_area">
            <div class="card">
                <h3 style="margin-top: 0;">Old Account</h3>
                <div id="employeeSelector"></div>
            </div>
            <div class="card">
                <h3 style="margin-top: 0;">New Account</h3>
                <div id="newEmployeeSelector"></div>
            </div>
        </div>
        <button class="buttonNorm" id="run">Preview Changes</button>
        <div id="reassign_reset" style="display:none; margin-bottom:3rem;">
            <h3>Review the results below and activate the button to update selections with the new account.</h3>
            <br />
            <div style="display:flex;">
                <button id="reassign" class="buttonNorm" style="margin-right: 1rem">Update Records</button>
                <button id="reset" class="buttonNorm">Start Over</button>
            </div>
        </div>
    </div>
    <div id="section2" style="display: none; margin-top: 1rem;">
        <h4>Requests created by the old account</h4>
        <div id="grid_initiator" class="grid_table"></div>
        
        <h4>Orgchart Employee fields containing the old account</h4>
        <div id="grid_orgchart_employee" class="grid_table"></div>

        <h4>Groups for Old Account</h4>
        <div id="grid_groups_info" class="grid_table"></div>

        <h4>Positions for Old Account</h4>
        <div id=grid_positions_info class="grid_table"></div>
    </div>
    <div id="section3" style="display: none">
        <p><b>Initiator Updates</b></p>
        <div id="initiators_no_updates" style="display: none;">no updates</div>
        <div id="initiators_updated" class="updates_output"></div>

        <p><b>Orgchart Employee Field Updates</b></p>
        <div id='orgchart_no_updates' style="display: none;">no updates</div>
        <div id="orgchart_employee_updated" class="updates_output"></div>

        <p><b>Group Updates</b></p>
        <div id="groups_no_updates" style="display: none;">no updates</div>
        <div id="groups_updated" class="updates_output"></div>

        <p><b>Positions Updates</b></p>
        <div id="positions_no_updates" style="display: none;">no updates</div>
        <div id="positions_updated" class="updates_output"></div>

        <p><b>Processing Errors</b></p>
        <div id="no_errors" style="display: none;">no errors</div>
        <div id="errors_updated" class="updates_output"></div>

        <div id="queue_completed" style="display: none">
            <h3 style="color: #085;">Updates Complete</h3>
            <h3><a href="./?a=admin_sync_services" target="_blank" class="sync_link">Sync Services</a> to implement any group updates</h3>
        </div>
    </div>
</main>


<script>
const CSRFToken = '<!--{$CSRFToken}-->';
const APIroot = '<!--{$APIroot}-->';
const orgchartPath = '<!--{$orgchartPath}-->';

const elGridInitiators = document.getElementById('grid_initiator');
const elGridOrgchartEmp = document.getElementById('grid_orgchart_employee');
const elGridGroups = document.getElementById('grid_groups_info');
const elGridPositions = document.getElementById('grid_positions_info');

const elInitiatorsUpdated = document.getElementById('initiators_updated');
const elOrgchartEmpUpdated = document.getElementById('orgchart_employee_updated');
const elGroupsUpdated = document.getElementById('groups_updated');
const elPositionsUpdated = document.getElementById('positions_updated');
const elErrors = document.getElementById('errors_updated');


function startQueueListener(event, queue) {
    document.getElementById('section2').style.display = 'none';
    document.getElementById('section3').style.display = 'block';
    document.getElementById('initiators_no_updates').style.display = 'none';
    document.getElementById('orgchart_no_updates').style.display = 'none';
    document.getElementById('groups_no_updates').style.display = 'none';
    document.getElementById('positions_no_updates').style.display = 'none';
    document.getElementById('no_errors').style.display = 'none';
    return queue.start().then(res => {
        document.getElementById('initiators_no_updates').style.display = Array.from(elInitiatorsUpdated.children).length === 0 ? 'block' : 'none';
        document.getElementById('orgchart_no_updates').style.display = Array.from(elOrgchartEmpUpdated.children).length === 0 ? 'block' : 'none';
        document.getElementById('groups_no_updates').style.display = Array.from(elGroupsUpdated.children).length === 0 ? 'block' : 'none';
        document.getElementById('positions_no_updates').style.display = Array.from(elPositionsUpdated.children).length === 0 ? 'block' : 'none';
        document.getElementById('no_errors').style.display = Array.from(elErrors.children).length === 0 ? 'block' : 'none';
        document.getElementById('queue_completed').style.display = 'block';
    });
}

function checkAll(event = {}) {
    const target = event?.currentTarget || null;
    const selectionString = target?.classList?.value || '';
    if (selectionString !== '') {
        const checkboxChecked = target.checked === true;
        const checkboxes = Array.from(document.querySelectorAll(`td input[id^="${selectionString}"]`));
        const headerCheckboxes = Array.from(document.querySelectorAll(`th input.${selectionString}`));
        checkboxes.forEach(cb => cb.checked = checkboxChecked);
        headerCheckboxes.forEach(cb => cb.checked = checkboxChecked);
    }
}
function checkOne(event = {}, type = '') {
    const target = event?.currentTarget || null;
    const id = target?.id || '';
    const headerCheckboxes = Array.from(document.querySelectorAll(`th input.confirm_${type}_updates`));
    const checkboxes = Array.from(document.querySelectorAll(`td input[id^="confirm_${type}_updates"]`));
    const allChecked = checkboxes.every(cb => cb.checked === true);
    if (id !== '' && type !== '') {
        headerCheckboxes.forEach(cb => cb.checked = allChecked);
    }
}

function createTextElement(textInput='', isBlockElement = true) {
    const text = XSSHelpers.stripAllTags(textInput);
    let el = document.createElement(isBlockElement ? 'div' : 'span');
    el.innerText = text;
    return el;
}

function resetEntryFields(empSel, empSelNew) {
    empSel.clearSearch();
    empSelNew.clearSearch();
    document.getElementById('run').style.display = 'block';
    
    document.getElementById('reassign_reset').style.display = 'none';
    let elReassign = document.getElementById('reassign');
    elReassign.replaceWith(elReassign.cloneNode(true));
    
    document.getElementById('section2').style.display = 'none';
    elGridInitiators.innerHTML = '';
    elGridOrgchartEmp.innerHTML = '';
    elGridGroups.innerHTML = '';
    elGridPositions.innerHTML = '';

    document.getElementById('section3').style.display = 'none';
    elInitiatorsUpdated.innerHTML = '';
    elOrgchartEmpUpdated.innerHTML = '';
    elGroupsUpdated.innerHTML = '';
    elPositionsUpdated.innerHTML = '';
    elErrors.innerHTML = '';
}
    
function reassignInitiator(item) {
    return new Promise ((resolve, reject) => {
        const { recordID, newAccount } = item;

        let formData = new FormData();
        formData.append('CSRFToken', CSRFToken);
        formData.append('initiator', newAccount);

        fetch(`${APIroot}form/${recordID}/initiator`, {
            method: 'POST',
            body: formData
        }).then(res => res.json()).then(data => {
            if (data === newAccount) {
                const textEl = createTextElement(`Request #${recordID} reassigned to ${newAccount}`);
                elInitiatorsUpdated.appendChild(textEl);
                resolve('updated');
            } else {
                const textEl = createTextElement(`Error assigning request #${recordID} to ${newAccount}`);
                elErrors.appendChild(textEl);
                reject('error');                
            }

        }).catch(err => {
            const textEl = createTextElement(`Error assigning request #${recordID} to ${newAccount}`);
            elErrors.appendChild(textEl);
            reject(err);
        });
    });
}

function updateOrgEmployeeData(item) {
    return new Promise ((resolve, reject) => {
        const { recordID, indicatorID, newEmpUID, newAccount } = item;

        const elConfirm = document.getElementById(`confirm_indicator_updates_${recordID}_${indicatorID}`);
        if (elConfirm.checked !== true) {
            resolve('updated');
            return;
        };

        let formData = new FormData();
        formData.append('CSRFToken', CSRFToken);
        formData.append(`${indicatorID}`, newEmpUID);
        
        fetch(`${APIroot}form/${recordID}`, {
            method: 'POST',
            body: formData
        }).then(res => res.json()).then(data => {
            if (parseInt(data) === 1) {
                const textEl = createTextElement(`Request #${recordID}, indicator ${indicatorID} updated to ${newAccount}(${newEmpUID})`);
                elOrgchartEmpUpdated.appendChild(textEl);
                resolve('updated');
            } else {
                const textEl = createTextElement(`Error updating request #${recordID}, indicator ${indicatorID} to ${newAccount}(${newEmpUID})`);
                elErrors.appendChild(textEl);
                reject('error');                
            }

        }).catch(err => {
            const textEl = createTextElement(`Error updating request #${recordID}, indicator ${indicatorID} to ${newAccount}(${newEmpUID})`);
            elErrors.appendChild(textEl);
            reject(err);
        });
    });
}

function searchGroupsOldAccount(accountAndTaskInfo, queue) {
    const { oldAccount, newAccount } = accountAndTaskInfo;
    return new Promise ((resolve, reject) => {
        //all groups and members
        fetch(`${APIroot}group/members/all`)
            .then(res => res.json()).then(data => {
                let groupInfo = {};
                //filter groups directly associated with old account (position handled differently)
                const selectedAccountGroups = data.filter(g => g.members.some(m => m.userName === oldAccount));

                selectedAccountGroups.forEach(g => {
                    let oldMemberSettings = g.members.find(m => m.userName === oldAccount);
                    let newMemberSettings = g.members.find(m => m.userName === newAccount && parseInt(m.active) === 1) || null;

                    if (parseInt(oldMemberSettings.active) === 1) {
                        groupInfo[`group_${g.groupID}`] = {
                            ...g,
                            oldMemberSettings,
                            newMemberSettings,
                            newAccountExistsInGroup: newMemberSettings !== null
                        };
                    }
                });

                if (Object.keys(groupInfo).length > 0) {
                    let recordIDs = '';
                    for (let i in groupInfo) {
                        recordIDs += groupInfo[i].groupID + ',';
                    }
                    const formGrid = new LeafFormGrid('grid_groups_info', {});

                    formGrid.setRootURL('../');
                    formGrid.enableToolbar();
                    formGrid.hideIndex();
                    formGrid.setDataBlob(groupInfo);
                    formGrid.setHeaders([
                        {
                            name: 'Group Name',
                            indicatorID: 'groupName',
                            sortable: false,
                            callback: function(data, blob) {
                                let containerEl = document.getElementById(data.cellContainerID);
                                containerEl.innerText = blob[`group_${data.recordID}`]?.name;
                                containerEl.addEventListener('click', () => {
                                    window.open(`${orgchartPath}/?a=view_group&groupID=${data.recordID}`, 'LEAF', 'width=800,resizable=yes,scrollbars=yes,menubar=yes');
                                });
                            }
                        },
                        {
                            name: 'Current Username',
                            indicatorID: 'groupMember',
                            editable: false,
                            sortable: false,
                            callback: function(data, blob) {
                                const k = `group_${data.recordID}`;
                                const isLocal = parseInt(groupInfo[k].oldMemberSettings.locallyManaged) === 1;
                                const isRegional = !isLocal;

                                const displayName = `${groupInfo[k].oldMemberSettings.lastName}, ${groupInfo[k].oldMemberSettings.firstName}`;
                                const username = `${groupInfo[k].oldMemberSettings.userName}`;

                                const localText =  isLocal ? ' (local)' : '';
                                const regionalText =  isRegional ? ' (nexus)' : '';

                                let htmlContent = `<div>${displayName}</div>`;
                                htmlContent += `<div style="white-space: nowrap;">${username}${localText}${regionalText}</div>`;
                                document.getElementById(data.cellContainerID).innerHTML = htmlContent;
                            }
                        },
                        {   //the input selector can't be an id because the same value will be given to the Vheader
                            name: `<label for="confirm_group_updates">Select All Groups
                                <input type="checkbox" class="confirm_group_updates" onclick="checkAll(event)" checked />
                            </label>`,
                            indicatorID: 'addToGroupOptions',
                            editable: false,
                            sortable: false,
                            callback: function(data, blob) {
                                const containerEl = document.getElementById(data.cellContainerID);
                                const k = `group_${data.recordID}`;
                                const elInput = `<label for="confirm_group_updates_${k}">Select
                                        <input type="checkbox" id="confirm_group_updates_${k}" onclick="checkOne(event, 'group')" checked />
                                    </label>`
                                containerEl.innerHTML = elInput;
                            }
                        }
                    ]);
                    formGrid.loadData(recordIDs);

                    accountAndTaskInfo.taskType = 'update_group_membership';
                    enqueueTask(groupInfo, accountAndTaskInfo, queue);
                    resolve(groupInfo);

                } else {
                    const textEl = createTextElement('No groups found');
                    elGridGroups.appendChild(textEl);
                    resolve(groupInfo);
                }

        }).catch(err => {
            console.log('error getting group list', err);
            reject(err);
        });
    });
}

function searchPositionsOldAccount(accountAndTaskInfo, queue) {
    const { oldAccount, newAccount } = accountAndTaskInfo;
    return new Promise ((resolve, reject) => {
        fetch(`${orgchartPath}/api/position/search?noLimit=1`)
            .then(res => res.json())
            .then(data => {
                let positionInfo = {};
                const userPositions = data.filter(p => p.employeeList.some(emp => emp.userName === oldAccount));

                if (userPositions.length > 0) {
                    let recordIDs = '';
                    userPositions.forEach(ele => {
                        const newAccountExistsForPosition = ele.employeeList.some(emp => emp.userName === newAccount);
                        recordIDs += ele.positionID + ',';
                        positionInfo[`position_${ele.positionID}`] = { ...ele, newAccountExistsForPosition, };
                    });
                    const formGrid = new LeafFormGrid('grid_positions_info', {});
                    formGrid.setRootURL('../');
                    formGrid.enableToolbar();
                    formGrid.hideIndex();
                    formGrid.setDataBlob(positionInfo);
                    formGrid.setHeaders([
                        {
                            name: 'Position Title',
                            indicatorID: 'positionTitle',
                            sortable: false,
                            callback: function(data, blob) {
                                let containerEl = document.getElementById(data.cellContainerID);
                                containerEl.innerText = blob[`position_${data.recordID}`]?.positionTitle || '';
                                containerEl.addEventListener('click', () => {
                                    window.open(`${orgchartPath}/?a=view_position&positionID=${data.recordID}`, 'LEAF', 'width=800,resizable=yes,scrollbars=yes,menubar=yes');
                                });
                            }
                        },
                        {
                            name: 'Current Username',
                            indicatorID: 'userName',
                            editable: false,
                            sortable: false,
                            callback: function(data, blob) {
                                const k = `position_${data.recordID}`;
                                const empInfo = blob[k].employeeList.find(emp => emp.userName === oldAccount);
                                const displayName = `${empInfo.lastName}, ${empInfo.firstName}`;
                                const htmlContent = `<div>${displayName}${parseInt(empInfo.isActing) === 1 ? ' (Acting)' : ''}</div><div>${oldAccount}</div>`;
                                document.getElementById(data.cellContainerID).innerHTML = htmlContent;
                            }
                        },
                        {
                            name: `<label for="confirm_position_updates">Select All Positions
                                <input type="checkbox" class="confirm_position_updates" onclick="checkAll(event)" checked />
                            </label>`,
                            sortable: false,
                            indicatorID: 'addToPositionOptions',
                            editable: false,
                            sortable: false,
                            callback: function(data, blob) {
                                const k = `position_${data.recordID}`;
                                const elInput = `<label for="confirm_position_updates_${k}">Select
                                    <input type="checkbox" id="confirm_position_updates_${k}" onclick="checkOne(event, 'position')" checked />
                                    </label>`
                                document.getElementById(data.cellContainerID).innerHTML = elInput;
                            }
                        }
                    ]);
                    formGrid.loadData(recordIDs);

                    accountAndTaskInfo.taskType = 'update_user_position';
                    enqueueTask(positionInfo, accountAndTaskInfo, queue);
                    resolve(positionInfo);

                } else {
                    const textEl = createTextElement('No Positions found');
                    elGridPositions.appendChild(textEl);
                    resolve(positionInfo);
                }

        }).catch(err => {
            console.log('error getting positions', err);
            reject(err);
        });
    });
}

function updateGroupAccount(item) {
    return new Promise ((resolve, reject) => {
        const { locallyManaged, regionallyManaged, userAccountGroupID,
            oldAccount, newAccount, oldEmpUID, newEmpUID } = item;

        const elConfirm = document.getElementById(`confirm_group_updates_group_${userAccountGroupID}`);
        if (elConfirm.checked !== true) {
            resolve('updated');
            return;
        };

        const totalUserGroupUpdates = +(parseInt(locallyManaged) === 1) + +(regionallyManaged === true);
        let processedGroupUpdates = 0;
        //PORTAL UPDATES
        if (parseInt(locallyManaged) === 1) {
            let formData = new FormData();
            formData.append('CSRFToken', CSRFToken);
            formData.append('userID', newAccount);

            fetch(`${APIroot}group/${userAccountGroupID}/members`, {
                method: 'POST',
                body: formData
            })
            .then(res => res.json())
            .then(data => {
                if (data === newAccount) {
                    removeFromGroup(item, 'portal').then(() => {
                        const textEl = createTextElement(`Removed ${oldAccount} and added ${newAccount} to ${item.groupName} (local)`);
                        elGroupsUpdated.appendChild(textEl);
                        processedGroupUpdates += 1;
                        if (processedGroupUpdates === totalUserGroupUpdates) {
                            resolve('updated');
                        }
                    });

                } else {
                    const textEl = createTextElement(`Error adding ${newAccount} to ${item.groupName} (portal)`);
                    elErrors.appendChild(textEl);
                    reject('error')
                }

            }).catch(err => {
                const textEl = createTextElement(`error adding local user ${newAccount} to group ${userAccountGroupID}`);
                elErrors.appendChild(textEl);
                reject(err);
            });
        }
        //NEXUS UPDATES
        if (regionallyManaged === true) {

            let formData = new FormData();
            formData.append('CSRFToken', CSRFToken);
            formData.append('empUID', newEmpUID);

            fetch(`${orgchartPath}/api/group/${userAccountGroupID}/employee`, {
                method: 'POST',
                body: formData
            })
            .then(res => res.json())
            .then(data => {
                if (parseInt(data) === parseInt(newEmpUID)) {
                    removeFromGroup(item, 'nexus').then(() => {
                        const textEl = createTextElement(`Removed ${oldAccount} and added ${newAccount} to ${item.groupName} (nexus)`);
                        elGroupsUpdated.appendChild(textEl);
                        processedGroupUpdates += 1;
                        if (processedGroupUpdates === totalUserGroupUpdates) {
                            resolve('updated')
                        }
                    });

                } else {
                    const textEl = createTextElement(`Error adding ${newAccount} to ${item.groupName} (nexus)`);
                    elErrors.appendChild(textEl);
                    reject('error')
                }

            }).catch(err => {
                console.log(err);
                reject(err);
            });
        }
    });
}

function updatePositionAccount(item) {
    return new Promise ((resolve, reject) => {
        const { newAccountExistsForPosition, userAccountPositionID, userAccountPositionIsActing,
            newEmpUID, oldEmpUID } = item;

        const elConfirm = document.getElementById(`confirm_position_updates_position_${userAccountPositionID}`);
        if (elConfirm.checked !== true) {
            resolve('updated');
            return;
        };

        let formData = new FormData();
        formData.append('CSRFToken', CSRFToken);
        formData.append('empUID', newEmpUID);
        formData.append('isActing', userAccountPositionIsActing);

        fetch(`${orgchartPath}/api/position/${userAccountPositionID}/employee`, {
            method: 'POST',
            body: formData
        })
        .then(res => res.json())
        .then(data => {
            if (parseInt(data) === parseInt(newEmpUID)) {
                removeFromPosition(item).then(() => {
                    const { oldAccount, newAccount, positionTitle } = item;
                    const acting = parseInt(userAccountPositionIsActing) === 1 ? ' (Acting)' : '';
                    const textEl = createTextElement(`Removed ${oldAccount} and added ${newAccount} to position: ${positionTitle}${acting}`);
                    elPositionsUpdated.appendChild(textEl);
                    resolve('updated');
                })

            } else {
                const textEl = createTextElement(`error adding employee ${newEmpUID} to position ${userAccountPositionID}`);
                elErrors.appendChild(textEl);
                reject('error');
            }

        }).catch(err => {
            const textEl = createTextElement(`error adding employee ${newEmpUID} to position ${userAccountPositionID}`);
            elErrors.appendChild(textEl);
            reject('error');
        });
    });
}

function removeFromGroup(taskItem, portalOrNexus = '') {
    return new Promise((resolve, reject) => {
        //RM member portal (prune)
        if (portalOrNexus === 'portal') {
            const { userAccountGroupID, oldAccount } = taskItem;
            let formData = new FormData();
            formData.append('CSRFToken', CSRFToken);

            fetch(`${APIroot}group/${userAccountGroupID}/members/_${oldAccount}/prune`, {
                    method: 'POST',
                    body: formData
                })
                .then(res => resolve(res))
                .catch(err => {
                    const textEl = createTextElement(`error removing account ${oldAccount} from portal group ${userAccountGroupID}`);
                    elErrors.appendChild(textEl);
                    reject(err);
            });

        //RM member nexus
        } else if (portalOrNexus === 'nexus') {
            const { userAccountGroupID, oldEmpUID, oldAccount } = taskItem;

            fetch(`${orgchartPath}/api/group/${userAccountGroupID}/employee/${oldEmpUID}?` +
                $.param({ CSRFToken:CSRFToken }), {
                    method: 'DELETE',
                })
                .then(res => resolve(res))
                .catch(err => {
                    const textEl = createTextElement(`error removing account ${oldAccount} from nexus group ${userAccountGroupID}`);
                    elErrors.appendChild(textEl);
                    reject(err);
            });

        } else {
            //should not happen, since method is called explicity, but this will keep promise from hanging
            console.log('member removal was not processed because locality was not specified')
            resolve();
        }
    });
}

function removeFromPosition(item) {
    const { userAccountPositionID, oldEmpUID } = item;
    return new Promise((resolve, reject) => {
        fetch(`${orgchartPath}/api/position/${userAccountPositionID}/employee/${oldEmpUID}?` +
            $.param({ CSRFToken:CSRFToken }), {
                method: 'DELETE',
            })
            .then(res => {
                resolve('updated');
            })
            .catch(err => {
                console.log(err);
                reject(err);
            })
    });
}

function enqueueTask(res = {}, accountAndTaskInfo = {}, queue = {}) {
    let count = 0;
    for(let recordID in res) {
        let isActing = null;
        if (accountAndTaskInfo.taskType === 'update_user_position') {
            const { oldAccount } = accountAndTaskInfo;
            isActing = res[recordID].employeeList.find(emp => emp.userName === oldAccount).isActing;
        }
        const item = {
            ...accountAndTaskInfo,
            recordID: /^group_/.test(recordID) ? 0 : recordID,
            groupName: res[recordID]?.name || 0,
            userAccountGroupID: /^group_/.test(recordID) ? res[recordID].groupID : 0,
            userAccountPositionID: /^position_/.test(recordID) ? res[recordID].positionID : 0,
            userAccountPositionIsActing: isActing,
            indicatorID: res[recordID]?.indicatorID || 0,
            positionTitle: res[recordID]?.positionTitle || 0,
            locallyManaged: res[recordID]?.oldMemberSettings?.locallyManaged,
            regionallyManaged: !res[recordID]?.oldMemberSettings?.locallyManaged,
            newAccountExistsInGroup: res[recordID]?.newAccountExistsInGroup,
            newAccountExistsForPosition: res[recordID]?.newAccountExistsForPosition
        }
        queue.push(item);
        count += 1;
    }
}

function processTask(item) {
    switch(item.taskType.toLowerCase()) {
        case 'update_initiator':
            return reassignInitiator(item);
            break;
        case 'update_orgchart_employee_field':
            return updateOrgEmployeeData(item);
            break;
        case 'update_group_membership':
            return updateGroupAccount(item);
            break;
        case 'update_user_position':
            return updatePositionAccount(item);
            break;
        default:
            console.log('hit default', item);
            return 'default case';
            break;
    }
}

function findAssociatedRequests(empSel, empSelNew) {
    const oldEmpUID = empSel?.selection;
    const newEmpUID = empSelNew?.selection;
    const newAccountIsEnabled = parseInt(empSelNew?.selectionData[newEmpUID]?.deleted) === 0;
    
    const oldAccount = empSel?.selectionData[oldEmpUID]?.userName || '';
    const newAccount = empSelNew?.selectionData[newEmpUID]?.userName || '';
	if(oldAccount === '' || newAccount === '' || oldAccount === newAccount || !newAccountIsEnabled) {
        alert('Invalid selections');
        return;
    }

    let accountAndTaskInfo = {
        oldAccount,
        newAccount,
        oldEmpUID,
        newEmpUID,
        taskType: ''
    }

    document.getElementById(`${empSel.prefixID}input`).value = `username_disabled:${oldAccount}`;
    document.getElementById(`${empSelNew.prefixID}input`).value = `username:${newAccount}`;

    document.getElementById('run').style.display = 'none';
    document.getElementById('section2').style.display = 'block';

    const queue = new intervalQueue();
    queue.setConcurrency(3);

    let calls = [];

    const queryInitiator = new LeafFormQuery();
    queryInitiator.setRootURL('../');
    queryInitiator.addTerm('userID', '=', oldAccount);
    queryInitiator.onSuccess(res => {
        if (res instanceof Object && Object.keys(res).length > 0) {
            let recordIDs = '';
            for (let i in res) {
                recordIDs += res[i].recordID + ',';
            }
            /*Passing empty object 2nd param prevents the formGrid from instantiating a LeafForm class. 
            The class is not needed here, and also has hardcoded references to images in libs, which causes errors*/
            const formGrid = new LeafFormGrid('grid_initiator', {});
            formGrid.setRootURL('../');
            formGrid.enableToolbar();
            formGrid.hideIndex();
            formGrid.setDataBlob(res);
            formGrid.setHeaders([
                {
                    name: 'Request UID',
                    indicatorID: 'uid',
                    sortable: false,
                    callback: function(data, blob) {
                        let containerEl = document.getElementById(data.cellContainerID);
                        containerEl.innerText = data.recordID;
                        containerEl.addEventListener('click', () => {
                            window.open(`../index.php?a=printview&recordID=${data.recordID}`, 'LEAF', 'width=800,resizable=yes,scrollbars=yes,menubar=yes');
                        });
                    }
                },
                {
                    name: 'Request Title',
                    indicatorID: 'requestTitle',
                    sortable: false,
                    callback: function(data, blob) {
                        let containerEl = document.getElementById(data.cellContainerID);
                        let title = XSSHelpers.decodeHTMLEntities(XSSHelpers.stripAllTags(blob[data.recordID].title || '[ blank ]'));
                        title = title.length < 60 ? title : title.slice(0, 60) + '...';
                        containerEl.innerText = title;
                        containerEl.addEventListener('click', () => {
                            window.open(`../index.php?a=printview&recordID=${data.recordID}`, 'LEAF', 'width=800,resizable=yes,scrollbars=yes,menubar=yes');
                        });
                    }
                },
                {
                    name: 'Current Initiator Account',
                    indicatorID: 'initiator',
                    editable: false,
                    sortable: false,
                    callback: function(data, blob) {
                        let containerEl = document.getElementById(data.cellContainerID);
                        containerEl.innerText = blob[data.recordID].userID;
                    }
                }
            ]);
            formGrid.loadData(recordIDs);

            accountAndTaskInfo.taskType = 'update_initiator';
            enqueueTask(res, accountAndTaskInfo, queue);
        } else {
            elGridInitiators.appendChild(createTextElement('No records found'));
        }
    });
    calls.push(queryInitiator.execute());
    
    /* ******************************* ORGCHART EMPLOYEE FIELDS *********************************** */
    
    const queryOrgchartEmployee = new LeafFormQuery();
    queryOrgchartEmployee.setRootURL('../');
    queryOrgchartEmployee.importQuery({
        "terms":[
            {"id":"data","indicatorID":"0.0","operator":"=","match": oldEmpUID,"gate":"AND"},
            {"id":"deleted","operator":"=","match":0,"gate":"AND"}
        ],
        "joins":["service"],
        "sort":{}
    });
    queryOrgchartEmployee.onSuccess(res => {
        if (res instanceof Object && Object.keys(res).length > 0) {
            let recordIDs = '';
            for (let i in res) {
                recordIDs += res[i].recordID + ',';
            }
            const formGrid = new LeafFormGrid('grid_orgchart_employee', {});
            formGrid.setRootURL('../');
            formGrid.enableToolbar();
            formGrid.hideIndex();
            formGrid.setDataBlob(res);
            formGrid.setHeaders([
                {
                    name: 'Request UID',
                    indicatorID: 'uid',
                    sortable: false,
                    callback: function(data, blob) {
                        let containerEl = document.getElementById(data.cellContainerID);
                        containerEl.innerText = data.recordID;
                        containerEl.addEventListener('click', () => {
                            window.open(`../index.php?a=printview&recordID=${data.recordID}`, 'LEAF', 'width=800,resizable=yes,scrollbars=yes,menubar=yes');
                        });
                    }
                },
                {
                    name: 'Request Title',
                    indicatorID: 'requestTitle',
                    sortable: false,
                    callback: function(data, blob) {
                        let containerEl = document.getElementById(data.cellContainerID);
                        let title = XSSHelpers.decodeHTMLEntities(XSSHelpers.stripAllTags(blob[data.recordID].title || '[ blank ]'));
                        title = title.length < 60 ? title : title.slice(0, 60) + '...';
                        containerEl.innerText = title;
                        containerEl.addEventListener('click', () => {
                            window.open(`../index.php?a=printview&recordID=${data.recordID}`, 'LEAF', 'width=800,resizable=yes,scrollbars=yes,menubar=yes');
                        });
                    }
                },
                {
                    name: `<label for="confirm_indicator_updates">Select All Requests
                        <input type="checkbox" class="confirm_indicator_updates" onclick="checkAll(event)" checked />
                    </label>`,
                    sortable: false,
                    indicatorID: 'updateIndicatorOptions',
                    editable: false,
                    sortable: false,
                    callback: function(data, blob) {
                        const containerEl = document.getElementById(data.cellContainerID);
                        const k = data.recordID;
                        const indID = blob[k].indicatorID;
                        const elInput = `<label for="confirm_indicator_updates_${k}_${indID}">Select
                                <input type="checkbox" id="confirm_indicator_updates_${k}_${indID}" onclick="checkOne(event, 'indicator')" checked />
                            </label>`
                        containerEl.innerHTML = elInput;
                    }
                }
            ]);
            formGrid.loadData(recordIDs);

            accountAndTaskInfo.taskType = 'update_orgchart_employee_field';
            enqueueTask(res, accountAndTaskInfo, queue);

        } else {
            elGridOrgchartEmp.appendChild(createTextElement('No records found'));
        }
    });
    calls.push(queryOrgchartEmployee.execute());

    /*  *************************** GROUPS AND POSITIONS ****************************** */

    calls.push(searchGroupsOldAccount(accountAndTaskInfo, queue));

    calls.push(searchPositionsOldAccount(accountAndTaskInfo, queue));

    Promise.all(calls).then((res)=> {
        document.getElementById('reassign_reset').style.display = 'block';
        queue.setWorker(item => processTask(item));
        document.getElementById('reassign').addEventListener('click', (event) => { startQueueListener(event, queue); });
    }).catch(err => console.log('process error', err));
}


window.addEventListener('DOMContentLoaded', (event) => {
    const empSel = new employeeSelector('employeeSelector');
    empSel.apiPath = '<!--{$orgchartPath}-->/api/';
    empSel.rootPath = '<!--{$orgchartPath}-->/';
    empSel.setResultHandler(function() {
        if(this.numResults > 0) {
            for(let i in this.selectionData) {
                const textEl = createTextElement(this.selectionData[i].userName);
                document.querySelector(`#${this.prefixID}emp${i} > .employeeSelectorName`).appendChild(textEl);
            }
        }
    });
    empSel.initialize();

    const empSelNew = new employeeSelector('newEmployeeSelector');
    empSelNew.apiPath = '<!--{$orgchartPath}-->/api/';
    empSelNew.rootPath = '<!--{$orgchartPath}-->/';
    empSelNew.setResultHandler(function() {
        if(this.numResults > 0) {
            for(let i in this.selectionData) {
                const textEl = createTextElement(this.selectionData[i].userName);
                document.querySelector(`#${this.prefixID}emp${i} > .employeeSelectorName`).appendChild(textEl);
            }
        }
    });
    empSelNew.initialize();

    document.getElementById('run').addEventListener('click', function() {
        findAssociatedRequests(empSel, empSelNew);
    });
    document.getElementById('reset').addEventListener('click', function() {
        resetEntryFields(empSel, empSelNew);
    })
});
</script>