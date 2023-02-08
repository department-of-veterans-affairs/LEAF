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
.updates_output {
    margin-bottom: 1rem;
}
.updates_output > div {
    line-height: 1.4;
    border-bottom: 1px solid #bbe;
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
    padding: 0.5rem;
    background-color: white;
}
#queue_completed {
    color: #085;
}
div [id^="LeafFormGrid"] {
    max-width: 850px;
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
    <p>
        <b>Please <a href="./?a=admin_sync_services" target="_blank" class="sync_link">Sync Services</a> prior to scanning accounts.</b>
    </p>
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
        <p>The old account you have selected is "<span id="oldAccountName" style="font-weight: bold"></span>"</p>
        <p>The new account you have selected is "<span id="newAccountName" style="font-weight: bold"></span>".</p>
        <p>Please review the results below. &nbsp;Activate the button to update them to reflect the new account.</p>
        <br />
        <div style="display:flex; margin-bottom:3rem;">
            <button class="buttonNorm" id="reassign" style="margin-right: 1rem">Update These Requests</button>
            <button class="buttonNorm" id="reset">Start Over</button>
        </div>

        <h3>Requests created by the old account</h3>
        <div id="grid_initiator" class="grid_table"></div>
        
        <h3>Orgchart Employee fields containing the old account</h3>
        <div id="grid_orgchart_employee" class="grid_table"></div>

        <div style="display:flex; align-items:center; justify-content: space-between">
            <h3>Groups for Old Account</h3>
            <label style="color:#c00;" for="confirm_group_updates">Check to confirm
                <input type="checkbox" id="confirm_group_updates" style="margin-left: 4px;"/>
            </label>
        </div>
        <div id="grid_groups_info" class="grid_table"></div>

        <div style="display:flex; align-items:center; justify-content: space-between"">
            <h3>Positions for Old Account</h3>
            <label style="color:#c00;" for="confirm_position_updates">Check to confirm
                <input type="checkbox" id="confirm_position_updates" style="margin-left: 4px;"/>
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
        <div id="queue_completed" style="display: none"><b>Updates Complete</b></div>
    </div>
</main>


<script>
const CSRFToken = '<!--{$CSRFToken}-->';
const APIroot = '<!--{$APIroot}-->';
const orgchartPath = '<!--{$orgchartPath}-->';

let groupUpdatesFound = false;

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

    document.getElementById('oldAccountName').innerText = '';
    document.getElementById('newAccountName').innerText = '';

    document.getElementById('grid_initiator').innerHTML = '';
    document.getElementById('grid_orgchart_employee').innerHTML = '';
    document.getElementById('grid_groups_info').innerHTML = '';

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

        let formData = new FormData();
        formData.append('CSRFToken', CSRFToken);
        formData.append(`${indicatorID}`, newEmpUID);
        
        fetch(`${APIroot}form/${recordID}`, {
            method: 'POST',
            body: formData
        }).then(() => {
            const textEl = createTextElement(`Request # ${recordID}, indicator ${indicatorID} reassigned to ${newAccount}(${newEmpUID})`);
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
                //filter groups directly associated with old account ( position needs to be handled differently)
                const selectedAccountGroups = data.filter(g => g.members.some(m => m.userName === oldAccount &&
                        (parseInt(m.locallyManaged) === 1 || m.regionallyManaged === true)));

                selectedAccountGroups.forEach(g => {
                    let memberSettings = g.members.find(m => m.userName === oldAccount);
                    //store info about whether the new account has already been added (if so do not try adding again)
                    memberSettings.newAccountExistsInGroup = g.members.some(m => m.userName === newAccount && parseInt(m.isActive) === 1);
                    if (parseInt(memberSettings.active) === 1) {
                        groupInfo[`group_${g.groupID}`] = {
                            ...g,
                            memberSettings
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
                            editable: false,
                            callback: function(data, blob) {
                                document.getElementById(data.cellContainerID).innerText = blob[`group_${data.recordID}`]?.name;
                            }
                        },
                        {
                            name: 'Current Group Member Username',
                            indicatorID: 'groupMember',
                            editable: false,
                            callback: function(data, blob) {
                                const k = `group_${data.recordID}`;
                                const localText = parseInt(groupInfo[k].memberSettings.locallyManaged) === 1 ? ' (local)' : '';
                                const regionalText = groupInfo[k].memberSettings.regionallyManaged === true ? ' (nexus)' : '';
                                const username = groupInfo[k].memberSettings.userName;
                                document.getElementById(data.cellContainerID).innerText = `${username}${localText}${regionalText}`;
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
                            editable: false,
                            callback: function(data, blob) {
                                document.getElementById(data.cellContainerID).innerText = blob[`position_${data.recordID}`]?.positionTitle || '';
                            }
                        },
                        {
                            name: 'Current Username',
                            indicatorID: 'userName',
                            editable: false,
                            callback: function(data, blob) {
                                document.getElementById(data.cellContainerID).innerText = oldAccount;
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
        const elConfirm = document.getElementById('confirm_group_updates');
        if (elConfirm.checked !== true) {
            resolve('updated');
            return;
        };

        const { locallyManaged, regionallyManaged, userAccountGroupID, oldAccount, newAccount, oldEmpUID, newEmpUID } = item;
        const totalUserGroupUpdates = +(parseInt(locallyManaged) === 1) + +(regionallyManaged === true);
        let processedGroupUpdates = 0;
        //PORTAL UPDATES
        if (parseInt(locallyManaged) === 1) {
            //If new account already exists and is active, just rm old
            if(item.newAccountExistsInGroup === true) {
                removeFromGroup(item, 'portal').then(res => {
                    const textEl = createTextElement(`New account already exists. Removed old account ${oldAccount} from ${userAccountGroupID} (local)`)
                    document.querySelector('#section3 #groups_updated').appendChild(textEl);
                    processedGroupUpdates += 1;
                    if (processedGroupUpdates === totalUserGroupUpdates) {
                        resolve('updated');
                    }
                });

            } else {
                let formData = new FormData();
                formData.append('CSRFToken', CSRFToken);
                formData.append('userID', newAccount);

                fetch(`${APIroot}group/${userAccountGroupID}/members`, {
                    method: 'POST',
                    body: formData
                }).then(res => {
                    removeFromGroup(item, 'portal').then(res => {
                        const textEl = createTextElement(`Removed ${oldAccount} and added ${newAccount} to ${userAccountGroupID} (local)`);
                        document.querySelector('#section3 #groups_updated').appendChild(textEl);
                        processedGroupUpdates += 1;
                        if (processedGroupUpdates === totalUserGroupUpdates) {
                            resolve('updated');
                        }
                    });

                }).catch(err => {
                    console.log(`error adding local user ${newAccount} to group ${userAccountGroupID}`, err);
                    reject(err);
                });
            }
        }
        //NEXUS UPDATES
        if (regionallyManaged === true) {
            if(item.newAccountExistsInGroup === true) {
                removeFromGroup(item, 'nexus').then(res => {
                    const textEl = createTextElement(`New account already exists. Removed old account ${oldAccount} from ${userAccountGroupID} (nexus)`);
                    document.querySelector('#section3 #groups_updated').appendChild(textEl);
                    processedGroupUpdates += 1;
                    if (processedGroupUpdates === totalUserGroupUpdates) {
                        resolve('updated');
                    }
                });

            } else {
                let formData = new FormData();
                formData.append('CSRFToken', CSRFToken);
                formData.append('empUID', newEmpUID);

                fetch(`${orgchartPath}/api/group/${userAccountGroupID}/employee`, {
                    method: 'POST',
                    body: formData
                }).then(res => {
                    removeFromGroup(item, 'nexus').then(res => {
                        const textEl = createTextElement(`Removed ${oldAccount} and added ${newAccount} to ${userAccountGroupID} (nexus)`);
                        document.querySelector('#section3 #groups_updated').appendChild(textEl);
                        processedGroupUpdates += 1;
                        if (processedGroupUpdates === totalUserGroupUpdates) {
                            resolve('updated')
                        }
                    });

                }).catch(err => {
                    console.log(err);
                    reject(err);
                });
            }
        }
    });
}

function updatePositionAccount(item) {
    return new Promise ((resolve, reject) => {
        const elConfirm = document.getElementById('confirm_position_updates');
        if (elConfirm.checked !== true) {
            resolve('updated');
            return;
        };
        console.log('task TODO position update', item);
        resolve('updated');
    });
}

function removeFromGroup(taskItem, portalOrNexus = '') {
    return new Promise((resolve, reject) => {
        //locally managed and regionally managed are not mutually exclusive, so check both individually
        //RM member portal
        if (portalOrNexus === 'portal') {
            const { userAccountGroupID, oldAccount } = taskItem;
            let formData = new FormData();
            formData.append('CSRFToken', CSRFToken);

            fetch(`${APIroot}group/${userAccountGroupID}/members/_${oldAccount}`, {
                    method: 'POST',
                    body: formData
                }).then(res => res.json()).then(data => {
                    resolve(data);
                }).catch(err => {
                    console.log(`error removing account ${oldAccount} from portal group ${userAccountGroupID}`, err);
                    reject(err);
            });
        //RM member nexus
        } else if (portalOrNexus === 'nexus') {
            const { userAccountGroupID, oldEmpUID } = taskItem;
            let formData = new FormData();
            formData.append('CSRFToken', CSRFToken);

            fetch(`${orgchartPath}/api/group/${userAccountGroupID}/employee/${oldEmpUID}?` +
                $.param({ CSRFToken:CSRFToken }), {
                    method: 'DELETE',
                }).then(res => res.json()).then(data => {
                    resolve(data);
                }).catch(err => {
                    console.log(`error removing account ${oldAccount} from nexus group ${userAccountGroupID}`, err);
                    reject(err);
            });

        } else {
            //this should not happen, since this method is called explicity, but this will keep promise from hanging
            console.log('member removal was not processed because locality was not specified')
            resolve();
        }
    });
}

function enqueueTask(res = {}, accountAndTaskInfo = {}, queue = {}) {
    let count = 0;
    for(let recordID in res) {
        const item = {
            ...accountAndTaskInfo,
            recordID: /^group_/.test(recordID) ? 0 : recordID,
            userAccountGroupID: /^group_/.test(recordID) ? res[recordID].groupID : 0,
            indicatorID: res[recordID]?.indicatorID || 0,
            locallyManaged: res[recordID]?.memberSettings?.locallyManaged,
            regionallyManaged: res[recordID]?.memberSettings?.regionallyManaged,
            newAccountExistsInGroup: res[recordID]?.memberSettings?.newAccountExistsInGroup,
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

    document.getElementById('section1').style.display = 'none';
    document.getElementById('section2').style.display = 'block';
    document.getElementById('oldAccountName').innerText = oldAccount;
    document.getElementById('newAccountName').innerText = newAccount;

    const queue = new intervalQueue();
    queue.setConcurrency(3);

    let calls = [];

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
                    name: 'UID',
                    indicatorID: 'uid',
                    editable: false,
                    callback: function(data, blob) {
                        const link = `<a href="../index.php?a=printview&recordID=${data.recordID}" target="_blank">${data.recordID}</a>`
                        $('#'+data.cellContainerID).html(link);
                    }
                },
                {
                    name: 'Title',
                    indicatorID: 'title',
                    callback: function(data, blob) {
                        let containerEl = document.getElementById(data.cellContainerID);
                        containerEl.innerText = XSSHelpers.stripAllTags(blob[data.recordID].title || '');
                        containerEl.addEventListener('click', () => {
                            window.open('../index.php?a=printview&recordID='+data.recordID, 'LEAF', 'width=800,resizable=yes,scrollbars=yes,menubar=yes');
                        });
                    }
                },
                {
                    name: 'Current Initiator Account',
                    indicatorID: 'initiator',
                    editable: false,
                    callback: function(data, blob) {
                        document.getElementById(data.cellContainerID).innerText = blob[data.recordID].userID;
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
    
    /* *********************************************************************************** */
    
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
                    editable: false,
                    callback: function(data, blob) {
                        const link = `<a href="../index.php?a=printview&recordID=${data.recordID}" target="_blank">${data.recordID}</a>`
                        $('#'+data.cellContainerID).html(link);
                    }
                },
                {
                    name: 'Request Title',
                    indicatorID: 'title', 
                    callback: function(data, blob) {
                        let containerEl = document.getElementById(data.cellContainerID);
                        containerEl.innerText = XSSHelpers.stripAllTags(blob[data.recordID].title || '');
                        containerEl.addEventListener('click', () => {
                            window.open('../index.php?a=printview&recordID='+data.recordID, 'LEAF', 'width=800,resizable=yes,scrollbars=yes,menubar=yes');
                        });
                    }
                },
                {
                    name: 'Question to Update',
                    request: 'request',
                    editable: false,
                    callback: function(data, blob) {
                        document.getElementById(data.cellContainerID).innerText = `indicator ${blob[data.recordID].indicatorID}`;
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

    /*  ******************************************************************************* */

    calls.push(searchGroupsOldAccount(accountAndTaskInfo, queue));

    calls.push(searchPositionsOldAccount(accountAndTaskInfo, queue));

    Promise.all(calls).then((res)=> {
        queue.setWorker(item => { //queue items added in 'enqueueTask' function
            return processTask(item);
        });
        document.getElementById('reassign').addEventListener('click', startQueueListener = (event) => {
            document.getElementById('section2').style.display = 'none';
            document.getElementById('section3').style.display = 'block';
            return queue.start().then((res) => {
                let elStatus = document.getElementById('queue_completed');
                if (elStatus !== null) {
                    elStatus.style.display = 'block';
                }
                if (groupUpdatesFound === true) {
                    $('#section3').append('<a href="./?a=admin_sync_services" target="_blank" class="sync_link">Sync Services</a> to implement group updates')
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