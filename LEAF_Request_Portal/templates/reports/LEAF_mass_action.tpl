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
    .buttonNorm.takeAction, .buttonNorm.buttonDaySearch {
        text-align: center;
        font-weight: bold;
        white-space: normal
    }
    #comment_required {
        transition: all 0.5s ease;
        color: #c00;
        font-weight: bolder;
    }
    #comment_required.attention {
        color: #fff;
        background-color: #c00;
    }
</style>
<!--{include file="site_elements/generic_confirm_xhrDialog.tpl"}-->
<script src="../libs/js/LEAF/intervalQueue.js"></script>

<div id="massActionContainer">
    <h1>Mass Action</h1>
    <div id="actionContainer">
        <label for="action"> Choose Action </label>
        <select id="action" name="action">
            <option value="">-Select-</option>
            <option value="cancel">Cancel</option>
            <option value="restore">Restore</option>
            <option value="submit">Submit</option>
            <option value="email">Email Reminder</option>
            <option value="take_action">Take Action</option>
        </select>
        <div id="form_container" style="padding: 2px;margin:0.75rem 0;"></div>
        <div id="step_container" style="padding: 2px;margin:0.75rem 0;"></div>
        <div id="requirements_container" style="padding: 2px;margin:0.75rem 0;"></div>
        <div id="relevant_action_container" style="padding: 2px;margin:0.75rem 0;"></div>
        <div id="comment_cancel_container" style="display:none;margin:0.75rem 0;">
            <label for="comment_cancel">Comment <span id="comment_required">* required</span></label>
            <textarea id="comment_cancel" rows="4" style="display:block;resize:vertical;width:530px;margin-top:2px"></textarea>
        </div>

    </div>
    <div id="progressContainer">
        <div id="progressbar"></div>
    </div>
    <div class="progress" style="text-align: center;"></div>

    <div id="searchRequestsContainer"></div>

    <div id="emailSection">
        <label for="lastAction">Days Since Last Action</label>
        <input type="number" id="lastAction" name="lastAction" value="7" maxlength="3" />
        <button class="buttonNorm buttonDaySearch" id="submitSearchByDays">Search Requests</button>
    </div>

    <img id="iconBusy" src="./images/indicator.gif" class="employeeSelectorIcon" alt="busy" />
    <button class="buttonNorm takeAction" style="text-align: center; font-weight: bold; white-space: normal; display: none">Take Action</button>
    <div id="searchResults" class="grid_table"></div>
    <button class="buttonNorm takeAction" style="text-align: center; font-weight: bold; white-space: normal; display: none">Take Action</button>
    <div id="errorMessage"></div>
</div>
<script>
// Global variables
let leafSearch;
let CSRFToken = '<!--{$CSRFToken}-->';
let orgChartPath = '<!--{$orgchartPath}-->';
let app_js_path = '<!--{$app_js_path}-->';
let processedRequests = 0;
let totalActions = 0;
let successfulActionRecordIDs = [];
let failedActionRecordIDs = [];
let dialog_confirm;
let searchID = "";
let extraTerms;
let actionValue;
let takeActionButton = document.querySelectorAll("button.takeAction");
let stepContainer = document.getElementById("step_container");
let relevantActionContainer = document.getElementById("relevant_action_container");
let requirementsContainer = document.getElementById("requirements_container");
let commentCancelContainer = document.getElementById("comment_cancel_container");
let searchResults = document.getElementById("searchResults");
let errorMessage = document.getElementById("errorMessage");

$(document).ready(function () {
    document.querySelector('title').innerText = 'Mass Actions - <!--{$title}-->';

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
        const commentValue = ($("#comment_cancel").val() || "").trim();
        if ((actionValue === "cancel" || actionValue === "take_action") && commentValue === "") {
            noteRequired();
        } else {
            dialog_confirm.setContent(
                '<img src="dynicons/?img=process-stop.svg&amp;w=48" alt="" style="float: left; padding-right: 24px" /> Are you sure you want to perform this action?'
            );

            dialog_confirm.setSaveHandler(function () {
                // hide all the extra stuff on the screen and show the progress bar
                $("#searchRequestsContainer, #searchResults, #errorMessage").hide();
                executeMassAction();
                dialog_confirm.hide();
            });
            dialog_confirm.show();
        }
    });

    // When changing any mass action, reset all record checkboxes to unchecked
    $(document).on("change", "input.massActionRequest", function () {
        $("input#selectAllRequests").prop("checked", false);
    });

    // Do the search from the input textbox if it is requested
    leafSearch = new LeafFormSearch("searchRequestsContainer");
    leafSearch.setJsPath(app_js_path);
    leafSearch.setRootURL("./");
    leafSearch.setOrgchartPath(orgChartPath);
    leafSearch.setSearchFunc(function (search) {
        extraTerms = search;
        searchID = Math.floor(Math.random() * 1000000000);
        listRequests(searchID);
    });
});

function noteRequired() {
    let elRequired = document.getElementById('comment_required');
    if(elRequired !== null) {
        elRequired.classList.add('attention');
        setTimeout(() => {
            elRequired.classList.remove('attention');
        }, 2500);
    }
}

/**
 * Purpose: Setup of choosing which action to take overall
 */
function chooseAction() {
    // If nothing selected and action selected is not 'Email Reminder'
    actionValue = $("#action").val();
    $("#comment_cancel").val("");
    $("#comment_cancel_container").hide();
    $("#form_container, #step_container, #relevant_action_container, #requirements_container, #emailSection").hide();
    document.getElementById("relevant_action_container").innerHTML = "";
    document.getElementById("step_container").innerHTML = "";
    document.getElementById("form_container").innerHTML = "";
    document.getElementById("requirements_container").innerHTML = "";
    let takeActionButton = document.querySelectorAll("button.takeAction");
    takeActionButton.forEach(tabutton => {
        tabutton.style.display = "none";
    });

    switch (actionValue) {
        case "cancel":
            // no break;
        case "restore":
            // no break;
        case "submit":
            $("#emailSection").hide();
            $("#searchRequestsContainer").show();

            if(actionValue === "cancel") {
                $("#comment_cancel_container").show();
            }

            leafSearch.init();
            searchID = Math.floor(Math.random() * 1000000000);
            listRequests(searchID);
            break;
        case "email":
            $("#emailSection, #searchRequestsContainer, #searchResults, #errorMessage").show();

            // When changing the time of last action, grab the value selected and search it
            $("#lastAction").change(function () {
                reminderDaysSearch();
            });

            $("#submitSearchByDays").click(function () {
                reminderDaysSearch();
            });

            leafSearch.init();
            reminderDaysSearch();
            break;
        case "take_action":
            // need to get forms and put them in the form_container as a drop down
            let forms = getForms();

            populateFormDropdown(forms);

            // show the form container
            $("#form_container").show();
            $("#searchRequestsContainer").hide();
            $("#searchResults").hide();
            break;
        default:
            $("#emailSection, #searchRequestsContainer, #searchResults, #errorMessage").hide();
            break;
    }
}

/**
 * Purpose: populate a dropdown with the form types
 */

function populateFormDropdown(forms) {
    let formContainer = document.getElementById("form_container");
    let formSelect = document.createElement("select");
    formSelect.id = "form_select";
    formSelect.name = "form_select";
    formSelect.onchange = function () {
        //$("#step_container, #relevant_action_container, #requirements_container, #comment_cancel_container, #searchResults, #errorMessage").hide();
        stepContainer.style.display = "none";
        relevantActionContainer.style.display = "none";
        requirementsContainer.style.display = "none";
        commentCancelContainer.style.display = "none";
        searchResults.style.display = "none";
        errorMessage.style.display = "none";

        takeActionButton.forEach(tabutton => {
            tabutton.style.display = "none";
        });

        let formID = this.value;
        let workflowID = formID.split("-")[1];
        let steps = getSteps();
        populateStepDropdown(steps, workflowID);
        $("#step_container").show();
    };

    let formOption = document.createElement("option");
    formOption.value = "";
    formOption.text = "-Select-";
    formSelect.appendChild(formOption);

    for (let i = 0; i < forms.length; i++) {
        if (forms[i].workflowID > 0) {
            let formOption = document.createElement("option");
            formOption.value = forms[i].categoryID + "-" + forms[i].workflowID;
            formOption.text = forms[i].categoryName;
            formSelect.appendChild(formOption);
        }
    }

    const labelElement = document.createElement('label');
    labelElement.setAttribute('for', 'form_select');
    labelElement.textContent = 'Select Form Type: ';

    formContainer.appendChild(labelElement);
    formContainer.appendChild(formSelect);
}

function populateStepDropdown(steps, formID) {
    if (formID !== undefined) {
        let stepContainer = document.getElementById("step_container");
        let stepSelect = document.createElement("select");
        stepSelect.id = "step_select";
        stepSelect.name = "step_select";
        stepSelect.onchange = function () {
            relevantActionContainer.style.display = "none";
            requirementsContainer.style.display = "none";
            commentCancelContainer.style.display = "none";
            searchResults.style.display = "none";
            errorMessage.style.display = "none";

            takeActionButton.forEach(tabutton => {
                tabutton.style.display = "none";
            });

            let stepID = $("select#step_select").val();
            let requirements = getRequirements(stepID);
            populateRequirementDropdown(requirements, stepID);
        };

        let stepOption = document.createElement("option");
        stepOption.value = "";
        stepOption.text = "-Select-";
        stepSelect.appendChild(stepOption);

        for (let i = 0; i < steps.length; i++) {
            let stepOption = document.createElement("option");

            if (steps[i].workflowID === Number(formID)) {
                stepOption.value = steps[i].stepID;
                stepOption.text = steps[i].stepTitle;
                stepSelect.appendChild(stepOption);
            }
        }

        const labelElement = document.createElement('label');
        labelElement.setAttribute('for', 'step_select');
        labelElement.textContent = 'Select Step: ';

        stepContainer.innerHTML = '';
        stepContainer.appendChild(labelElement);
        stepContainer.appendChild(stepSelect);
    }
}

function populateRequirementDropdown(requirements, stepID) {
    let requirementsContainer = document.getElementById("requirements_container");
    let requirementsSelect = document.createElement("select");
    requirementsSelect.id = "requirements_select";
    requirementsSelect.name = "requirements_select";
    requirementsSelect.onchange = function () {
        relevantActionContainer.style.display = "none";
        commentCancelContainer.style.display = "none";
        searchResults.style.display = "none";
        errorMessage.style.display = "none";

        takeActionButton.forEach(tabutton => {
            tabutton.style.display = "none";
        });

        let formID = $("select#form_select").val();
        let workflowID = formID.split("-")[1];
        let stepID = $("select#step_select").val();
        let actions = getActions(workflowID);
        populateActionDropdown(actions, stepID);
        $("#relevant_action_container").show();
    };

    let requirementsOption = document.createElement("option");
    requirementsOption.value = "";
    requirementsOption.text = "-Select-";
    requirementsSelect.appendChild(requirementsOption);

    for (let i = 0; i < requirements.length; i++) {
        if (requirements[i].stepID === Number(stepID)) {
            let requirementsOption = document.createElement("option");
            requirementsOption.value = requirements[i].dependencyID;
            requirementsOption.text = requirements[i].description;
            requirementsSelect.appendChild(requirementsOption);
        }
    }

    const labelElement = document.createElement('label');
    labelElement.setAttribute('for', 'requirements_select');
    labelElement.textContent = 'Select Requirement: ';

    requirementsContainer.innerHTML = '';
    requirementsContainer.appendChild(labelElement);
    requirementsContainer.appendChild(requirementsSelect);

    if (requirements.length > 1) {
        $("#requirements_container").show();
    } else {
        $("#requirements_container").hide();
        requirementsSelect.value = requirements[0].dependencyID;
        requirementsSelect.dispatchEvent(new Event('change'));
    }
}

function populateActionDropdown(actions, stepID) {
    let actionContainer = document.getElementById("relevant_action_container");
    let actionSelect = document.createElement("select");
    actionSelect.id = "action_select";
    actionSelect.name = "action_select";
    actionSelect.onchange = function () {
        let actionValue = document.getElementById("action").value;
        if(actionValue === "take_action") {
            $("#comment_cancel_container").show();
        }
        leafSearch.init();
        searchID = Math.floor(Math.random() * 1000000000);
        listRequests(searchID);
    };

    let actionOption = document.createElement("option");
    actionOption.value = "";
    actionOption.text = "-Select-";
    actionSelect.appendChild(actionOption);

    for (let i = 0; i < actions.length; i++) {
        if (actions[i].stepID === Number(stepID)) {
            let actionOption = document.createElement("option");
            actionOption.value = actions[i].actionType;
            actionOption.text = actions[i].actionText;
            actionSelect.appendChild(actionOption);
        }
    }

    const labelElement = document.createElement('label');
    labelElement.setAttribute('for', 'action_select');
    labelElement.textContent = 'Select Action: ';

    actionContainer.innerHTML = '';
    actionContainer.appendChild(labelElement);
    actionContainer.appendChild(actionSelect);
}

function getRequirements(stepID) {
    let requirements;

    $.ajax({
        type: "GET",
        url: "./api/workflow/step/" + stepID + "/dependencies",
        cache: false,
        success: function (res) {
            requirements = res;
        },
        error: function (err) {
            console.log(err);
        },
        async: false
    });

    return requirements;
}

function getActions(workflowID) {
    let actions;

    $.ajax({
        type: "GET",
        url: "./api/workflow/" + workflowID + "/route",
        cache: false,
        success: function (res) {
            actions = res;
        },
        error: function (err) {
            console.log(err);
        },
        async: false
    });

    return actions;
}

function getSteps() {
    let steps;

    $.ajax({
        type: "GET",
        url: "./api/workflow/steps",
        cache: false,
        success: function (res) {
            steps = res;
        },
        error: function (err) {
            console.log(err);
        },
        async: false
    });

    return steps;
}

/**
 * Purpose: need to get the form types and put them in the form_container as a drop down
 */

function getForms() {
    let forms;

    $.ajax({
        type: "GET",
        url: "./api/workflow/categoriesUnabridged",
        cache: false,
        success: function (res) {
            forms = res;
        },
        error: function (err) {
            console.log(err);
        },
        async: false
    });

    return forms;
}

/**
 * Purpose do reminder search (used by click or change of lastAction text)
 */
function reminderDaysSearch() {
    let daysSince = document.getElementById("lastAction").valueOf();
    searchID = Math.floor(Math.random() * 1000000000);
    listRequests(searchID);
}

function addTerms(leafFormQuery) {
    let actionValue = $("select#action").val();
    switch (actionValue) {
        case "cancel":
            leafFormQuery.addTerm('stepID', '!=', 'deleted');
            break;
        case "email":
            leafFormQuery.addTerm('stepID', '!=', 'deleted');
            let lastAction = document.getElementById("lastAction");

            if (Number(lastAction.value) > 0) {
                leafFormQuery.addTerm('stepID', '!=', 'resolved');
            }
            break;
        case "submit":
            leafFormQuery.addTerm('stepID', '!=', 'deleted');
            leafFormQuery.addTerm('stepID', '!=', 'submitted');
            break;
        case "restore":
            leafFormQuery.addTerm('stepID', '=', 'deleted');
            break;
        case "take_action":
            leafFormQuery.addTerm('stepID', '!=', 'deleted');
            getAction = document.getElementById("action_select").value;

            if (getAction !== "") {
                let stepID = $("select#step_select").val();
                let dependencyID = $("select#requirements_select").val();
                let formID = $("select#form_select").val();
                let categoryID = formID.split("-")[0];

                leafFormQuery.addTerm('categoryID', '=', categoryID);
                leafFormQuery.addTerm('stepID', '=', stepID);
                leafFormQuery.addDataTerm('dependencyID', dependencyID, '=');
            }
            break;
    }

    let isJSON = true;
    let advSearch = {};

    try {
        advSearch = $.parseJSON(extraTerms);
    } catch (err) {
        isJSON = false;
    }

    if (isJSON) {
        for (let i = 0; i < advSearch.length; i++) {
            if (advSearch[i]?.id === 'data' || advSearch[i]?.id === 'dependencyID') {
                leafFormQuery.addDataTerm(advSearch[i].id, advSearch[i].indicatorID, advSearch[i].operator, advSearch[i].match);
            } else {
                leafFormQuery.addTerm(advSearch[i].id, advSearch[i].operator, advSearch[i].match);
            }
        }
    } else if (typeof extraTerms === "string") {
        leafFormQuery.addTerm('title', 'LIKE', '*' + extraTerms.trim() + '*');
    }
}

function addJoins(leafFormQuery) {
    leafFormQuery.join("service");
    leafFormQuery.join("recordsDependencies");
    leafFormQuery.join("categoryName");
    leafFormQuery.join("status");

    let actionValue = $("select#action").val();
    let lastAction = document.getElementById("lastAction");

    if (actionValue === "email" && Number(lastAction.value) > 0) {
        leafFormQuery.join("action_history");
    }
}

function filterEmailData(result) {
    for (let item in result) {
        if (result[item].action_history !== undefined) {
            let numberActions = result[item].action_history.length;
            let lastActionDate = Number(result[item].action_history[numberActions - 1].time) * 1000;
            let lastAction = document.getElementById("lastAction");
            let comparisonDate = Date.now() - (Number(lastAction.value) * 24 * 60 * 60 * 1000);

            if (lastActionDate >= comparisonDate) {
                delete result[item];
            }
        } else {
            delete result[item];
        }
    };

    return result;
}

/**
 * Looks up requests based on filter/searchbar and builds table with the results
 *
 * @param {Object}                [queryObj]                                                Object to pass to form/query
* @param {Integer} [thisSearchID]                When done() is called, this param is compared to the global searchID. If they are not equal, then the results are not processed.
* @param {Number}                [getReminder]                 Number of days for email reminder selection
*/
async function listRequests(thisSearchID) {
    let searchResult = document.getElementById("searchResults");
    let errorMessage = document.getElementById("errorMessage");
    let iconBusy = document.getElementById("iconBusy");

    searchResult.style.display = "none";
    errorMessage.style.display = "none";
    iconBusy.style.display = "none";

    let leafFormQuery = new LeafFormQuery();
    leafFormQuery.setRootURL("./");
    leafFormQuery.clearTerms();
    addTerms(leafFormQuery);
    addJoins(leafFormQuery);
    leafFormQuery.onSuccess(result => {
        if (thisSearchID === searchID) {
            if (result instanceof Object && Object.keys(result).length > 0 && result[0] === undefined) {
                const formGrid = new LeafFormGrid('searchResults', {});
                formGrid.setRootURL("./");
                let lastAction = document.getElementById("lastAction");
                let action = document.getElementById("action");
                let filterData = result;

                if (action.value === 'email' && Number(lastAction.value) > 0) {
                    filterData = filterEmailData(result);
                }

                formGrid.setDataBlob(filterData);
                formGrid.setHeaders([
                    {
                        name: "Type",
                        indicatorID: "categoryNames",
                        callback: function (data, blob) {
                            let containerEl = document.getElementById(data.cellContainerID);
                            containerEl.innerText = blob[data.recordID]?.categoryNames?.[0] ?? "none";
                        }
                    },
                    {
                        name: "Service",
                        indicatorID: "service",
                        callback: function (data, blob) {
                            let containerEl = document.getElementById(data.cellContainerID);
                            containerEl.innerText = blob[data.recordID].service;
                        }
                    },
                    {
                        name: 'Title',
                        indicatorID: 'title',
                        callback: function(data, blob) {
                            $('#'+data.cellContainerID).html(blob[data.recordID].title);
                            $('#'+data.cellContainerID).on('click', function() {
                                window.open('index.php?a=printview&recordID='+data.recordID, 'LEAF', 'width=800,resizable=yes,scrollbars=yes,menubar=yes');
                            });
                        }
                    },
                    {
                        name: `<input type="checkbox" name="selectAllRequests" id="selectAllRequests" value="">`,
                        indicatorID: "checkboxes",
                        editable: false,
                        sortable: false,
                        callback: function(data, blob) {
                            $('#'+data.cellContainerID).html('<input type="checkbox" name="massActionRequest" class="massActionRequest" value="' + data.recordID + '">');
                        }
                    }
                ]);

                $("input#selectAllRequests").change(function () {
                    $("input.massActionRequest").prop("checked", $(this).is(":checked"));
                });

                formGrid.renderBody();
                let takeActionButton = document.querySelectorAll("button.takeAction");

                takeActionButton.forEach(tabutton => {
                    tabutton.style.display = "block";
                });

                if (searchResult !== null) {
                    searchResult.style.display = "block";
                }
            } else {
                if (errorMessage !== null) {
                    errorMessage.innerHTML = "No Results";
                    errorMessage.style.display = "block";
                }
            }
        }
    });

    leafFormQuery.execute();

    if (iconBusy !== null) {
        iconBusy.style.display = "none";
    }
}

/**
 * Executes the selected action on each request selected in the table
 */
function executeMassAction() {
    let progressbar = $('#progressbar').progressbar();
    $('#progressbar').attr('aria-label', `Searching for records`);

    let queue = new intervalQueue();
    const commentValue = ($("#comment_cancel").val() || "").trim();
    if ((actionValue === "cancel" || actionValue === "take_action") && commentValue === "") {
        noteRequired();
        return
    }

    let selectedRequests = $("input.massActionRequest:checked");
    let lastAction = document.getElementById("lastAction").value;
    let reminderDaysSince = Number(lastAction);

    // Update global variables for execution - used in updateProgress function
    // Setting them to default at beginning of mass execution run
    processedRequests = 0;
    totalActions = selectedRequests.length;
    successfulActionRecordIDs = [];
    failedActionRecordIDs = [];

    $('#progressbar').progressbar('option', 'max', totalActions);

    if (totalActions > 0) {
        $("button.takeAction").attr("disabled", "disabled");
    }
    $.each(selectedRequests, function (key, item) {
        let ajaxPath = "";
        let ajaxData = { CSRFToken: CSRFToken };
        let recordID = $(item).val();
        switch (actionValue) {
            case "submit":
                ajaxPath = "./api/form/" + recordID + "/submit";
                break;
            case "cancel":
                ajaxPath = "./api/form/" + recordID + "/cancel";
                ajaxData["comment"] = commentValue;
                break;
            case "restore":
                ajaxPath = "./ajaxIndex.php?a=restore";
                ajaxData["restore"] = recordID;
                break;
            case "email":
                ajaxPath =
                    "./api/form/" + recordID + "/reminder/" + reminderDaysSince;
                break;
            case "take_action":
                let dependencyID = $("select#requirements_select").val();

                ajaxPath = "./api/formWorkflow/" + recordID + "/apply";
                ajaxData["comment"] = commentValue;
                ajaxData["actionType"] = document.getElementById("action_select").value;
                ajaxData["dependencyID"] = Number(dependencyID);

                break;
        }
        queue.push({ recordID, ajaxPath, ajaxData });
    });

    queue.setWorker(item => {
        $('#progressContainer').slideDown();
        $('#progressbar').progressbar('option', 'value', queue.getLoaded());
        return new Promise((resolve, reject) => {
            $.ajax({
                type: "POST",
                url: item.ajaxPath,
                data: item.ajaxData,
                dataType: "text",
                cache: false,
            }).done(function () {
                successTrueFalse = true;
                updateProgress(item.recordID, successTrueFalse);
                resolve();
            }).fail(function (jqXHR, error, errorThrown) {
                successTrueFalse = false;
                updateProgress(item.recordID, successTrueFalse);
                console.log(jqXHR);
                console.log(error);
                console.log(errorThrown);
                reject();
            });
        });
    });

    queue.start().then(res => {
        $('#progressContainer').slideUp();
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

        searchID = Math.floor(Math.random() * 1000000000);
        listRequests(searchID);

        setProgress(
            successfulActionRecordIDs.length +
                " successes and " +
                failedActionRecordIDs.length +
                " failures of " +
                totalActions +
                " total."
        );

        $("button.takeAction").removeAttr("disabled");
        $("#comment_cancel").val("");
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
</script>