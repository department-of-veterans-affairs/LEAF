/*
 * Mass Action Page Javascript
 */

// Global variables
let leafSearch;
let massActionToken = document
    .getElementById("mass-action-js")
    .getAttribute("data-token");
let orgChartPath = document
    .getElementById("mass-action-js")
    .getAttribute("data-orgChartPath");
let processedRequests = 0;
let totalActions = 0;
let successfulActionRecordIDs = [];
let failedActionRecordIDs = [];
let dialog_confirm;
let searchID = "";
let extraTerms;

$(document).ready(function () {
    // Setup choosing selection and dialog for future use
    chooseAction();
    dialog_confirm = new dialogController(
        "confirm_xhrDialog",
        "confirm_xhr",
        "confirm_loadIndicator",
        "confirm_button_save",
        "confirm_button_cancelchange"
    );

    // When action changes, redo the choose so it sets up the correct fields to enter
    $("select#action").change(function () {
        chooseAction();
    });

    // Confirm submission for mass action and perform action if accepted
    $("button.takeAction").click(function () {
        dialog_confirm.setContent(
            '<img src="dynicons/?img=process-stop.svg&amp;w=48" alt="Cancel Request" style="float: left; padding-right: 24px" /> Are you sure you want to perform this action?'
        );

        dialog_confirm.setSaveHandler(function () {
            executeMassAction();
            dialog_confirm.hide();
        });
        dialog_confirm.show();
    });

    // When "Select All" selected/de-selected, set all of the request checkboxes to match
    $("input#selectAllRequests").change(function () {
        $("input.massActionRequest").prop("checked", $(this).is(":checked"));
    });

    // When changing any mass action, reset all record checkboxes to unchecked
    $(document).on("change", "input.massActionRequest", function () {
        $("input#selectAllRequests").prop("checked", false);
    });

    // Do the search from the input textbox if it is requested
    leafSearch = new LeafFormSearch("searchRequestsContainer");
    leafSearch.setRootURL("./");
    leafSearch.setOrgchartPath(orgChartPath);
    leafSearch.setSearchFunc(function (search) {
        extraTerms = search;
        doSearch();
    });
});

/**
 * Purpose: Setup of choosing which action to take overall
 */
function chooseAction() {
    // If nothing selected and action selected is not 'Email Reminder'
    let actionValue = $("#action").val();
    if (actionValue !== "" && actionValue !== "email") {
        // Hide the email reminder and reset then show other options search and perform
        $("#emailSection").hide();
        $("#searchRequestsContainer").show();
        leafSearch.init();
        doSearch();
    }
    // If selected 'Email Reminder' then hide searches, show last action select
    else if (actionValue === "email") {
        $(
            "#emailSection, #searchRequestsContainer, #searchResults, #errorMessage"
        ).show();
        // When changing the time of last action, grab the value selected and search it
        $("#lastAction").change(function () {
            reminderDaysSearch();
        });
        $("#submitSearchByDays").click(function () {
            reminderDaysSearch();
        });
        leafSearch.init();
        reminderDaysSearch();
    }
    // Nothing selected so hide search and email sections
    else {
        $(
            "#emailSection, #searchRequestsContainer, #searchResults, #errorMessage"
        ).hide();
    }
}

/**
 * Purpose do reminder search (used by click or change of lastAction text)
 */
function reminderDaysSearch() {
    let daysSince = document.getElementById("lastAction").valueOf();
    doSearch();
}

/**
 * Sets up and builds the search query, passing it along to listRequests
 */
function doSearch() {
    let getCancelled = false;
    let getSubmitted = true;
    let getReminder = 0;

    $("input#selectAllRequests").prop("checked", false);
    setProgress("");
    // Get Dropdown values
    actionValue = $("select#action").val();
    switch (actionValue) {
        case "email":
            getReminder = Number(document.getElementById("lastAction").value);
            break;
        case "submit":
            getSubmitted = false;
            break;
        case "restore":
            getCancelled = true;
            break;
    }

    let queryObj = buildQuery(getCancelled, getSubmitted, getReminder);
    searchID = Math.floor(Math.random() * 1000000000);
    listRequests(queryObj, searchID, getReminder);
}

/**
 * Builds query object to pass to form/query
 *
 * @param {boolean}                [getCancelled]                                 filter by cancelled
 * @param {boolean}                [getSubmitted]                                 filter by submitted
 * @param {int}                                                [getReminder]                                                value of email reminder selection
 *
 * @return {Object} query object to pass to form/query.
 */
function buildQuery(getCancelled, getSubmitted, getReminder) {
    let requestQuery = {
        terms: [],
        joins: ["service", "recordsDependencies", "categoryName", "status"],
        sort: {},
    };

    if (getCancelled) {
        requestQuery.terms.push({
            id: "stepID",
            operator: "=",
            match: "deleted",
        });
    } else {
        requestQuery.terms.push({
            id: "stepID",
            operator: "!=",
            match: "deleted",
        });
    }

    if (!getSubmitted) {
        requestQuery.terms.push({
            id: "stepID",
            operator: "!=",
            match: "submitted",
        });
    }

    if (getReminder) {
        requestQuery.joins.push("action_history");
        requestQuery.terms.push({
            id: "stepID",
            operator: "!=",
            match: "resolved",
        });
    }

    //handle extraTerms
    let isJSON = true;
    let advSearch = {};
    try {
        advSearch = $.parseJSON(extraTerms);
    } catch (err) {
        isJSON = false;
    }

    if (isJSON) {
        requestQuery.terms = $.merge(requestQuery.terms, advSearch);
    } else if (typeof extraTerms === "string") {
        requestQuery.terms.push({
            id: "title",
            operator: "LIKE",
            match: "*" + extraTerms.trim() + "*",
        });
    }
    return requestQuery;
}

/**
 * Looks up requests based on filter/searchbar and builds table with the results
 *
 * @param {Object}                [queryObj]                                                Object to pass to form/query
 * @param {Integer} [thisSearchID]                When done() is called, this param is compared to the global searchID. If they are not equal, then the results are not processed.
 * @param {Number}                [getReminder]                 Number of days for email reminder selection
 */
function listRequests(queryObj, thisSearchID, getReminder = 0) {
    $("#searchResults").hide();
    $("#errorMessage").hide();
    $("table#requests tr.requestRow").remove();
    $("#iconBusy").show();
    $('#saveLinkContainer').fadeIn(700);
    
    let query = new LeafFormQuery();

    let batchSize = 1000;
    let offset = 0;
    let queryResult = {};
    let abortLoad = false;

    
    query.setLimit(offset, batchSize);
    query.setRootURL('./');
    query.importQuery(queryObj);
    query.onSuccess(function(res, resStatus, resJqXHR){
        queryResult = Object.assign(queryResult, res);

            if((Object.keys(res).length == batchSize
                    || resJqXHR.getResponseHeader('leaf-query') == 'continue')
                && !abortLoad) {
                $('#reportStats').html(`Loading ${offset}+ records <button id="btn_abort" class="buttonNorm">Stop</button>`);
                $('#btn_abort').on('click', function() {
                    abortLoad = true;
                });
                offset += batchSize;
                query.setLimit(offset, batchSize);
                query.execute();
            }
            else {
                let partialLoad = '';
                if(abortLoad) {
                    partialLoad = ' (partially loaded)';
                }
                $('#reportStats').html(`${Object.keys(queryResult).length} records${partialLoad}`);
                renderGrid(queryResult,thisSearchID, getReminder);
            }
    });
    
    query.execute();

}

function renderGrid(data,thisSearchID, getReminder){
    if (thisSearchID === searchID) {
        if (Object.keys(data).length) {
            let totalCount = 0;
            let requestsRow = "";
            $.each(data, function (index, value) {
                let displayRecord = true;
                // If this is email reminder list, then compare against give time period
                if (getReminder) {
                    // Get if we can show record for time period selected
                    if (value.action_history !== undefined) {
                        let numberActions = value.action_history.length;
                        let lastActionDate =
                            Number(
                                value.action_history[numberActions - 1]
                                    .time
                            ) * 1000;

                        // Current date minus selected reminder time period
                        let comparisonDate =
                            Date.now() - getReminder * 86400 * 1000;
                        if (lastActionDate >= comparisonDate) {
                            displayRecord = false;
                        }
                    } else {
                        console.log("No record to display");
                        displayRecord = false;
                    }
                }
                if (displayRecord) {
                    totalCount++;
                    requestsRow = '<tr class="requestRow">';
                    requestsRow +=
                        '<td><a href="index.php?a=printview&amp;recordID=' +
                        value.recordID +
                        '" target="_blank">' +
                        value.recordID +
                        "</a></td>";
                    requestsRow +=
                        "<td>" +
                        (value.categoryNames === undefined ||
                            value.categoryNames.length === 0
                            ? "non"
                            : value.categoryNames[0]) +
                        "</td>";
                    requestsRow +=
                        "<td>" +
                        (value.service == null ? "" : value.service) +
                        "</td>";
                    requestsRow += "<td>" + value.title + "</td>";
                    requestsRow +=
                        '<td><input type="checkbox" name="massActionRequest" class="massActionRequest" value="' +
                        value.recordID +
                        '"></td>';
                    requestsRow += "</tr>";
                    $("table#requests").append(requestsRow);
                }
            });

            if (totalCount == 0) {
                requestsRow = '<tr class="requestRow">';
                requestsRow +=
                    "<td colspan='5'>No records to display</td>";
                requestsRow += "</tr>";
                $("table#requests").append(requestsRow);
            }

            $("#searchResults").show();
        } else {
            $("#errorMessage").html("No Results").show();
        }
    }
    $("#iconBusy").hide();
}
/**
 * Executes the selected action on each request selected in the table
 */
function executeMassAction() {
    let selectedRequests = $("input.massActionRequest:checked");
    let reminderDaysSince = Number($("#lastAction").val());
    // Update global variables for execution - used in updateProgress function
    // Setting them to default at beginning of mass execution run
    processedRequests = 0;
    totalActions = selectedRequests.length;
    successfulActionRecordIDs = [];
    failedActionRecordIDs = [];

    if (totalActions) {
        $("button.takeAction").attr("disabled", "disabled");
    }
    $.each(selectedRequests, function (key, item) {
        let ajaxPath = "";
        let ajaxData = { CSRFToken: massActionToken };
        let recordID = $(item).val();
        switch (actionValue) {
            case "submit":
                ajaxPath = "./api/form/" + recordID + "/submit";
                break;
            case "cancel":
                ajaxPath = "./api/form/" + recordID + "/cancel";
                break;
            case "restore":
                ajaxPath = "./ajaxIndex.php?a=restore";
                ajaxData["restore"] = recordID;
                break;
            case "email":
                ajaxPath =
                    "./api/form/" + recordID + "/reminder/" + reminderDaysSince;
                break;
        }

        executeOneAction(recordID, ajaxPath, ajaxData);
    });
}

/**
 * Executes one ajax call to execute an action
 *
 * @param {int}                                 [recordID]                recordID for the record that the selected action is being applied to
 * @param {string}                [ajaxPath]                the api path for the selected action
 * @param {Object}                [ajaxData]                data object to pass to the selected ajaxPath
 */
function executeOneAction(recordID, ajaxPath, ajaxData) {
    $.ajax({
        type: "POST",
        url: ajaxPath,
        data: ajaxData,
        dataType: "text",
        cache: false,
    })
        .done(function () {
            successTrueFalse = true;
            updateProgress(recordID, successTrueFalse);
        })
        .fail(function (jqXHR, error, errorThrown) {
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
 * @param {int}                                 [recordID]                recordID for the record that the selected action is being applied to
 * @param {boolean} [success]                 true if the update is marking a success, false if a failure
 */
function updateProgress(recordID, success) {
    if (success) {
        successfulActionRecordIDs.push(recordID);
    } else {
        failedActionRecordIDs.push(recordID);
    }
    processedRequests++;
    setProgress("Completed: " + processedRequests + "/" + totalActions);
    if (processedRequests === totalActions) {
        if (failedActionRecordIDs.length > 0) {
            let alertMessage = "Action failed on the following requests:";
            $.each(failedActionRecordIDs, function (key, item) {
                alertMessage += "\n - ID: " + item;
            });
            alert(alertMessage);
        }

        doSearch();
        setProgress(
            successfulActionRecordIDs.length +
            " successes and " +
            failedActionRecordIDs.length +
            " failures of " +
            totalActions +
            " total."
        );

        $("button.takeAction").removeAttr("disabled");
    }
}

/**
 * Updates progress message
 *
 * @param {string}                [message]                 String to set into the progress area
 */
function setProgress(message) {
    $("div.progress").html(message);
}
