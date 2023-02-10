<style>
body {
    min-width: fit-content;

}
h2, h3 {
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
}
main {
    padding: 1rem;
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
    font-size: 1rem;
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
    line-height: 1.4;
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
    padding: 0.75rem;
    background-color: white;
    border-radius: 2px;
}
#queue_completed {
    color: #085;
}
div [id^="LeafFormGrid"] {
    max-width: 900px;
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
#employeeSelector div[id$="_border"], #newEmployeeSelector div[id$="_border"] {
    height: 30px;
}
.card:first-child {
    margin-right: 10px;
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
<!-- importing this here, there are otherwise override issues -->
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
                <h2 style="margin-top: 0;">Old Account</h2>
                <div id="employeeSelector"></div>
            </div>
            <div class="card">
                <h2 style="margin-top: 0;">New Account</h2>
                <div id="newEmployeeSelector"></div>
            </div>
        </div>
        <button class="buttonNorm" id="run">Preview Changes</button>
    </div>
    <div id="section2" style="display: none">
        <p>The old account you have selected is "<span id="oldAccountName" style="font-weight: bold"></span>".</p>
        <p>The new account you have selected is "<span id="newAccountName" style="font-weight: bold"></span>".</p>
        <p>Please review the results below. &nbsp;Activate the button to update them to reflect the new account.</p>
        <br />
        <div style="display:flex; margin-bottom:3rem;">
            <button class="buttonNorm" id="reassign" style="margin-right: 1rem">Update These Records</button>
            <button class="buttonNorm" id="reset">Start Over</button>
        </div>

        <h3>Requests created by the old account</h3>
        <div id="grid_initiator" class="grid_table"></div>
        
        <div style="display:flex; align-items:center; justify-content: space-between">
            <h3>Orgchart Employee fields containing the old account</h3>
            <label for="confirm_indicator_updates">Select All Requests
                <input type="checkbox" id="confirm_indicator_updates" onclick="checkAll(event)"/>
            </label>
        </div>
        <div id="grid_orgchart_employee" class="grid_table"></div>

        <div style="display:flex; align-items:center; justify-content: space-between">
            <h3>Groups for Old Account</h3>
            <label for="confirm_group_updates">Select All Groups
                <input type="checkbox" id="confirm_group_updates" onclick="checkAll(event)"/>
            </label>
        </div>
        <div id="grid_groups_info" class="grid_table"></div>

        <div style="display:flex; align-items:center; justify-content: space-between"">
            <h3>Positions for Old Account</h3>
            <label for="confirm_position_updates">Select All Positions
                <input type="checkbox" id="confirm_position_updates" onclick="checkAll(event)" />
            </label>
        </div>
        <div id=grid_positions_info class="grid_table"></div>
    </div>
    <div id="section3" style="display: none">
        <div id="initiators_updated" class="updates_output">
            <p><b>Initiator Updates</b></p>
        </div>
        <div id="orgchart_employee_updated" class="updates_output">
            <p><b>Orgchart Employee Field Updates</b></p>
        </div>
        <div id="groups_updated" class="updates_output">
            <p><b>Group Updates</b></p>
        </div>
        <div id="positions_updated" class="updates_output">
            <p><b>Positions Updates</b></p>
        </div>
        <div id="errors_updated" class="updates_output">
            <p><b>Processing Errors</b></p>
        </div>
        <div id="queue_completed" style="display: none"><b>Updates Complete</b></div>
    </div>
</main>


<script>
const CSRFToken = '<!--{$CSRFToken}-->';
const APIroot = '<!--{$APIroot}-->';
const orgchartPath = '<!--{$orgchartPath}-->';

let groupUpdatesFound = false;

function checkAll(event = {}) {
    const target = event?.currentTarget || null;
    const id = target?.id || '';
    if (id !== '') {
        const checkboxChecked = target.checked === true;
        const checkboxes = Array.from(document.querySelectorAll(`input[id^="${id}"]`));
        checkboxes.forEach(cb => cb.checked = checkboxChecked)
    }
}
function checkOne(event = {}, type = '') {
    const target = event?.currentTarget || null;
    const id = target?.id || '';
    if (id !== '' && type !== '' && target?.checked === false) {
        const primary = document.getElementById(`confirm_${type}_updates`);
        if (primary) primary.checked = false;
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
    document.getElementById('reassign').removeEventListener('click', startQueueListener);

    document.getElementById('oldAccountName').innerHTML = '';
    document.getElementById('newAccountName').innerHTML = '';

    document.getElementById('grid_initiator').innerHTML = '';
    document.getElementById('grid_orgchart_employee').innerHTML = '';
    document.getElementById('grid_groups_info').innerHTML = '';
    document.getElementById('grid_positions_info').innerHTML = '';

    document.getElementById('section1').style.display = 'block';
    document.getElementById('section2').style.display = 'none';
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
        }).then((res) => {
            const textEl = createTextElement(`Request #${recordID} reassigned to ${newAccount}`);
            document.querySelector('#section3 #initiators_updated')?.appendChild(textEl);
            resolve('updated')
        }).catch(err => {
            console.log('error assigning initiator', err);
            reject(err);
        });
    });
}

function updateOrgEmployeeData(item) {
    return new Promise ((resolve, reject) => {
        const { recordID, indicatorID, newEmpUID, newAccount } = item;

        const elConfirm = document.getElementById(`confirm_indicator_updates_${recordID}_${indicatorID}`);
        if (elConfirm.checked !== true) {
            console.log('skipping rec ind', recordID, indicatorID);
            resolve('updated');
            return;
        };

        let formData = new FormData();
        formData.append('CSRFToken', CSRFToken);
        formData.append(`${indicatorID}`, newEmpUID);
        
        fetch(`${APIroot}form/${recordID}`, {
            method: 'POST',
            body: formData
        }).then(() => {
            const textEl = createTextElement(`Request #${recordID}, indicator ${indicatorID} reassigned to ${newAccount}(${newEmpUID})`);
            document.querySelector('#section3 #orgchart_employee_updated')?.appendChild(textEl);
            resolve('updated');
        }).catch(err => {
            console.log('error updating form field', err);
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
                const selectedAccountGroups = data.filter(g => g.members.some(m => m.userName === oldAccount &&
                        (parseInt(m.locallyManaged) === 1 || m.regionallyManaged === true)));

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
                    groupUpdatesFound = true; //global declared @ ~148
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
                            callback: function(data, blob) {
                                const k = `group_${data.recordID}`;
                                const isLocal = parseInt(groupInfo[k].oldMemberSettings.locallyManaged) === 1;
                                const isRegional = groupInfo[k].oldMemberSettings.regionallyManaged === true;

                                const displayName = `${groupInfo[k].oldMemberSettings.lastName}, ${groupInfo[k].oldMemberSettings.firstName}`;
                                const username = `${groupInfo[k].oldMemberSettings.userName}`;

                                const localText =  isLocal ? ' (local)' : '';
                                const regionalText =  isRegional ? ' (nexus)' : '';

                                let htmlContent = `<div>${displayName}</div>`;
                                htmlContent += `<div style="white-space: nowrap;">${username}${localText}${regionalText}</div>`;
                                document.getElementById(data.cellContainerID).innerHTML = htmlContent;
                            }
                        },
                        {
                            name: 'New Account Status (if existing)',
                            indicatorID: 'newAccountStatus',
                            editable: false,
                            callback: function(data, blob) {
                                const k = `group_${data.recordID}`;
                                let htmlContent = `Select to Assign`;
                                if (blob[k].newAccountExistsInGroup === true) {
                                    const isLocal = parseInt(blob[k].newMemberSettings.locallyManaged) === 1;
                                    const isRegional = blob[k].newMemberSettings.regionallyManaged === true;

                                    const displayName = `${blob[k].newMemberSettings.lastName}, ${blob[k].newMemberSettings.firstName}`;
                                    const username = `${blob[k].newMemberSettings.userName}`;

                                    const localText =  isLocal ? ' (local)' : '';
                                    const regionalText =  isRegional ? ' (nexus)' : '';

                                    htmlContent = `<div>${displayName}</div>`;
                                    htmlContent += `<div style="white-space: nowrap;">${username}${localText}${regionalText}</div>`;
                                }
                                document.getElementById(data.cellContainerID).innerHTML = htmlContent;
                            }
                        },
                        {
                            name: 'Group Selections',
                            indicatorID: 'addToGroupOptions',
                            editable: false,
                            callback: function(data, blob) {
                                const containerEl = document.getElementById(data.cellContainerID);
                                const k = `group_${data.recordID}`;
                                const elInput = `<label for="confirm_group_updates_${k}">Select
                                        <input type="checkbox" id="confirm_group_updates_${k}" onclick="checkOne(event, 'group')" />
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
                    document.getElementById('grid_groups_info').appendChild(textEl);
                    resolve(groupInfo);
                }

        }).catch(err => {
            console.log(err);
            reject(err);
        });
    });
}

function searchPositionsOldAccount(accountAndTaskInfo, queue) {
    const { oldAccount, newAccount } = accountAndTaskInfo;
    return new Promise ((resolve, reject) => {
        fetch(`${orgchartPath}/api/position/search?noLimit=1`)  //q=username:${oldAccount}&employeeSearch=1  only gets 1
            .then(res => res.json())
            .then(data => {
                let positionInfo = {};
                const userPositions = data.filter(p => p.employeeList.some(emp => emp.userName === oldAccount));

                if (userPositions.length > 0) {
                    groupUpdatesFound = true; //global declared @ ~148
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
                            callback: function(data, blob) {
                                const k = `position_${data.recordID}`;
                                const empInfo = blob[k].employeeList.find(emp => emp.userName === oldAccount);
                                const displayName = `${empInfo.lastName}, ${empInfo.firstName}`;
                                const htmlContent = `<div>${displayName}${parseInt(empInfo.isActing) === 1 ? ' (Acting)' : ''}</div><div>${oldAccount}</div>`;
                                document.getElementById(data.cellContainerID).innerHTML = htmlContent;
                            }
                        },
                        {
                            name: 'New Account Status (if existing)',
                            indicatorID: 'newAccountStatus',
                            editable: false,
                            callback: function(data, blob) {
                                const k = `position_${data.recordID}`;
                                let htmlContent = `Select to Assign`;
                                if (blob[k].newAccountExistsForPosition === true) {
                                    const empInfo = blob[k].employeeList.find(emp => emp.userName === newAccount);
                                    const displayName = `${empInfo.lastName}, ${empInfo.firstName}`;
                                    htmlContent = `<div>${displayName}${parseInt(empInfo.isActing) === 1 ? ' (Acting)' : ''}</div><div>${newAccount}</div>`;
                                }
                                document.getElementById(data.cellContainerID).innerHTML = htmlContent;
                            }
                        },
                        {
                            name: 'Position Selections',
                            indicatorID: 'addToPositionOptions',
                            editable: false,
                            callback: function(data, blob) {
                                const k = `position_${data.recordID}`;
                                const elInput = `<label for="confirm_position_updates_${k}">Select
                                    <input type="checkbox" id="confirm_position_updates_${k}" onclick="checkOne(event, 'position')" />
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
                    document.getElementById('grid_positions_info').appendChild(textEl);
                    resolve(positionInfo);
                }

        }).catch(err => {
            console.log(err);
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
                        document.querySelector('#section3 #groups_updated').appendChild(textEl);
                        processedGroupUpdates += 1;
                        if (processedGroupUpdates === totalUserGroupUpdates) {
                            resolve('updated');
                        }
                    });

                } else {
                    const text = `Error adding ${newAccount} to ${item.groupName} (portal)`;
                    const textEl = createTextElement(text);
                    document.querySelector('#section3 #errors_updated').appendChild(textEl);

                    const err = new Error(text);
                    reject(err)
                }

            }).catch(err => {
                console.log(`error adding local user ${newAccount} to group ${userAccountGroupID}`, err);
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
                        document.querySelector('#section3 #groups_updated').appendChild(textEl);
                        processedGroupUpdates += 1;
                        if (processedGroupUpdates === totalUserGroupUpdates) {
                            resolve('updated')
                        }
                    });

                } else {
                    const text = `Error adding ${newAccount} to ${item.groupName} (nexus)`;
                    const textEl = createTextElement(text);
                    document.querySelector('#section3 #errors_updated').appendChild(textEl);

                    const err = new Error(text);
                    reject(err)
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
                    document.querySelector('#section3 #positions_updated').appendChild(textEl);
                    resolve('updated');
                })

            } else {
                const err = new Error(`error adding employee ${newEmpUID} to position ${userAccountPositionID}`);
                console.log(res, err);
                reject(err);
            }

        }).catch(err => {
            console.log(`error adding employee ${newEmpUID} to position ${userAccountPositionID}`, err);
            reject(err);
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
                    console.log(`error removing account ${oldAccount} from portal group ${userAccountGroupID}`, err);
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
                    console.log(`error removing account ${oldAccount} from nexus group ${userAccountGroupID}`, err);
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
            regionallyManaged: res[recordID]?.oldMemberSettings?.regionallyManaged,
            newAccountExistsInGroup: res[recordID]?.newAccountExistsInGroup,
            newAccountExistsForPosition: res[recordID]?.newAccountExistsForPosition
        }
        queue.push(item);
        count += 1;
    }
    console.log(`queued ${count} task${count > 1 ? 's' : ''}`);
}

function processTask(item) {
    switch(item.taskType) {
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
    //TODO: display name etc here
    document.getElementById('section1').style.display = 'none';
    document.getElementById('section2').style.display = 'block';
    document.getElementById('oldAccountName').innerHTML = `<a href="${orgchartPath}/?a=view_employee&empUID=${oldEmpUID}" target="_blank">${oldAccount}</a>`;
    document.getElementById('newAccountName').innerHTML = `<a href="${orgchartPath}/?a=view_employee&empUID=${newEmpUID}" target="_blank">${newAccount}</a>`;

    const queue = new intervalQueue();
    queue.setConcurrency(3);

    let calls = [];

    //TODO: initial search selections
    const queryInitiator = new LeafFormQuery();
    queryInitiator.setRootURL('../');
    queryInitiator.addTerm('userID', '=', oldAccount);
    queryInitiator.onSuccess(function(res) {
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
                    callback: function(data, blob) {
                        let containerEl = document.getElementById(data.cellContainerID);
                        containerEl.innerText = data.recordID;
                        containerEl.addEventListener('click', () => {
                            window.open(`../index.php?a=printview&recordID=${data.recordID}`, 'LEAF', 'width=800,resizable=yes,scrollbars=yes,menubar=yes');
                        });
                    }
                },
                {
                    name: 'Title',
                    indicatorID: 'requestTitle',
                    callback: function(data, blob) {
                        let containerEl = document.getElementById(data.cellContainerID);
                        containerEl.innerText = XSSHelpers.stripAllTags(blob[data.recordID].title || '');
                        containerEl.addEventListener('click', () => {
                            window.open(`../index.php?a=printview&recordID=${data.recordID}`, 'LEAF', 'width=800,resizable=yes,scrollbars=yes,menubar=yes');
                        });
                    }
                },
                {
                    name: 'Current Initiator Account',
                    indicatorID: 'initiator',
                    editable: false,
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
            document.getElementById('grid_initiator').appendChild(createTextElement('No records found'));
        }
    });
    calls.push(queryInitiator.execute());
    
    /* ******************************* ORGCHART FIELDS *********************************** */
    
    //TODO: initial search selections
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
    queryOrgchartEmployee.onSuccess(function(res) {
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
                    callback: function(data, blob) {
                        let containerEl = document.getElementById(data.cellContainerID);
                        containerEl.innerText = XSSHelpers.stripAllTags(blob[data.recordID].title || '');
                        containerEl.addEventListener('click', () => {
                            window.open(`../index.php?a=printview&recordID=${data.recordID}`, 'LEAF', 'width=800,resizable=yes,scrollbars=yes,menubar=yes');
                        });
                    }
                },
                {
                    name: 'Question to Update',
                    indicatorID: 'requestField',
                    editable: false,
                    callback: function(data, blob) {
                        document.getElementById(data.cellContainerID).innerText = `indicator ${blob[data.recordID].indicatorID}`;
                    }
                },
                {
                    name: 'Indicator Selections',
                    indicatorID: 'updateIndicatorOptions',
                    editable: false,
                    callback: function(data, blob) {
                        const containerEl = document.getElementById(data.cellContainerID);
                        const k = data.recordID;
                        const indID = blob[k].indicatorID;
                        const elInput = `<label for="confirm_indicator_updates_${k}_${indID}">Select
                                <input type="checkbox" id="confirm_indicator_updates_${k}_${indID}" onclick="checkOne(event, 'indicator')" />
                            </label>`
                        containerEl.innerHTML = elInput;
                    }
                }
            ]);
            formGrid.loadData(recordIDs);

            accountAndTaskInfo.taskType = 'update_orgchart_employee_field';
            enqueueTask(res, accountAndTaskInfo, queue);
        } else {
            document.getElementById('grid_orgchart_employee').appendChild(createTextElement('No records found'));
        }
    });
    calls.push(queryOrgchartEmployee.execute());

    /*  *************************** GROUPS AND POSITIONS ****************************** */

    //TODO: initial search selections
    calls.push(searchGroupsOldAccount(accountAndTaskInfo, queue));
    //TODO: initial search selections
    calls.push(searchPositionsOldAccount(accountAndTaskInfo, queue));

    Promise.all(calls).then((res)=> {
        queue.setWorker(item => processTask(item));

        document.getElementById('reassign').addEventListener('click', startQueueListener = (event) => {
            document.getElementById('section2').style.display = 'none';
            document.getElementById('section3').style.display = 'block';
            return queue.start().then((res) => {
                document.getElementById('queue_completed').style.display = 'block';
                if (groupUpdatesFound === true) {
                    let elDiv = document.createElement('div');
                    elDiv.innerHTML = '<h3><a href="./?a=admin_sync_services" target="_blank" class="sync_link">Sync Services</a> to implement group updates</h3>';
                    document.getElementById('section3').appendChild(elDiv);
                }
            });
        });

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