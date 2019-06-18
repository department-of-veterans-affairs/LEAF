<style>
    div#massActionContainer {
        width: 800px;
        margin: auto;
    }
    #searchRequestsContainer, #searchResults, #searchResultsFrom, #errorMessage, #errorMessageFrom, #indicatorAssignment, #iconBusy {
        display: none;
    }
    #actionContainer {
        padding-bottom: 5px;
    }
    #iconBusy{
        height: 20px;
    }
    table#requests {
        border-collapse: collapse;
    }
    table#requests th, table#requestsFrom th{
        text-align: center;
        border: 1px solid black;
        padding: 4px 2px;
        font-size: 12px;
        background-color: rgb(209, 223, 255);
    }
    table#requests td, table#requestsFrom td{
        border: 1px solid black;
        padding: 8px;
        font-size: 12px;
    }
</style>
<!--{include file="site_elements/generic_confirm_xhrDialog.tpl"}-->
<script src="./js/formSearch.js"></script>
<script src="<!--{$orgchartPath}-->/js/employeeSelector.js"></script>
<link rel="stylesheet" type="text/css" href="<!--{$orgchartPath}-->/css/employeeSelector.css" />
<script>

var processedRequests = 0;
var totalActions = 0;
var actionValue = '';
var successfulActionRecordIDs = [];
var failedActionRecordIDs = [];
var dialog_confirm;
var searchID = '';
var fromSearchID = '';
var leafSearch;
var leafSearchFrom;
var isLeafSearchInit = false;
var isLeafSearchFromInit = false;
var extraTerms;
var extraTermsFrom;
var empSel = '';
var firstSearch = true;
var fromFirstSearch = true;
var indicatorsToParse = [];
var selectedFormCategories = [];

$(document).ready(function(){

    chooseAction();

    dialog_confirm = new dialogController('confirm_xhrDialog', 'confirm_xhr', 'confirm_loadIndicator', 'confirm_button_save', 'confirm_button_cancelchange');

    $('select#action').change(function(){
        chooseAction();
    });

    $("button.takeAction").click(function() {
        dialog_confirm.setContent('<img src="../../../libs/dynicons/?img=process-stop.svg&amp;w=48" alt="Cancel Request" style="float: left; padding-right: 24px" /> Are you sure you want to perform this action?');

        dialog_confirm.setSaveHandler(function() {
            executeMassAction();
            dialog_confirm.hide();
        });
        dialog_confirm.show();
    });

    $('input#selectAllRequests').change(function(){
        $('input.massActionRequest').prop('checked', $(this).is(':checked'));
    });

    $(document).on('change', 'input#indicatorVal', function() {
        if (actionValue === 'copyIndicator') {
            getCategoryIndicators();
        }
    });

    $(document).on('change', 'input.massActionRequest', function() {
        $('input#selectAllRequests').prop('checked', false);
        if ($(this).is(':checked')) {
            selectedFormCategories.push($(this).attr('id'));
        } else if (!$(this).is(':checked')) {
            selectedFormCategories.splice(selectedFormCategories.indexOf($(this).attr('id')), 1);
        }
        if (actionValue === 'copyIndicator') {
            getCategoryIndicators();
        }
    });

    leafSearch = new LeafFormSearch('searchRequestsContainer');
    leafSearch.setRootURL('./');
    leafSearch.setSearchFunc(function(search) {
        extraTerms = search;
        doSearch();
    });
    leafSearchFrom = new LeafFormSearch('searchRequestsContainerFrom');
    leafSearchFrom.setRootURL('./');
    leafSearchFrom.setSearchFunc(function(search) {
        extraTermsFrom = search;
        doSearchFrom();
    });

    //leafSearch.init();
});

function doSearchFrom() {
    fromSearchID = Math.floor((Math.random() * 1000000000));
    queryObjFrom = buildQuery('false', '', true);
    listRequests(queryObjFrom, fromSearchID, true);
}
function getCategoryIndicators() {
    var categoryList = [];
    var indicatorArray = [];
    var indicatorDropdown = '<select id="indicatorAssigned">';
    $.each($('input#indicatorVal:checked'), function() {
        indicatorArray.push({
            recordID: $(this).closest('tr').find('td:first > a').html(),
            name: $(this).attr('name'),
            id: $(this).val()
        });
    });

    for (var i = 0; i < selectedFormCategories.length; i++) {
        tempArr = selectedFormCategories[i].split('-');
        for (var j = 0; j < tempArr.length; j++) {
            if (categoryList.indexOf(tempArr[j]) === -1) {
                categoryList.push(tempArr[j]);
            }
        }
    }
    indicatorDropdown += '<option value="0">No Change</option>';
    for (var i = 0; i < indicatorArray.length; i++) {
        indicatorDropdown += '<option value="'+indicatorArray[i].recordID+'-'+indicatorArray[i].id+'">';
        indicatorDropdown += indicatorArray[i].recordID + ': ' + indicatorArray[i].name;
        indicatorDropdown += '</option>';
    }
    indicatorDropdown += '</select>';
    if (categoryList.length > 0) {
        $.ajax({
            type: 'GET',
            url: './api/?a=form/indicator/list',
            data: {CSRFToken: '<!--{$CSRFToken}-->', sort: 'indicatorID', forms: categoryList.join(',')},
            cache: false
        }).done(function (data) {
            var table = '<table id="indicatorAssociation">' +
                '               <thead>' +
                '               <th>ID</th>' +
                '               <th>Indicator</th>' +
                '               <th>Form</th>' +
                '               <th>Indicator Options</th>' +
                '               </thead>' +
                '               <tbody>';
            $.each(data, function () {
                table += '<tr><td>' + this.indicatorID + '</td>';
                table += '<td>' + this.name + '</td>';
                table += '<td>' + this.categoryName + '</td>';
                table += '<td>'+indicatorDropdown+'</td></tr>';
            });
            table += '</table>';
            if (data.length === 0) {
                $('#indicatorAssignment').html('');
                $('#indicatorAssignment').hide();
            } else {
                $('#indicatorAssignment').show();
                $('#indicatorAssignment').html(table);
            }
        }).fail(function (jqXHR, error, errorThrown) {
            console.log(jqXHR);
            console.log(error);
            console.log(errorThrown);
        }).always(function () {
            // $('#iconBusy').hide();
        });
    } else {
        $('#indicatorAssignment').html('');
        $('#indicatorAssignment').hide();
    }
}

function chooseAction()
{
    $('#copyFromContainer').hide();
    $('#searchResultsFrom').hide();
    $('#empSelector').hide();
    $('#empSelectorMat').hide();
    indicatorsToParse = [];
    selectedFormCategories = [];
    if($('select#action').val() !== '')
    {
        $('#searchRequestsContainer').show();
        if(!isLeafSearchInit)
        {
            isLeafSearchInit = true;
            leafSearch.init();
        }
        if($('select#action').val() === 'copyIndicator')
        {
            $('#copyFromContainer').show();
            if(!isLeafSearchFromInit)
            {
                isLeafSearchFromInit = true;
                leafSearchFrom.init();
            }
            if (!fromFirstSearch) {
                doSearchFrom();
            } else {
                fromFirstSearch = !fromFirstSearch;
            }
        }
        if (!firstSearch) {
            doSearch();
        } else {
            firstSearch = !firstSearch;
        }
    }
    else
    {
        $('#searchRequestsContainer').hide();
        $('#searchResults').hide();
        $('#errorMessage').hide();
        $('#errorMessageFrom').hide();
    }
}

/**
 * Sets up and builds the search query, passing it along to listRequests
 */
function doSearch()
{
    var getCancelled = '';
    var getSubmitted = '';

    $('input#selectAllRequests').prop('checked', false);
    setProgress("");
    actionValue = $('select#action').val();//lock in selection

    switch(actionValue) {
        case 'submit':
            getCancelled = 'false';
            getSubmitted = 'false';
            break;
        case 'copyIndicator':
            getCancelled = 'false';
            break;
        case 'changeSubmitter':
            $('#empSelector').show();
            $('#empSelectorMat').show();
            empSel = new employeeSelector("empSelector");
            empSel.apiPath = '<!--{$orgchartPath}-->' + '/api/';
            empSel.rootPath = '<!--{$orgchartPath}-->' + '/';
            empSel.outputStyle = 'micro';

            empSel.setSelectHandler(function() {
                if(empSel.selectionData[empSel.selection] != undefined) {
                    $('#empSelectorMat').val(empSel.selectionData[empSel.selection].userName);
                }
            });
            empSel.setResultHandler(function() {
                if(empSel.selectionData[empSel.selection] != undefined) {
                    $('#empSelectorMat').val(empSel.selectionData[empSel.selection].userName);
                }
            });
            empSel.initialize();
            getCancelled = 'false';
            getSubmitted = 'true';
            break;
        case 'cancel':
            getCancelled = 'false';
            break;
        case 'restore':
            getCancelled = 'true';
            break;
    }
    var queryObj = buildQuery(getCancelled, getSubmitted, false);
    searchID = Math.floor((Math.random() * 1000000000));
    listRequests(queryObj, searchID, false);
}

/**
 * Builds query object to pass to form/query
 *
 * @param {string}  [getCancelled]      '','true', or 'false' whether to filter by cancelled, then whether request is('true') or isn't('false') cancelled
 * @param {string}  [getSubmitted]      '','true', or 'false' whether to filter by submitted, then whether request is('true') or isn't('false') cancelled
 *
 * @param {boolean} [isCopy] true if for copy container, false for normal container
 * @return {Object} query object to pass to form/query.
 */
function buildQuery(getCancelled, getSubmitted, isCopy)
{
    var requestQuery = {"terms":[],
                        "joins":["service", "recordsDependencies", "categoryName", "status"],
                        "sort":{}
                        };
    var terms = isCopy ? extraTermsFrom : extraTerms;

    if(getCancelled === 'true')
    {
        requestQuery.terms.push({"id":"stepID","operator":"=","match":"deleted"});
    }
    else if(getCancelled === 'false')
    {
        requestQuery.terms.push({"id":"stepID","operator":"!=","match":"deleted"});
    }

    if(getSubmitted === 'false')
    {
        requestQuery.terms.push({"id":"stepID","operator":"!=","match":"submitted"});
    }

    //handle extraTerms
    var isJSON = true;
    var advSearch = {};
    try {
        advSearch = $.parseJSON(terms);
    }
    catch(err) {
        isJSON = false;
    }

    if(isJSON) {
        requestQuery.terms = $.merge(requestQuery.terms, advSearch);
    }
    else if(typeof(terms) === 'string'){
        requestQuery.terms.push({"id":"title","operator":"LIKE","match":"*"+terms.trim()+"*"});
    }

    return requestQuery;
}

/**
 * Looks up requests based on filter/searchbar and builds table with the results
 *
 * @param {Object}  [queryObj]  Object to pass to form/query
 * @param {Integer} [thisSearchID]  When done() is called, this param is compared to the global searchID. If they are not equal, then the results are not processed.
 * @param {Boolean} [isCopy]
 */
function listRequests(queryObj, thisSearchID, isCopy)
{
    var table = isCopy ? 'table#requestsFrom' : 'table#requests';
    var results = isCopy ? '#searchResultsFrom' : '#searchResults';
    var clearedRows = isCopy ? 'table#requestsFrom tr.requestRow' : 'table#requests tr.requestRow';
    var id = isCopy ? fromSearchID : searchID;
    var error = isCopy ? '#errorMessageFrom' : '#errorMessage';
    $(results).hide();
    $(error).hide();
    $(clearedRows).remove();
    $('#iconBusy').show();
    function makeRow(value, indicatorSelector) {
        box = isCopy ? indicatorSelector : '<input type="checkbox" name="massActionRequest" class="massActionRequest" id="'+value.categoryIDs.join('-')+'" value="'+value.recordID+'">';
        requestsRow = '<tr class="requestRow">';
        requestsRow += '<td><a href="index.php?a=printview&amp;recordID='+value.recordID+'">'+value.recordID+'</a></td>';
        requestsRow += '<td>'+((value.categoryNames === undefined || value.categoryNames.length == 0) ? 'non' : value.categoryNames[0]) +'</td>';
        requestsRow += '<td>'+(value.service == null ? '' : value.service)+'</td>';
        requestsRow += '<td>'+value.title+'</td>';
        requestsRow += '<td>'+box+'</td>';
        requestsRow += '</tr>';
        $(table).append(requestsRow);
        $(results).show();
    }

    $.ajax({
        type: 'GET',
        url: './api/?a=form/query',
        data: {q: JSON.stringify(queryObj),
                CSRFToken: '<!--{$CSRFToken}-->'},
        cache: false
    }).done(function(data) {
        if(thisSearchID === id) {
            if (Object.keys(data).length) {
                $.each(data, function (index, value) {
                    if (isCopy) {
                        $.ajax({
                            type: 'GET',
                            url: './api/?a=form/' + value.recordID + '/data',
                            data: {CSRFToken: '<!--{$CSRFToken}-->'},
                            cache: false
                        }).done(function (data) {
                            indicators = '';
                            $.each(data, function (index, value) {
                                firstLevel = Object.keys(value)[0];
                                name = value[firstLevel].name === '' ? 'Indicator Number ' + value[firstLevel].indicatorID : value[firstLevel].name;
                                indicators += '<input type="checkbox" name="' + name + '" id="indicatorVal" value="' + value[firstLevel].indicatorID + '">' + name + '<br />'
                            });
                            makeRow(value, indicators);
                        }).fail(function (jqXHR, error, errorThrown) {
                            console.log(jqXHR);
                            console.log(error);
                            console.log(errorThrown);
                        }).always(function () {
                            // $('#iconBusy').hide();
                        });
                    } else {
                        makeRow(value, '');
                    }
                });
            }
        }
        else
        {
            $(error).html('No Results');
            $(error).show();
        }
    }).fail(function (jqXHR, error, errorThrown) {
        console.log(jqXHR);
        console.log(error);
        console.log(errorThrown);
    }).always(function (){
        $('#iconBusy').hide();
    });
}

/**
 * Executes the selected action on each request selected in the table
 */
function executeMassAction()
{
    var selectedRequests = $('input.massActionRequest:checked');
    processedRequests = 0;
    totalActions = selectedRequests.length;
    successfulActionRecordIDs = [];
    failedActionRecordIDs = [];

    if(totalActions)
    {
        $('button.takeAction').attr("disabled", "disabled");
    }
    $.each(selectedRequests, function(key, item) {
        var ajaxPath = '';
        var ajaxData = {};
        var recordID = $(item).val();
        switch(actionValue) {
            case 'submit':
                ajaxPath = './api/?a=form/'+recordID+'/submit';
                ajaxData = {CSRFToken: '<!--{$CSRFToken}-->'};
                break;
            case 'copyIndicator':
                var dataToSend = [];
                var destination = $(this).parent('td').parent('tr').first('td').find('a').html();
                var tempArr = [];
                $.each($('select#indicatorAssigned'), function() {
                    var tempObj = {};
                    tempObj.recordID = destination;
                    tempObj.indicatorID = $(this).closest('tr').find('td:first').html();
                    tempObj.fromRecordID = $(this).val().split('-')[0];
                    tempObj.fromIndicatorID = $(this).val().split('-')[1];
                    tempArr.push(tempObj);
                });
                dataToSend.push(tempArr);

                ajaxPath = './api/?a=form/copy';
                ajaxData = {CSRFToken: '<!--{$CSRFToken}-->', dataToSend: dataToSend};
                break;
            case 'changeSubmitter':
                ajaxPath = './api/?a=form/'+recordID+'/initiator';
                ajaxData = {CSRFToken: '<!--{$CSRFToken}-->', initiator: $('#empSelectorMat').val()};
                break;
            case 'cancel':
                ajaxPath = './api/?a=form/'+recordID+'/cancel';
                ajaxData = {CSRFToken: '<!--{$CSRFToken}-->'};
                break;
            case 'restore':
                ajaxPath = './ajaxIndex.php?a=restore';
                ajaxData = {restore: recordID,
                            CSRFToken: '<!--{$CSRFToken}-->'};
                break;
        }

        executeOneAction(recordID, ajaxPath, ajaxData);
	});
}

/**
 * Executes one ajax call to execute an action
 *
 * @param {int}     [recordID]  recordID for the record that the selected action is being applied to
 * @param {string}  [ajaxPath]  the api path for the selected action
 * @param {Object}  [ajaxData]  data object to pass to the selected ajaxPath
 */
function executeOneAction(recordID, ajaxPath, ajaxData)
{
    $.ajax({
        type: 'POST',
        url: ajaxPath,
        data: ajaxData,
        dataType: "text",
        cache: false
    }).done(function(data) {
        successTrueFalse = true;
        updateProgress(recordID, successTrueFalse);
    }).fail(function (jqXHR, error, errorThrown) {
        successTrueFalse = false;
        updateProgress(recordID, successTrueFalse);
        console.log(jqXHR);
        console.log(error);
        console.log(errorThrown);
    });
}

/**
 * Updates progress message, checks if the process is complete, and sets complete message
 *
 * @param {int}     [recordID]  recordID for the record that the selected action is being applied to
 * @param {boolean} [success]   true if the update is marking a success, false if a failure
 */
function updateProgress(recordID, success)
{
    if(success)
    {
        successfulActionRecordIDs.push(recordID);
    }
    else
    {
        failedActionRecordIDs.push(recordID);
    }
    processedRequests++;
    setProgress("Completed: " + processedRequests + '/' + totalActions);
    if(processedRequests === totalActions)
    {
        if(failedActionRecordIDs.length > 0)
        {
            var alertMessage = "Action failed on the following requests:";
            $.each(failedActionRecordIDs, function(key, item) {
                alertMessage += "\n - ID: " + item;
            });
            alert(alertMessage);
        }

        doSearch();
        setProgress(successfulActionRecordIDs.length + ' successes and ' + failedActionRecordIDs.length + ' failures of ' + totalActions + ' total.');
        if (actionValue === 'copyIndicator') {
            doSearchFrom();
            $('#indicatorAssignment').html('');
            $('#indicatorAssignment').hide();
        }
        $('button.takeAction').removeAttr("disabled");
    }
}

/**
 * Updates progress message
 *
 * @param {string}  [message]   String to set into the progress area
 */
function setProgress(message)
{
    $('div.progress').html(message);
}
</script>
<div id="massActionContainer">
    <h1>Mass Action</h1>
    <div id="actionContainer">
        <label for="action"> Choose Action </label>
        <select id="action" name="action">
            <option value="">-Select-</option>
            <option value="cancel">Cancel</option>
            <option value="restore">Restore</option>
            <option value="submit">Submit</option>
            <option value="changeSubmitter">Change Submitter</option>
            <option value="copyIndicator">Copy Indicator</option>
        </select>
    </div>
    <div id="copyFromContainer">
        <h4>Select a Request to Copy From:</h4>
        <div id="searchRequestsContainerFrom"></div>
        <div id="searchResultsFrom">
            <table style="border-collapse: collapse;" id="requestsFrom">
                <tr id="headerRow">
                    <th>UID</th>
                    <th>Type</th>
                    <th>Service</th>
                    <th>Title</th>
                    <th>Indicators</th>
                </tr>
            </table>
        </div>
        <div id="errorMessageFrom"></div>
        <br />
        <h4>Select a Request to Copy Into:</h4>
    </div>

    <div id="searchRequestsContainer"></div>
    <img id="iconBusy" src="./images/indicator.gif" class="employeeSelectorIcon" alt="busy">
    <div id="empSelector"></div>
    <div id="empSelectorMat"></div>
    <div id="indicatorAssignment"></div>
    <div id="searchResults">
        <button class="buttonNorm takeAction" style="text-align: center; font-weight: bold; white-space: normal">Take Action</button>
        <div class="progress"></div>
        <table id="requests">
            <tr id="headerRow">
                <th>UID</th>
                <th>Type</th>
                <th>Service</th>
                <th>Title</th>
                <th><input type="checkbox" name="selectAllRequests" id="selectAllRequests" value=""></th>
            </tr>
        </table>
        <button class="buttonNorm takeAction" style="text-align: center; font-weight: bold; white-space: normal">Take Action</button>
    </div>
    <div class="progress"></div>
    <div id="errorMessage"></div>
</div>