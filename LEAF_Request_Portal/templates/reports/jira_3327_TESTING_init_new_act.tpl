<style>
#content {
	padding: 1rem;
}
body {
    min-width: fit-content;
}
#bodyarea {
    width: fit-content;
}
.grid_table {
    margin-bottom: 3rem;
}
div [id^="LeafFormGrid"] {
    max-width: 850px;
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
<script src="../libs/js/LEAF/intervalQueue.js"></script>
<link rel="stylesheet" type="text/css" href="<!--{$orgchartPath}-->/css/employeeSelector.css" />



<script>

const CSRFToken = '<!--{$CSRFToken}-->';
    
function reassignInitiator(recordID, newAccount) {
    return new Promise ((resolve, reject) => {
        $.ajax({
            type: 'POST',
            url: `./api/form/${recordID}/initiator`,
            data: {
                CSRFToken: CSRFToken,
                initiator: newAccount
            },
            success: res => {
                $('#section3 #initiators_updated').append(`Request # ${recordID} reassigned to ${newAccount}<br />`);
                resolve('updated');
            },
            error: err => {
                console.log(err);
                reject(err);
            }
        });
    });
}

function updateOrgEmployeeData(recordID, indicatorID, newEmpUID, newAccount) {
    return new Promise ((resolve, reject) => {
        let formData = new FormData();
        formData.append('CSRFToken', CSRFToken);
        formData.append(`${indicatorID}`, newEmpUID);
        
        fetch(`./api/form/${recordID}`, {
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

function prepare(res, accountInfo = {}, queue = {}) {
    for(let recordID in res) {
        queue.push({
            ...accountInfo,
            recordID,
            indicatorID: res[recordID].indicatorID
        });
    }
    $('#reassign').on('click', function() {
        $('#section2').css('display', 'none');
        $('#section3').css('display', 'inline');
        return queue.start().then((res) => {
            console.log(res);
        });
    });
}

function assignTaskForRecord(item) {
    const { taskType, recordID, indicatorID, oldAccount, newAccount, oldEmpUID, newEmpUID } = item;

    switch(taskType) {
        case 'update_initiator':
            return reassignInitiator(recordID, newAccount);
            break;
        case 'update_orgchart_employee_field':
            return updateOrgEmployeeData(recordID, indicatorID, newEmpUID, newAccount);
            break;
        default:
            console.log('hit default', taskType);
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

    let calls = [];
    const queue = new intervalQueue();
    queue.setConcurrency(3);
    
    $('#section1').css('display', 'none');
    $('#section2').css('display', 'inline');
    $('#oldAccountName').html(oldAccount);
    $('#newAccountName').html(newAccount);

    const queryInitiator = new LeafFormQuery();
    queryInitiator.addTerm('userID', '=', oldAccount);
    queryInitiator.onSuccess(function(res) {
        if (res instanceof Object && Object.keys(res).length > 0) {
            let recordIDs = '';
            for (let i in res) {
                recordIDs += res[i].recordID + ',';
            }
            const formGrid = new LeafFormGrid('grid_initiator');
            formGrid.enableToolbar();
            formGrid.setDataBlob(res);
            formGrid.setHeaders([
                {
                    name: 'Title',
                    indicatorID: 'title',
                    callback: function(data, blob) {
                        $('#'+data.cellContainerID).html(blob[data.recordID].title);
                        $('#'+data.cellContainerID).on('click', function() {
                            window.open('index.php?a=printview&recordID='+data.recordID, 'LEAF', 'width=800,resizable=yes,scrollbars=yes,menubar=yes');
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
            prepare(res, accountInfo, queue);
        } else {
            $('#grid_initiator').append('No records found');
        }
    });
    calls.push(queryInitiator.execute());
    
    /* *********************************************************************************** */
    
    const queryOrgchartEmployee = new LeafFormQuery();
    
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
            const formGrid = new LeafFormGrid('grid_orgchart_employee');
            formGrid.enableToolbar();
            formGrid.setDataBlob(res);
            formGrid.setHeaders([
                {
                    name: 'Title', 
                    indicatorID: 'title', 
                    callback: function(data, blob) {
                        $('#'+data.cellContainerID).html(blob[data.recordID].title);
                        $('#'+data.cellContainerID).on('click', function() {
                            window.open('index.php?a=printview&recordID='+data.recordID, 'LEAF', 'width=800,resizable=yes,scrollbars=yes,menubar=yes');
                    });
                }},
                {
                    name: 'Orgchart Employee',
                    request: 'request',
                    editable: false,
                    callback: function(data, blob) {
                        //blob[data.recordID].userID
                        $('#'+data.cellContainerID).html('TEMP INFO');
                }}
            ]);
            formGrid.loadData(recordIDs);

            accountInfo.taskType = 'update_orgchart_employee_field';
            prepare(res, accountInfo, queue);
        } else {
            $('#grid_orgchart_employee').append('No records found');
        }
    });
    calls.push(queryOrgchartEmployee.execute());

    Promise.all(calls).then((res)=> {
        console.log(res);
        queue.setWorker(item => {
            return assignTaskForRecord(item);
        });

    }).catch(err => console.log(err));
}

$(function() {

    const empSel = new nationalEmployeeSelector('employeeSelector');
    empSel.apiPath = '<!--{$orgchartPath}-->/api/?a=';
    empSel.rootPath = '<!--{$orgchartPath}-->/';
    empSel.outputStyle = 'micro';
    empSel.setResultHandler(function() {
        if(this.numResults > 0) {
            for(let i in this.selectionData) {
				$('#' + this.prefixID + 'emp' + i + ' > .employeeSelectorName').append('<br /><span style="font-weight: normal">' + this.selectionData[i].userName + '</span>');
            }
        }
    });
    empSel.initialize();

    const empSelNew = new nationalEmployeeSelector('newEmployeeSelector');
    empSelNew.apiPath = '<!--{$orgchartPath}-->/api/?a=';
    empSelNew.rootPath = '<!--{$orgchartPath}-->/';
    empSelNew.outputStyle = 'micro';
    empSelNew.setResultHandler(function() {
        if(this.numResults > 0) {
            for(let i in this.selectionData) {
				$('#' + this.prefixID + 'emp' + i + ' > .employeeSelectorName').append('<br /><span style="font-weight: normal">' + this.selectionData[i].userName + '</span>');
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
    
</div>
<div id="section3" style="display: none">
    <div id="initiators_updated"></div>
    <div id="orgchart_employee_updated"></div>
</div>

