<h2>This utility will replace the account associated to a request initiator. (e.g.: after an employee has been assigned a new account by OIT).</h2>
<br /><br />

<script src="<!--{$orgchartPath}-->/js/nationalEmployeeSelector.js"></script>
<link rel="stylesheet" type="text/css" href="<!--{$orgchartPath}-->/css/employeeSelector.css" />
<script>

var CSRFToken = '<!--{$CSRFToken}-->';
function reassign(i, newAccount) {
    $.ajax({
        type: 'POST',
        url: './api/form/' + i + '/initiator',
        data: {CSRFToken: CSRFToken,
            initiator: newAccount},
        success: function() {
            $('#section3').append('Request # ' + i + ' reassigned to ' + newAccount + '<br />');
        }
    });
}
function prepare(res, newAccount) {
    $('#reassign').on('click', function() {
        $('#section2').css('display', 'none');
        $('#section3').css('display', 'inline');
        for(var i in res) {
            reassign(i, newAccount);
        }
    });
}

function findAssociatedRequests(oldAccount, newAccount) {
    $('#section1').css('display', 'none');
    $('#section2').css('display', 'inline');
    $('#oldAccountName').html(oldAccount);
    $('#newAccountName').html(newAccount);

    var query = new LeafFormQuery();
    query.addTerm('userID', '=', oldAccount);
    query.onSuccess(function(res) {
        var recordIDs = '';
        for (var i in res) {
            // Currently need to store the resulting list of recordIDs as a CSV
            recordIDs += res[i].recordID + ',';
        }
        var formGrid = new LeafFormGrid('grid');
        formGrid.enableToolbar();
        formGrid.setDataBlob(res);
        formGrid.setHeaders([
            {name: 'Title', indicatorID: 'title', callback: function(data, blob) { // The Title field is a bit unique, and must be implemnted this way
                $('#'+data.cellContainerID).html(blob[data.recordID].title);
                $('#'+data.cellContainerID).on('click', function() {
                    window.open('index.php?a=printview&recordID='+data.recordID, 'LEAF', 'width=800,resizable=yes,scrollbars=yes,menubar=yes');
                });
            }},
            {name: 'Initiator Account', indicatorID: 'initiator', editable: false, callback: function(data, blob) {
                $('#'+data.cellContainerID).html(blob[data.recordID].userID);
            }}
        ]);
        formGrid.loadData(recordIDs);
        prepare(res, newAccount);
    });
    query.execute();
}

$(function() {

    var empSel = new nationalEmployeeSelector('employeeSelector');
    empSel.apiPath = '<!--{$orgchartPath}-->/api/?a=';
    empSel.rootPath = '<!--{$orgchartPath}-->/';
    empSel.outputStyle = 'micro';
    empSel.setResultHandler(function() {
        if(this.numResults > 0) {
            for(var i in this.selectionData) {
				$('#' + this.prefixID + 'emp' + i + ' > .employeeSelectorName').append('<br /><span style="font-weight: normal">' + this.selectionData[i].userName + '</span>');
            }
        }
    });
    empSel.initialize();

    var empSelNew = new nationalEmployeeSelector('newEmployeeSelector');
    empSelNew.apiPath = '<!--{$orgchartPath}-->/api/?a=';
    empSelNew.rootPath = '<!--{$orgchartPath}-->/';
    empSelNew.outputStyle = 'micro';
    empSelNew.setResultHandler(function() {
        if(this.numResults > 0) {
            for(var i in this.selectionData) {
				$('#' + this.prefixID + 'emp' + i + ' > .employeeSelectorName').append('<br /><span style="font-weight: normal">' + this.selectionData[i].userName + '</span>');
            }
        }
    });
    empSelNew.initialize();
    $('.employeeSelectorTable > thead > tr').prepend('<td style="color: red">Account Name</td>');
    $('#run').on('click', function() {
        var oldAccount = empSel.selectionData[empSel.selection].userName;
        var newAccount = empSelNew.selectionData[empSelNew.selection].userName;
		if(oldAccount != ''
          	&& newAccount != ''
          	&& oldAccount != newAccount) {
            findAssociatedRequests(oldAccount, newAccount);
        }
        else {
            alert('Invalid selections');
        }
    });

});

</script>
<div id="section1">
    <div class="card" style="float: left; width: 40%; border: 1px solid black; padding: 8px; margin: 10px">
        <h2>Old Account</h2>
        <div id="employeeSelector"></div>
    </div>

    <div class="card" style="float: left; width: 40%; border: 1px solid black; padding: 8px; margin: 10px">
        <h2>New Account</h2>
        <div id="newEmployeeSelector"></div>
    </div>
    <br style="clear: both" /><br />
    <button class="buttonNorm" id="run">Preview Changes</button>
</div>
<div id="section2" style="display: none">
    The following requests created by the old account "<span id="oldAccountName" style="font-weight: bold"></span>" will be reassigned to the new account "<span id="newAccountName" style="font-weight: bold"></span>."
    <br />
    <button class="buttonNorm" id="reassign">Reassign These Requests</button>
    <div id="grid"></div>
</div>
<div id="section3" style="display: none"></div>