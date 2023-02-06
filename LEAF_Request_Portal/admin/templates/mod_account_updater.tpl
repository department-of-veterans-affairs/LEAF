<style>

body {
    min-width: fit-content;
}
#bodyarea {
    width: fit-content;
    padding: 1rem;
}
.grid_table {
    margin-bottom: 3rem;
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
    min-width: 300px;
    width: 50%;
    border: 1px solid rgb(44, 44, 44);
    border-radius: 3px;
    padding: 0.75rem; 
    
}
.card:first-child {
    margin-right: 10px;
}
@media only screen and (max-width: 550px) {
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



<h2>New Account Updater</h2>
<p style="max-width: 850px;">
This utility will restore access for people who have been asigned a new Active Directory account.
It can be used to update the initiator of requests created under the old account, update the content of
orgchart employee format questions to refer to the new account, and update group memberships.
</p>
<br /><br />

<script src="<!--{$orgchartPath}-->/js/nationalEmployeeSelector.js"></script>
<script src="../../libs/js/LEAF/intervalQueue.js"></script>
<link rel="stylesheet" type="text/css" href="<!--{$orgchartPath}-->/css/employeeSelector.css" />



<script>

const CSRFToken = '<!--{$CSRFToken}-->';
const APIroot = '<!--{$APIroot}-->'
    
function reassignInitiator(item) {
    return new Promise ((resolve, reject) => {
        const { recordID, newAccount } = item;

        let formData = new FormData();
        formData.append('CSRFToken', CSRFToken);
        formData.append('initiator', newAccount);

        fetch(`${APIroot}form/${recordID}/initiator`, {
            method: 'POST',
            body: formData
        }).then(() => {
            $('#section3 #initiators_updated').append(`Request # ${recordID} reassigned to ${newAccount}<br />`);
            resolve('updated')
        }).catch(err => {
            console.log(err);
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
            $('#section3 #orgchart_employee_updated').append(`Request # ${recordID}, indicator ${indicatorID} reassigned to ${newAccount}(${newEmpUID})<br />`);
            resolve('updated')
        }).catch(err => {
            console.log(err);
            reject(err);
        });
    });
}

function searchGroupsOldAccount(accountInfo, queue) {
    const { oldAccount } = accountInfo;
    return new Promise ((resolve, reject) => {
        //all groups and members
        fetch(`${APIroot}group/members`)
            .then(res => res.json())
            .then(data => {
                let groupInfo = {};
                //groups associated with old account
                const selectedAccountGroups = data.filter(g => g.members.some(m => m.userName === oldAccount));
                selectedAccountGroups.forEach(g => {
                    const memberSettings = g.members.find(m => m.userName === oldAccount);
                    if (parseInt(memberSettings.active) === 1) {
                        groupInfo[`group_${g.groupID}`] = {
                            ...g,
                            memberSettings
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
                            editable: false,
                            callback: function(data, blob) {
                                $('#'+data.cellContainerID).html(blob[`group_${data.recordID}`]?.name);
                            }
                        },
                        {
                            name: 'Group Member Username',
                            indicatorID: 'groupMember',
                            editable: false,
                            callback: function(data, blob) {
                                $('#'+data.cellContainerID).html(blob[`group_${data.recordID}`]?.memberSettings.userName);
                            }
                        }
                    ]);
                    formGrid.loadData(recordIDs);

                    accountInfo.taskType = 'update_group_membership';
                    enqueueTask(groupInfo, accountInfo, queue);
                    resolve(groupInfo);
                } else {
                    $('#grid_initiator').append('No records found');
                }

        }).catch(err => {
            console.log(err);
            reject(err);
        });
    });
}

function addUserToGroup(item) {
    return new Promise ((resolve, reject) => {
        //TODO:

        const { locallyManaged, userAccountGroupID, newAccount } = item;
        if (parseInt(locallyManaged) === 1) {
            let formData = new FormData();
            formData.append('CSRFToken', CSRFToken);
            formData.append('userID', newAccount);

            fetch(`${APIroot}group/${userAccountGroupID}/members`, {
                method: 'POST',
                body: formData
            }).then((res) => {
                console.log('grp post res', res)
                $('#section3 #groups_updated').append(`${newAccount} added to ${userAccountGroupID}<br />`);
                resolve('updated')
            }).catch(err => {
                console.log(err);
                reject(err);
            });
        }
    });
}

function enqueueTask(res = {}, accountInfo = {}, queue = {}) {
    let count = 0;
    for(let recordID in res) {
        const item = {
            ...accountInfo,
            recordID: /^group_/.test(recordID) ? 0 : recordID,
            indicatorID: res[recordID]?.indicatorID || 0,
            userAccountGroupID: /^group_/.test(recordID) ? res[recordID].groupID : 0,
            locallyManaged: res[recordID]?.memberSettings?.locallyManaged || null,
            regionallyManaged: res[recordID]?.memberSettings?.regionallyManaged || null,
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
        case 'update_orgchart_employee_field':
            return updateOrgEmployeeData(item);
        case 'update_group_membership':
            return addUserToGroup(item);
        default:
            console.log('hit default', item);
            return 'default case';
            break;
    }
}

function findAssociatedRequests(empSel, empSelNew) {
    const oldEmpUID = empSel?.selection;
    const newEmpUID = empSelNew?.selection;

    const oldAccount = empSel?.selectionData[oldEmpUID]?.userName || '';
    const newAccount = empSelNew?.selectionData[newEmpUID]?.userName || '';
	if(oldAccount === '' || newAccount === '' || oldAccount === newAccount) {
        alert('Invalid selections');
        return;
    }

    let accountInfo = {
        oldAccount,
        newAccount,
        oldEmpUID,
        newEmpUID,
        taskType: ''
    }

    $('#section1').css('display', 'none');
    $('#section2').css('display', 'inline');
    $('#oldAccountName').html(oldAccount);
    $('#newAccountName').html(newAccount);

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
                        $('#'+data.cellContainerID).html(blob[data.recordID].title);
                        $('#'+data.cellContainerID).on('click', function() {
                            window.open('../index.php?a=printview&recordID='+data.recordID, 'LEAF', 'width=800,resizable=yes,scrollbars=yes,menubar=yes');
                        });
                }},
                {
                    name: 'Initiator Account',
                    indicatorID: 'initiator',
                    editable: false,
                    callback: function(data, blob) {
                        $('#'+data.cellContainerID).html(blob[data.recordID].userID);
                }}
            ]);
            formGrid.loadData(recordIDs);

            accountInfo.taskType = 'update_initiator';
            enqueueTask(res, accountInfo, queue);
        } else {
            $('#grid_initiator').append('No records found');
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
        "sort":{},
        "limit":10000,"limitOffset":0
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
                    name: 'UID',
                    indicatorID: 'uid',
                    editable: false,
                    callback: function(data, blob) {
                        const link = `<a href="../index.php?a=printview&recordID=${data.recordID}" target"="_blank">${data.recordID}</a>`
                        $('#'+data.cellContainerID).html(link);
                    }
                },
                {
                    name: 'Title', 
                    indicatorID: 'title', 
                    callback: function(data, blob) {
                        $('#'+data.cellContainerID).html(blob[data.recordID].title);
                        $('#'+data.cellContainerID).on('click', function() {
                            window.open('../index.php?a=printview&recordID='+data.recordID, 'LEAF', 'width=800,resizable=yes,scrollbars=yes,menubar=yes');
                    });
                }},
                {
                    name: 'Orgchart Employee Entry',
                    request: 'request',
                    editable: false,
                    callback: function(data, blob) {
                        $('#'+data.cellContainerID).html(`indicator ${blob[data.recordID].indicatorID}, empUID ${blob[data.recordID].data}`);
                }}
            ]);
            formGrid.loadData(recordIDs);

            accountInfo.taskType = 'update_orgchart_employee_field';
            enqueueTask(res, accountInfo, queue);
        } else {
            $('#grid_orgchart_employee').append('No records found');
        }
    });
    calls.push(queryOrgchartEmployee.execute());

    /*  ******************************************************************************* */
    calls.push(searchGroupsOldAccount(accountInfo, queue));



    Promise.all(calls).then((res)=> {
        queue.setWorker(item => { //queue items added in 'enqueueTask' function
            return processTask(item);
        });
        $('#reassign').on('click', function() {
            $('#section2').css('display', 'none');
            $('#section3').css('display', 'inline');
            return queue.start().then((res) => {
                console.log(res);
            });
        });

    }).catch(err => console.log(err));
}

$(function() {
    const empSel = new nationalEmployeeSelector('employeeSelector');
    empSel.apiPath = '<!--{$orgchartPath}-->/api/';
    empSel.rootPath = '<!--{$orgchartPath}-->/';
    empSel.outputStyle = 'micro';
    empSel.setResultHandler(function() {
        if(this.numResults > 0) {
            for(let i in this.selectionData) {
                $(`#${this.prefixID}emp${i} > .employeeSelectorName`).append(`<br /><span style="font-weight: normal">${this.selectionData[i].userName}</span>`);
            }
        }
    });
    empSel.initialize();

    const empSelNew = new nationalEmployeeSelector('newEmployeeSelector');
    empSelNew.apiPath = '<!--{$orgchartPath}-->/api/';
    empSelNew.rootPath = '<!--{$orgchartPath}-->/';
    empSelNew.outputStyle = 'micro';
    empSelNew.setResultHandler(function() {
        if(this.numResults > 0) {
            for(let i in this.selectionData) {
                $(`#${this.prefixID}emp${i} > .employeeSelectorName`).append(`<br /><span style="font-weight: normal">${this.selectionData[i].userName}</span>`);
            }
        }
    });
    empSelNew.initialize();

    $('.employeeSelectorTable > thead > tr').prepend('<td style="color: red">Account Name</td>');

    $('#run').on('click', function() {
        findAssociatedRequests(empSel, empSelNew);
    });
});

</script>

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
    <br style="clear: both" /><br />
    <button class="buttonNorm" id="run">Preview Changes</button>
    <div id="preview_no_results_found" style="display: none">No associated requests or groups were found for the old account selected</div>
</div>
<div id="section2" style="display: none">
    <p>The requests listed below are associated with the old account "<span id="oldAccountName" style="font-weight: bold"></span>"</p>
    <p>Please review them and the new account "<span id="newAccountName" style="font-weight: bold"></span>".</p>
    <p>Activate the button to update them to reflect the new account.</p>
    <br />
    <button class="buttonNorm" id="reassign">Update These Requests</button>
    <hr />

    <h3>Requests created by the old account</h3>
    <div id="grid_initiator" class="grid_table"></div>
    
    
    <h3>Requests referring to the old account</h3>
    <br />
    <div id="grid_orgchart_employee" class="grid_table"></div>

    <h3>Groups for Old Account</h3>
    <br />
    <div id="grid_groups_info" class="grid_table"></div>
    
</div>
<div id="section3" style="display: none">
    <div id="initiators_updated"></div>
    <div id="orgchart_employee_updated"></div>
    <div id="groups_updated"></div>
</div>

