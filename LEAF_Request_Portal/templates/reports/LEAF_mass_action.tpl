<style>
    div#massActionContainer {
        width: 800px;
        margin: auto;
    }
    #searchRequestsContainer, #searchResults, #errorMessage, #iconBusy {
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
    table#requests th {
        text-align: center;
        border: 1px solid black;
        padding: 4px 2px;
        font-size: 12px;
        background-color: rgb(209, 223, 255);
    }
    table#requests td {
        border: 1px solid black; 
        padding: 8px; 
        font-size: 12px;
    }
</style>
<!--{include file="site_elements/generic_confirm_xhrDialog.tpl"}-->
<script src="./js/formSearch.js"></script>
<script>

var processedRequests = 0;
var totalActions = 0;
var actionValue = '';
var successfulActionRecordIDs = [];
var failedActionRecordIDs = [];
var dialog_confirm;
var searchID = '';
var leafSearch;
var isLeafSearchInit = false;
var extraTerms;

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

    $(document).on('change', 'input.massActionRequest', function() { 
        $('input#selectAllRequests').prop('checked', false);
    });

    leafSearch = new LeafFormSearch('searchRequestsContainer');
    leafSearch.setRootURL('./');
    leafSearch.setSearchFunc(function(search) {
        extraTerms = search;
        doSearch();
    });

    //leafSearch.init();
});

function chooseAction()
{
    if($('select#action').val() !== '')
    {
        $('#searchRequestsContainer').show();
        if(!isLeafSearchInit)
        {
            isLeafSearchInit = true;
            leafSearch.init();
        }
        doSearch();
    }
    else
    {
        $('#searchRequestsContainer').hide();
        $('#searchResults').hide();
        $('#errorMessage').hide();
        
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
        case 'cancel':
            getCancelled = 'false';
            break;
        case 'restore':
            getCancelled = 'true';
            break;
    }
    var queryObj = buildQuery(getCancelled, getSubmitted);
    searchID = Math.floor((Math.random() * 1000000000));
    listRequests(queryObj, searchID);
}

/**
 * Builds query object to pass to form/query
 *
 * @param {string}  [getCancelled]      '','true', or 'false' whether to filter by cancelled, then whether request is('true') or isn't('false') cancelled 
 * @param {string}  [getSubmitted]      '','true', or 'false' whether to filter by submitted, then whether request is('true') or isn't('false') cancelled 
 *
 * @return {Object} query object to pass to form/query.
 */
function buildQuery(getCancelled, getSubmitted)
{
    var requestQuery = {"terms":[],
                        "joins":["service", "recordsDependencies", "categoryName", "status"],
                        "sort":{}
                        };

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
        advSearch = $.parseJSON(extraTerms);
    }
    catch(err) {
        isJSON = false;
    }

    if(isJSON) {
        requestQuery.terms = $.merge(requestQuery.terms, advSearch);
    }
    else if(typeof(extraTerms) === 'string'){
        requestQuery.terms.push({"id":"title","operator":"LIKE","match":"*"+extraTerms.trim()+"*"});
    }

    return requestQuery;
}

/**
 * Looks up requests based on filter/searchbar and builds table with the results
 *
 * @param {Object}  [queryObj]  Object to pass to form/query
 * @param {Integer} [thisSearchID]  When done() is called, this param is compared to the global searchID. If they are not equal, then the results are not processed.
 */
function listRequests(queryObj, thisSearchID)
{
    $('#searchResults').hide();
    $('#errorMessage').hide();
    $('table#requests tr.requestRow').remove();
    $('#iconBusy').show();

    $.ajax({
        type: 'GET',
        url: './api/?a=form/query',
        data: {q: JSON.stringify(queryObj),
                CSRFToken: '<!--{$CSRFToken}-->'},
        cache: false
    }).done(function(data) {
        if(thisSearchID === searchID)
        {
            if(Object.keys(data).length)
            {
                $.each(data, function( index, value ) {
                    console.log(value);
                    requestsRow = '<tr class="requestRow">';
                    requestsRow += '<td><a href="index.php?a=printview&amp;recordID='+value.recordID+'">'+value.recordID+'</a></td>';
                    requestsRow += '<td>'+((value.categoryNames === undefined || value.categoryNames.length == 0) ? 'non' : value.categoryNames[0]) +'</td>';
                    requestsRow += '<td>'+(value.service == null ? '' : value.service)+'</td>';
                    requestsRow += '<td>'+value.title+'</td>';
                    requestsRow += '<td><input type="checkbox" name="massActionRequest" class="massActionRequest" value="'+value.recordID+'"></td>';
                    requestsRow += '</tr>';
                    $('table#requests').append(requestsRow);
                });
                $('#searchResults').show();
            }
            else
            {
                $('#errorMessage').html('No Results');
                $('#errorMessage').show();
            }
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
        </select>
    </div>

    <div id="searchRequestsContainer"></div>
    <img id="iconBusy" src="./images/indicator.gif" class="employeeSelectorIcon" alt="busy">
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