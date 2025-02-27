<style>
    #import_data_existing_form, #import_data_new_form, #uploadBox, #toggler {
        padding: 20px;
    }

    #category_indicators thead tr, #new_form_indicators thead tr {
        background-color: rgb(185, 185, 185);
    }

    #category_indicators thead tr th, #new_form_indicators thead tr th {
        padding: 7px;
    }

    #category_indicators td, #new_form_indicators td {
        padding: 7px;
    }
    #category_select {
        max-width: 600px;
    }

    .modalBackground {
        width: 100%;
        height: 100vh;
        z-index: 5;
        position: fixed;
        background-color: grey;
        margin-top: 0px;
        margin-left: 0px;
        opacity: 0.5;
    }
    .ui-progressbar-value {
        background-color: #28a0cb;
    }

</style>
<script type="text/javascript" src="https://cdn.jsdelivr.net/gh/SheetJS/js-xlsx@1eb1ec/dist/xlsx.full.min.js"></script>
<script type="text/javascript" src="https://cdn.jsdelivr.net/gh/SheetJS/js-xlsx@64798fd/shim.js"></script>
<script type="text/javascript" src="js/lz-string/lz-string.min.js"></script>
<script src="<!--{$app_js_path}-->/LEAF/intervalQueue.js"></script>

<script src="<!--{$app_js_path}-->/jquery/jquery-ui.custom.min.js"></script>
<script src="<!--{$app_js_path}-->/promise-pollyfill/polyfill.min.js"></script>

<div id="status" style="background-color: black; color: white; font-weight: bold; font-size: 140%"></div>
<div id="uploadBox">
    <h4><label for="sheet_upload">Choose a Spreadsheet</label></h4>
    The first row of the file must be headers for the columns.
    <br/>

    <input id="sheet_upload" type="file"/>

    <br />
    <br />
</div>
<div id="toggler" style="display: none">
    <fieldset>
        <legend>Import Type</legend>
        <label for="newFormToggler">New Form<label>
        <input id="newFormToggler" name="toggle" style="margin-right: 1rem;" onclick="toggleImport(event)" type="radio" />
        <label for="existingFormToggler">Existing Form<label>
        <input id="existingFormToggler" name="toggle" onclick="toggleImport(event)" type="radio" />
    </fieldset>
</div>
<div id="import_data_new_form" style="display: none;">
    <h4>Create a Form</h4>
    <button id="import_btn_new" type="button">Import</button>
    <input id="preserve_new" type="checkbox" name="preserve_new"/>
    <label for="preserve_new">Preserve Row Order?</label>
    <br/><br/>
    <label for="formTitleInput"><b>Title of Form</b></label>
    <input type="text" id="formTitleInput" />
    This will be the title for the custom form.
    <br/><br/>
    <label for="formDescription"><b>Description of Form</b></label>
    <input type="text" id="formDescription" />
    Enter a short description.
    <br/><br/>
    <span id="formWorkflowSelect">
    </span>
    <br/><br/>
    <label for="title_input_new"><b>Title of Requests</b></label>
    <input type="text" id="title_input_new" />
    (Required) This will be the title for all imported requests.
    <br/><br/>
</div>
<div id="import_data_existing_form" style="display: none;">
    <label for="category_select"><b>Select a Form</b></label>
    <select id="category_select"></select>

    <button id="import_btn_existing" type="button">Import</button>
    <input id="preserve_existing" type="checkbox" name="preserve_existing"/>
    <label for="preserve_existing">Preserve Row Order?</label>

    <br/><br/>

    <label for="title_input_existing"><b>Title of Requests</b></label>
    <input type="text" id="title_input_existing" />
    (Required) This will be the title for all imported requests.

    <br/><br/>

    <table id="category_indicators">
        <thead>
            <tr>
                <th>ID</th>
                <th>Name</th>
                <th>Format</th>
                <th>Description</th>
                <th>Required</th>
                <th>Sensitive</th>
                <th>Sheet Column</th>
            </tr>
        </thead>
        <tbody></tbody>
    </table>
</div>
<div id="request_status" style="padding: 20px;"></div>

<!--{include file="site_elements/generic_confirm_xhrDialog.tpl"}-->

<div id="dialog" title="Import Status" style="z-index:100;">
    <div class="progress-label">Starting import...</div>
    <div id="progressbar"></div>
</div>

<div id="modal-background"></div>

<script>
    var CSRFToken = '<!--{$CSRFToken}-->';
    var orgChartPath = '<!--{$orgchartPath}-->';

    var nexusAPI = LEAFNexusAPI();
    nexusAPI.setBaseURL(orgChartPath + '/api/?a=');
    nexusAPI.setCSRFToken(CSRFToken);

    var portalAPI = LEAFRequestPortalAPI();
    portalAPI.setBaseURL('./api/?a=');
    portalAPI.setCSRFToken(CSRFToken);

    var categorySelect = $('#category_select');
    var categoryIndicators = $('#category_indicators tbody');
    var fileSelect = $('#file_select');
    var importBtnExisting = $('#import_btn_existing');
    var importBtnNew = $('#import_btn_new');
    var titleInputExisting = $('#title_input_existing');
    var titleInputNew = $('#title_input_new');
    var formTitle = $('#formTitleInput');
    var formDescription = $('#formDescription');
    var newForm = $('#import_data_new_form');
    var existingForm = $('#import_data_existing_form');
    var toggler = $('#toggler');
    var requestStatus = $('#request_status');
    var sheetUpload = $('#sheet_upload');
    var nameOfSheet = '';
    var placeInOrder;

    var totalRecords;


    var totalImported = 0;
    var createdRequests = 0;
    var failedRequests = [];
    var currentIndicators = [];
    var indicatorArray = [];
    var blankIndicators = [];
    var sheet_data = {};
    var dialog_confirm = new dialogController(
        'confirm_xhrDialog',
        'confirm_xhr',
        'confirm_loadIndicator',
        'confirm_button_save',
        'confirm_button_cancelchange'
    );

    function toggleImport(e) {
        if(e.target.id === "newFormToggler") {
            newForm.css('display', 'block');
            existingForm.css('display', 'none');
        } else if (e.target.id === "existingFormToggler") {
            newForm.css('display', 'none');
            existingForm.css('display', 'block');
        }
    }

    function checkFormatNew(e, column) {
        if ($(e.target).val() === 'orgchart_employee') {
            checkFormatExisting(column);
        }
    }

    function checkFormatExisting(column) {
        for (var i = 1; i < sheet_data.cells.length; i++) {
            var value = typeof (sheet_data.cells[i]) !== "undefined" && typeof (sheet_data.cells[i][column]) !== "undefined" ? sheet_data.cells[i][column].toString() : '';
            if (value.indexOf('@va.gov') === -1 && value.indexOf(' ') === -1 && value.indexOf(',') === -1 && value.indexOf('VHA') === -1 && value.indexOf('VACO') === -1) {
                alert('The column for employees should be either an email, username, or "Last name, First Name".');
                break;
            }
        }
    }

    function buildFormat(spreadSheet) {
        $('#new_form_indicators').remove();
        var table =
            '<table id="new_form_indicators" style="text-align: center;">' +
            '   <thead>' +
            '       <tr>' +
            '           <th scope="col"> Sheet Column </th>' +
            '           <th scope="col"> Name </th>' +
            '           <th scope="col"> Format </th>' +
            '           <th scope="col"> Required </th>' +
            '           <th scope="col"> Sensitive </th>' +
            '       </tr>' +
            '   <thead>' +
            '   <tbody>';
        $.each(spreadSheet.headers, function(key, value) {
            var requiredCheckbox = blankIndicators.indexOf(key) === -1 ? '<input type="checkbox"/>' : '<input type="checkbox" onclick="return false;" disabled="disabled" title="Cannot set as required when a row in this column is blank."/>';
            table +=
                '<tr>' +
                '   <td>' + key + '</td>' +
                '   <td>' + value + '</td>' +
                '   <td>' +
                '       <select onchange="checkFormatNew(event, \'' + key + '\')">' +
                '           <option value="text">Single line text</option>' +
                '           <option value="textarea">Multi-line text</option>' +
                '           <option value="number">Numeric</option>' +
                '           <option value="currency">Currency</option>' +
                '           <option value="date">Date</option>' +
                '           <option value="currency">Currency</option>' +
                '           <option value="orgchart_group">Orgchart group</option>' +
                '           <option value="orgchart_position">Orgchart position</option>' +
                '           <option value="orgchart_employee">Orgchart employee</option>' +
                '       </select>' +
                '   </td>' +
                '   <td>' + requiredCheckbox + '</td>' +
                '   <td><input type="checkbox"/></td>' +
                '</tr>';
        });
        table += '</tbody></table>';
        newForm.append(table);
    }

    function alphaToNum(alpha) {

        var i = 0,
            num = 0,
            len = alpha.length;

        for (; i < len; i++) {
            num = num * 26 + alpha.charCodeAt(i) - 0x40;
        }

        return num - 1;
    }
    function numToAlpha(num) {

        var alpha = '';

        for (; num >= 0; num = parseInt(num / 26, 10) - 1) {
            alpha = String.fromCharCode(num % 26 + 0x41) + alpha;
        }

        return alpha;
    }
    function _buildColumnsArray(range) {

        var i,
            res = [],
            rangeNum = range.split(':').map(function (val) {
                return alphaToNum(val.replace(/[0-9]/g, ''));
            }),
            start = rangeNum[0],
            end = rangeNum[1] + 1;

        for (i = start; i < end; i++) {
            res.push(numToAlpha(i));
        }

        return res;
    }

    function searchBlankRow(e) {
        if (blankIndicators.indexOf($(e.target).val()) > -1) {
            $(e.target).val("-1");
            alert('Column can\'t be selected because it contains blank entries.');
        }
    }

    /* build the select input with options for the given indicator
    the indicatorID corresponds to the select input id */
    function buildSheetSelect(indicatorID, sheetData, required, format) {
        var select = $(document.createElement('select'))
            .attr('id', indicatorID + '_sheet_column')
            .attr('class', 'indicator_column_select');

        if (required === "1") {
            select.attr('onchange', 'searchBlankRow(event);');
        }

        /* "blank" option */
        var option = $(document.createElement('option'))
            .attr('value', '-1')
            .html('');

        select.append(option);

        /* the value of each option is the column header, which is the key of the sheetData.headers object */
        var keys = Object.keys(sheetData.headers);
        for (var i = 0; i < keys.length; i++) {
            var option = $(document.createElement('option'))
                .attr('value', keys[i])
                .html(keys[i] + ': ' + sheetData.headers[keys[i]]);

            select.append(option);
        }
        if (format === "orgchart_employee") {
            select.attr('onchange', 'checkFormatExisting($("option:selected", this).val());');
        }

        return select;
    }

    /* build the table row and data (<tr> and <td>) for the given indicator */
    function buildIndicatorRow(indicator) {
        if (indicator.format === '') {
            return '';
        }

        var row = $(document.createElement('tr'));

        var iid = $(document.createElement('td'))
            .html(indicator.indicatorID)
            .appendTo(row);

        var indicatorName = $(document.createElement('td'))
            .html(indicator.name)
            .appendTo(row);

        var indicatorFormat = $(document.createElement('td'))
            .html(indicator.format)
            .appendTo(row);

        var indicatorDesc = $(document.createElement('td'))
            .html(indicator.description)
            .appendTo(row);

        var indicatorRequired = $(document.createElement('td'))
            .html(indicator.required === "1" ? "YES" : "NO")
            .appendTo(row);

        var indicatorSensitive = $(document.createElement('td'))
            .html(indicator.is_sensitive === "1" ? "YES" : "NO")
            .appendTo(row);

        var columnSelect = $(document.createElement('td'))
            .append(buildSheetSelect(indicator.indicatorID, sheet_data, indicator.required, indicator.format))
            .appendTo(row);

        indicatorArray.push({'indicatorID': indicator.indicatorID, 'format': indicator.format});

        return row;
    }

    function generateReport(title) {
        urlTitle = "Requests have been generated for each row of the imported spreadsheet";
        urlQueryJSON = '{"terms":[{"id":"title","operator":"LIKE","match":"*' + title + '*"},{"id":"deleted","operator":"=","match":0}],"joins":["service"],"sort":{}}';
        urlIndicatorsJSON = '[{"indicatorID":"","name":"","sort":0},{"indicatorID":"title","name":"","sort":0}]';

        urlTitle = encodeURIComponent(btoa(urlTitle));
        urlQuery = encodeURIComponent(LZString.compressToBase64(urlQueryJSON));
        urlIndicators = encodeURIComponent(LZString.compressToBase64(urlIndicatorsJSON));

        $('#status').html('Data has been imported');
        requestStatus.html(
            'Import Completed! ' + createdRequests + ' requests made, ' + failedRequests.length + ' failures.<br/><br/>' +
            '<a class="buttonNorm" role="button" href="./?a=reports&v=3&title=' + urlTitle + '&query=' + urlQuery + '&indicators=' + urlIndicators + '">View Report<\a>'
        );
        if (failedRequests.length > 0) {
            requestStatus.append(
                '<br/><br/>' +
                'Failed to import values: <br/>' + failedRequests.join("<br/>"))
        }
    }

    function updateReportStatus(title) {
        requestStatus.html(createdRequests + ' out of ' + (sheet_data.cells.length - 1) + ' requests completed, ' + failedRequests.length + ' failures.');
        if (failedRequests.length === (sheet_data.cells.length - 1)) {
            requestStatus.html('All requests failed!  See log for details.');
            requestStatus.append(
                '<br/><br/>' +
                'Failed to import values: <br/>' + failedRequests.join("<br/>"));
            $('#status').html('Import has failed');
            failedRequests = new Array();
        } else if (createdRequests + failedRequests.length === (sheet_data.cells.length - 1)) {
            generateReport(title);
        }
    }

    function handleMakeRequestFail(requestData, title, msg = "") {
        failedRequests.push(requestData);
        updateReportStatus(title);
        console.log(msg)
    }

    function makeRequests(categoryID, requestData, preserveOrder) {
        const title = $('input[name="toggle"]:checked').attr('id') === 'newFormToggler' ? titleInputNew.val() : titleInputExisting.val();

        return new Promise((resolve, reject) => {
            if (typeof (requestData['failed']) !== "undefined") {
                failedRequests.push(requestData['failed']);
                resolve();
            } else {
                $.ajax({
                    method: 'POST',
                    url: './api/form/new',
                    data: {
                        CSRFToken: CSRFToken,
                        ['num' + categoryID]: 1,
                        title: requestData.title,
                    },
                    dataType: 'json',
                    async: !preserveOrder,
                    success(recordID) {
                        delete requestData.title;
                        requestData['CSRFToken'] = CSRFToken;

                        $.ajax({
                            method: 'POST',
                            url: './api/form/' + recordID,
                            data: requestData,
                            dataType: 'json',
                            success(result) {
                                if (result > 0) {
                                    if (recordID > 0) {
                                        createdRequests++;
                                        requestStatus.html(createdRequests + ' out of ' + (sheet_data.cells.length - 1) + ' requests completed, ' + failedRequests.length + ' failures.');
                                    } else {
                                        failedRequests.push('Error creating request for the following data: ' + requestData);
                                    }
                                    updateReportStatus(title);
                                    resolve();
                                } else {
                                    handleMakeRequestFail(requestData, title, result)
                                    resolve();
                                }
                            },
                            error(err) {
                                handleMakeRequestFail(requestData, title, err)
                                resolve();
                            }
                        });
                    },
                    error(err) {
                        handleMakeRequestFail(requestData, title, err)
                        resolve();
                    }
                });
            }
        });
    }

    // Converts Excel Date into a Short Date String
    // param excelDate int date in excel formatted integer field
    // return formattedJSDate MM/DD/YYY formatted string of excel date
    function convertExcelDateToShortString(excelDate) {
        var jsDate = new Date((excelDate - (25567 + 1))*86400*1000);
        var formattedJSDate = (jsDate.getMonth() + 1) + '/' + jsDate.getDate() + '/' + jsDate.getFullYear();
        return formattedJSDate;
    }

    $(function () {
        document.querySelector('title').innerText = 'Import Spreadsheet - <!--{$title}-->';
        $("body").prepend($("#modal-background"));
        var progressTimer;
        var progressbar = $( "#progressbar" );
        var progressLabel = $( ".progress-label" );
        var dialog = $( "#dialog" ).dialog({
            autoOpen: false,
            closeOnEscape: false,
            resizable: false,
            open: function() {
                $("#modal-background").addClass("modalBackground");
                 $(".ui-dialog-titlebar-close").hide();
                progressTimer = setTimeout( progress, 2000 );
            },
            close: closeImport
        });

        progressbar.progressbar({
            value: false,
            change: function() {
                progressLabel.text( "Current Progress: " + progressbar.progressbar( "value" ) + "%" );

            },
            complete: function() {
                 $(".ui-dialog-titlebar-close").show();
            }
        });

        function closeImport() {
            $("#modal-background").removeClass("modalBackground");
            clearTimeout( progressTimer );
            dialog.dialog( "close" );
            progressbar.progressbar( "value", false );
            progressLabel.text( "Starting import..." );
            progressbar.progressbar( "value", 0);
            createdRequests = 0;
            failedRequests = new Array();
        }

        function progress() {
            var val = progressbar.progressbar( "value" ) || 0;

            progressbar.progressbar(
                "value",
                Math.floor(
                    100 * (createdRequests + failedRequests.length)/totalRecords
                )
            );

            if ( val <= 99 ) {
                progressTimer = setTimeout( progress, 50 );
            }
        }

        /*builds select options of workflows */
        portalAPI.Workflow.getAllWorkflows(
            function(msg) {
                if(msg.length > 0) {
                    var buffer = '<label for="workflowID"><b>Workflow of Form</b></label><select id="workflowID">';
                    buffer += '<option value="0">No Workflow</option>';
                    for(var i in msg) {
                        buffer += '<option value="'+ msg[i].workflowID +'">'+ msg[i].description +' (ID: #'+ msg[i].workflowID +')</option>';
                    }
                    buffer += '</select>    This will be the workflow for the custom form.\n';
                    $('#formWorkflowSelect').html(buffer);
                }
            },
            function (err) {
                console.log(err);
            }
        );

        function importNew() {
            let queue = new intervalQueue();
            queue.setConcurrency(3);

            $('#status').html('Processing...'); /* UI hint */
            var newFormIndicators = $('#new_form_indicators');
            var workflowID = $('#workflowID > option:selected').val();
            var formName = formTitle.val() === '' ? nameOfSheet : formTitle.val();
            var formData = {"name": formName, "description": formDescription.val()};
            var indicators = [];
            var newCategoryID = '';
            var preserveOrder = $("#preserve_new").prop("checked");
            totalImported = 0;
            requestStatus.html('Making custom form...');

            /* creates custom form */
            portalAPI.FormEditor.createCustomForm(
                formData.name,
                formData.description,
                function(categoryID) {
                    newCategoryID = categoryID.replace(/"/g, "");
                    if (workflowID > 0) {
                        portalAPI.FormEditor.assignFormWorkflow(
                            newCategoryID.replace(/"/g, ""),
                            workflowID,
                            function (msg) {
                                requestStatus.html('Workflow assigned...');
                            },
                            function (err) {
                                console.log(err);
                            }
                        );
                    }
                    requestStatus.html('Form created, adding questions...');
                    var formCreationIndex = 0;
                    var indicatorTableRows = newFormIndicators.children('tbody').find('tr');

                    /* parses user's input and makes an indicator for each row of the indicator table */
                    function makeIndicator() {
                        /* Creates indicators synchronously, then moves on to next step of filling out requests */
                        if (formCreationIndex < indicatorTableRows.length) {
                            $.ajax({
                                method: 'POST',
                                url: './api/formEditor/newIndicator',
                                dataType: "text",
                                async: false,
                                data: {
                                    name: $("td:eq(1)", indicatorTableRows[formCreationIndex]).html(),
                                    format: $("td:eq(2) > select > option:selected", indicatorTableRows[formCreationIndex]).val(),
                                    categoryID: newCategoryID,
                                    required:  $("td:eq(3) > input", indicatorTableRows[formCreationIndex]).is(":checked") === true ? 1 : 0,
                                    is_sensitive: $("td:eq(4) > input", indicatorTableRows[formCreationIndex]).is(":checked") === true ? 1 : 0,
                                    CSRFToken: CSRFToken
                                },
                                success(indicatorID) {
                                    /* adds index by 1, pushes indicator to array, makes next indicator */
                                    formCreationIndex++;
                                    indicators.push(indicatorID.replace(/"/g, ""));
                                    requestStatus.html(indicators.length.toString() + ' out of ' + indicatorTableRows.length + ' questions added.');
                                    makeIndicator();
                                },
                                error(err) {
                                    alert("Error creating form.  See log for details.");
                                }
                            });

                        } else {
                            requestStatus.html(indicators.length.toString() + ' out of ' + indicatorTableRows.length + ' questions added.');
                            requestStatus.html('Filling out form...');

                            var indicatorArray = Object.keys(indicators).map(function(e) {
                                return indicators[e]
                            });

                            function selectRowToAnswer(i) {
                                return new Promise(function(resolve, reject) {
                                    var titleIndex = i;
                                    var completed = 0;
                                    var row = sheet_data.cells[titleIndex];
                                    var requestData = new Object();
                                    
                                    function answerQuestions() {
                                        return new Promise(function(resolve, reject) {
                                            if (completed >= indicatorArray.length) {
                                                requestData['title'] = titleInputNew.val() + '_' + titleIndex;
                                                queue.push({
                                                    categoryID: newCategoryID,
                                                    requestData: requestData,
                                                });
                                                resolve();

                                            } else if (titleIndex <= sheet_data.cells.length - 1) {
                                                var currentCol = newFormIndicators.find('tbody > tr:eq(' + completed + ') > td:first').html();
                                                var currentFormat = newFormIndicators.find('tbody > tr:eq(' + completed + ') > td:eq(2) > select > option:selected').val();
                                                switch (currentFormat) {
                                                    case 'orgchart_employee':
                                                        var sheetEmp = typeof (row[currentCol]) !== "undefined" && row[currentCol] !== null && !$.isNumeric(row[currentCol]) ? row[currentCol].toString() : '';
                                                        nexusAPI.Employee.getByEmailNational({
                                                            'onSuccess': function (user) {
                                                                var res = Object.keys(user);
                                                                var emp = user[res[0]];
                                                                if (typeof (emp) !== "undefined" && emp !== null && res.length === 1) {
                                                                    nexusAPI.Employee.importFromNational({
                                                                        'onSuccess': function (results) {
                                                                            if (!isNaN(results)) {
                                                                                requestData[indicatorArray[completed]] = parseInt(results);
                                                                            } else {
                                                                                requestData['failed'] = currentCol + titleIndex + ': Employee ' + sheetEmp + ' not found. Error: '+ results;
                                                                            }
                                                                            completed++;
                                                                            answerQuestions().then(function(){resolve();});
                                                                        },
                                                                        'onFail': function (err) {
                                                                            requestData['failed'] = currentCol + titleIndex + ": Error retrieving employee on sheet row " + titleIndex + " for indicator " + formCreationIndex;
                                                                            completed++;
                                                                            answerQuestions().then(function(){resolve();});
                                                                        },
                                                                        'async': true
                                                                    }, emp.userName);
                                                                } else if (res.length > 1) {
                                                                    requestData['failed'] = currentCol + titleIndex + ': Multiple employees found for ' + sheetEmp + '.  Make sure it is in the correct format.';
                                                                    completed++;
                                                                    answerQuestions().then(function(){resolve();});
                                                                } else {
                                                                    requestData['failed'] = currentCol + titleIndex + ': Employee ' + sheetEmp + ' not found.';
                                                                    completed++;
                                                                    answerQuestions().then(function(){resolve();});
                                                                }
                                                            },
                                                            'onFail': function (err) {
                                                                requestData['failed'] = currentCol + titleIndex + ": Error retrieving email for employee on sheet row " + titleIndex + " indicator " + formCreationIndex;
                                                                completed++;
                                                                answerQuestions().then(function(){resolve();});
                                                            },
                                                            'async': true
                                                        }, sheetEmp);
                                                        break;
                                                    case 'orgchart_group':
                                                        var sheetGroup = typeof (row[currentCol]) !== "undefined" && row[currentCol] !== null ? row[currentCol].toString() : '';
                                                        nexusAPI.Groups.searchGroups({
                                                            'onSuccess': function (groups) {
                                                                if (groups.length === 1) {
                                                                    var grp = groups[Object.keys(groups)[0]];
                                                                    requestData[indicatorArray[completed]] = parseInt(grp.groupID);
                                                                } else if (groups.length > 1) {
                                                                    requestData['failed'] = currentCol + titleIndex + ': Multiple groups found for ' + sheetGroup + '.  Make sure that the name is exact.';
                                                                } else {
                                                                    requestData['failed'] = currentCol + titleIndex + ': Group ' + sheetGroup + ' not found.';
                                                                }
                                                                completed++;
                                                                answerQuestions().then(function(){resolve();});
                                                            },
                                                            'onFail': function (err) {
                                                                requestData['failed'] = currentCol + titleIndex + ": Error retrieving group on sheet row " + titleIndex + " indicator " + formCreationIndex;
                                                                completed++;
                                                                answerQuestions().then(function(){resolve();});
                                                            },
                                                            'async': true
                                                        }, sheetGroup);
                                                        break;
                                                    case 'orgchart_position':
                                                        var sheetPosition = typeof (row[currentCol]) !== "undefined" && row[currentCol] !== null ? row[currentCol].toString() : '';
                                                        nexusAPI.Positions.searchPositions({
                                                            'onSuccess': function (positions) {
                                                                if (positions.length === 1) {
                                                                    var pos = positions[Object.keys(positions)[0]];
                                                                    requestData[indicatorArray[completed]] = parseInt(pos.positionID);
                                                                } else if (positions.length > 1) {
                                                                    requestData['failed'] = currentCol + titleIndex + ': Multiple positions found for ' + sheetPosition + '.  Make sure that the name is exact.';
                                                                } else {
                                                                    requestData['failed'] = currentCol + titleIndex + ': Position ' + sheetPosition + ' not found.';
                                                                }
                                                                completed++;
                                                                answerQuestions().then(function(){resolve();});
                                                            },
                                                            'onFail': function (err) {
                                                                requestData['failed'] = currentCol + titleIndex + ": Error retrieving group on sheet row " + titleIndex + " indicator " + formCreationIndex;
                                                                completed++;
                                                                answerQuestions().then(function(){resolve();});
                                                            },
                                                            'async': true
                                                        }, sheetPosition);
                                                        break;
                                                    case 'date':
                                                        var cellDate = typeof (row[currentCol]) !== "undefined" && row[currentCol] !== null ? row[currentCol].toString() : '';

                                                        // check if excel formatted number
                                                        if (!isNaN(cellDate) && cellDate !== '') {
                                                            var convertedDate = convertExcelDateToShortString(parseInt(cellDate));
                                                            requestData[indicatorArray[completed]] = convertedDate;
                                                        } else {
                                                            requestData[indicatorArray[completed]] = cellDate;
                                                        }

                                                        completed++;
                                                        answerQuestions().then(function(){resolve();});
                                                        break;
                                                    default:
                                                    requestData[indicatorArray[completed]] = row[currentCol];
                                                    completed++;
                                                    answerQuestions().then(function(){resolve();});
                                                    break;
                                                }
                                            }
                                        });
                                	}

                                	answerQuestions().then(function(res) {
                                        resolve();
                                    });
                                });
                            }

                            /* iterate through the sheet cells, which are organized by row */
                            totalRecords = sheet_data.cells.length - 1;
                            dialog.dialog( "open" );

                            if(preserveOrder){
                                placeInOrder = 1;
                                selectRowToAnswer(placeInOrder).then(iterate);

                                function iterate(){
                                    placeInOrder++;
                                    totalImported++;
                                    if(placeInOrder <= sheet_data.cells.length -1){
                                        selectRowToAnswer(placeInOrder).then(iterate);
                                    }
                                }

                            } else {
                                for (var i = 1; i <= sheet_data.cells.length - 1; i+=2) {

                                    var doublet = [];
                                    doublet.push(selectRowToAnswer(i));

                                    var addAnother = i+1 <= sheet_data.cells.length - 1;
                                    if(addAnother){
                                        doublet.push(selectRowToAnswer(i+1));
                                    }

                                    Promise.all(doublet).then(function(results){
                                        totalImported += results.length;
                                    });
                                }
                            }
                            queue.setWorker(item => makeRequests(item.categoryID, item.requestData, preserveOrder));
                            queue.start().then(res => {
                                progressbar.progressbar("value", 100);
                                $('#status').html('Data has been imported');
                            });
                        }
                    }
                    makeIndicator();
                },
                function (err) {
                    console.log(err)
                }
            );
        }

        function importExisting() {
            let queue = new intervalQueue();
            queue.setConcurrency(3);

            totalImported = 0;
            $('#status').html('Processing...'); /* UI hint */
            requestStatus.html('Parsing sheet data...');
            var preserveOrder = $("#preserve_existing").prop("checked");

            function selectRowToAnswer(i) {
                return new Promise(function(resolve,reject) {
                    var titleIndex = i;
                    var completed = 0;
                    var row = sheet_data.cells[titleIndex];
                    var requestData = new Object();

                    function answerQuestions() {
                        return new Promise(function(resolve, reject) {
                            if (completed === indicatorArray.length) {
                                requestData['title'] = titleInputExisting.val() + '_' + titleIndex;
                                queue.push({
                                    categoryID: categorySelect.val(),
                                    requestData: requestData,
                                });
                                resolve();

                            } else {
                                var indicatorColumn = $('#' + indicatorArray[completed].indicatorID + '_sheet_column').val();

                                /* skips indicators that aren't set*/
                                if (indicatorColumn === "-1") {
                                    completed++;
                                    answerQuestions().then(function(){resolve();});

                                } else {
                                    var currentIndicator = indicatorArray[completed].indicatorID;
                                    var currentFormat = indicatorArray[completed].format;
                                    switch (currentFormat) {
                                        case 'orgchart_employee':
                                            var sheetEmp = typeof (row[indicatorColumn]) !== "undefined" && row[indicatorColumn] !== null ? row[indicatorColumn].toString() : '';
                                            nexusAPI.Employee.getByEmailNational({
                                                'onSuccess': function (user) {
                                                    var res = Object.keys(user);
                                                    var emp = user[res[0]];
                                                    if (typeof (emp) !== "undefined" && emp !== null && res.length === 1) {
                                                        nexusAPI.Employee.importFromNational({
                                                            'onSuccess': function (results) {
                                                                if (!isNaN(results)) {
                                                                    requestData[currentIndicator] = parseInt(results);
                                                                } else {
                                                                    requestData['failed'] = indicatorColumn + titleIndex + ': Employee ' + sheetEmp + ' not found. Error: '+ results;
                                                                }
                                                                completed++;
                                                                answerQuestions().then(function(){resolve();})
                                                            },
                                                            'onFail': function (err) {
                                                                requestData['failed'] = indicatorColumn + titleIndex + ": Error retrieving employee on sheet row " + titleIndex + " for indicator " + index;
                                                                completed++;
                                                                answerQuestions().then(function(){resolve();})
                                                            },
                                                            'async': true
                                                        }, emp.userName);
                                                    } else if (res.length > 1) {
                                                        requestData['failed'] = indicatorColumn + titleIndex + ': Multiple employees found for ' + sheetEmp + '.  Make sure it is in the correct format.';
                                                        completed++;
                                                        answerQuestions().then(function(){resolve();})
                                                    } else {
                                                        requestData['failed'] = indicatorColumn + titleIndex + ': Employee ' + sheetEmp + ' not found.';
                                                        completed++;
                                                        answerQuestions().then(function(){resolve();})
                                                    }
                                                },
                                                'onFail': function (err) {
                                                    requestData['failed'] = indicatorColumn + titleIndex + ": Error retrieving email for employee on sheet row " + titleIndex + " indicator " + index;
                                                    completed++;
                                                    answerQuestions().then(function(){resolve();})
                                                },
                                                'async': true
                                            }, sheetEmp);
                                            break;
                                        case 'orgchart_group':
                                            var sheetGroup = typeof (row[indicatorColumn]) !== "undefined" && row[indicatorColumn] !== null ? row[indicatorColumn].toString() : '';
                                            nexusAPI.Groups.searchGroups({
                                                'onSuccess': function (groups) {
                                                    if (groups.length === 1) {
                                                        var grp = groups[Object.keys(groups)[0]];
                                                        requestData[currentIndicator] = parseInt(grp.groupID);
                                                    } else if (groups.length > 1) {
                                                        requestData['failed'] = indicatorColumn + titleIndex + ': Multiple groups found for ' + sheetGroup + '.  Make sure that the name is exact.';
                                                    } else {
                                                        requestData['failed'] = indicatorColumn + titleIndex + ': Group ' + sheetGroup + ' not found.';
                                                    }
                                                    completed++;
                                                    answerQuestions().then(function(){resolve();})
                                                },
                                                'onFail': function (err) {
                                                    requestData['failed'] = indicatorColumn + titleIndex + ": Error retrieving group on sheet row " + titleIndex + " indicator " + index;
                                                    completed++;
                                                    answerQuestions().then(function(){resolve();})
                                                },
                                                'async': true
                                            }, sheetGroup);
                                            break;
                                        case 'orgchart_position':
                                            var sheetPosition = typeof (row[indicatorColumn]) !== "undefined" && row[indicatorColumn] !== null ? row[indicatorColumn].toString() : '';
                                            nexusAPI.Positions.searchPositions({
                                                'onSuccess': function (positions) {
                                                    if (positions.length === 1) {
                                                        var pos = positions[Object.keys(positions)[0]];
                                                        requestData[currentIndicator] = parseInt(pos.positionID);
                                                    } else if (positions.length > 1) {
                                                        requestData['failed'] = indicatorColumn + titleIndex + ': Multiple positions found for ' + sheetPosition + '.  Make sure that the name is exact.';
                                                    } else {
                                                        requestData['failed'] = indicatorColumn + titleIndex + ': Position ' + sheetPosition + ' not found.';
                                                    }
                                                    completed++;
                                                    answerQuestions().then(function(){resolve();})
                                                },
                                                'onFail': function (err) {
                                                    requestData['failed'] = indicatorColumn + titleIndex + ": Error retrieving group on sheet row " + titleIndex + " indicator " + index;
                                                    completed++;
                                                    answerQuestions().then(function(){resolve();})
                                                },
                                                'async': true
                                            }, sheetPosition);
                                            break;
                                        case 'date':
                                            var cellDate = typeof (row[indicatorColumn]) !== "undefined" && row[indicatorColumn] !== null ? row[indicatorColumn].toString() : '';

                                            // check if excel formatted number
                                            if (!isNaN(cellDate) && cellDate !== '') {
                                                var convertedDate = convertExcelDateToShortString(parseInt(cellDate));
                                                requestData[currentIndicator] = convertedDate;
                                            } else {
                                                requestData[currentIndicator] = cellDate;
                                            }

                                            completed++;
                                            answerQuestions().then(function(){resolve();})
                                            break;
                                        default:
                                        requestData[currentIndicator] = row[indicatorColumn];
                                        completed++;
                                        answerQuestions().then(function(){resolve();})
                                        break;
                                    }
                                }
                            }
                        });
                    }
                    answerQuestions().then(function(res) {
                        resolve();
                    });
                });
            }

            /* iterate through the sheet cells, which are organized by row */
            totalRecords = sheet_data.cells.length -1;
            dialog.dialog( "open" );
         
            if(preserveOrder){
                placeInOrder = 1;
                selectRowToAnswer(placeInOrder).then(iterate);

                function iterate() {
                    placeInOrder++;
                    totalImported++;
                    if(placeInOrder <= sheet_data.cells.length -1){
                        selectRowToAnswer(placeInOrder).then(iterate);
                    }
                }

            } else {
                for (var i = 1; i <= sheet_data.cells.length - 1; i+=2) {
                    var doublet = [];
                    doublet.push(selectRowToAnswer(i));

                    var addAnother = i+1 <= sheet_data.cells.length - 1;
                    if(addAnother){
                        doublet.push(selectRowToAnswer(i+1));
                    }

                    Promise.all(doublet).then(function(results){
                        totalImported += results.length;
                    });
                }
            }

            queue.setWorker(item => makeRequests(item.categoryID, item.requestData, preserveOrder));
            queue.start().then(res => {
                progressbar.progressbar("value", 100);
                $('#status').html('Data has been imported');
            });
        }

        portalAPI.Forms.getAllForms(
            function (results) {
                /* build a select options for each form */
                var opt = $(document.createElement('option'))
                    .attr('value', '-1')
                    .html('');

                categorySelect.append(opt);

                for (var i = 0; i < results.length; i++) {
                    var category = results[i];
                    var opt = $(document.createElement('option'))
                        .attr('value', category.categoryID)
                        .html(category.categoryName + ' : ' + category.categoryDescription);

                    categorySelect.append(opt);
                }

            },
            function (error) {
                console.log(error)
            }
        );

        /*  build the rows for the given indicator data, also processes its children if present */
        function buildRows(indicator) {
            if (typeof (indicator) !== "undefined" && indicator !== null) {
                categoryIndicators.append(buildIndicatorRow(indicator));

                if (typeof (indicator.child) !== "undefined" && indicator.child != null) {
                    var children = Object.keys(indicator.child);
                    for (var i = 0; i < children.length; i++) {
                        var child = indicator.child[children[i]];

                        buildRows(child);
                    }
                }
            }
        }

        importBtnExisting.on('click', function () {
            if (titleInputExisting.val() === '') {
                return alert('Request title is required.');
            }
            dialog_confirm.setContent('Are you sure you want to submit ' + (sheet_data.cells.length - 1) + ' requests?');
            dialog_confirm.setSaveHandler(function () {
                dialog_confirm.hide();
                importExisting();
            });
            dialog_confirm.show();
        });

        importBtnNew.on('click', function () {
            if (nameOfSheet === 'Sheet1' && formTitle.val() === '') {
                return alert('Form title is required for this type of sheet.');
            }
            if (titleInputNew.val() === '') {
                return alert('Request title is required.');
            }
            dialog_confirm.setContent('Are you sure you want to submit ' + (sheet_data.cells.length - 1) + ' requests?');
            dialog_confirm.setSaveHandler(function () {
                dialog_confirm.hide();
                importNew();
            });
            dialog_confirm.show();
        });

        categorySelect.on('change', function () {
            categoryIndicators.html('');

            portalAPI.Forms.getIndicatorsForForm(categorySelect.val(),
                function (results) {
                    currentIndicators = results;
                    indicatorArray = new Array();

                    for (var i = 0; i < results.length; i++) {
                        var indicator = results[i];
                        buildRows(indicator);
                    }
                },
                function (error) {
                }
            );
        });

        sheetUpload.on('change', function (e) {
            categorySelect.val("-1");
            categoryIndicators.html('');
            var files = e.target.files,file;
            if (!files || files.length === 0) return;
            file = files[0];
            var fileReader = new FileReader();
            fileReader.onload = function (e) {
                var cells = [];
                var data = new Uint8Array(e.target.result);

                /* passes file through js-xlsx library */
                try {
                    var returnedJSON = XLSX.read(data, {type: 'array'});
                }
                catch (err) {
                    toggler.attr('style', 'display: none;');
                    existingForm.css('display', 'none');
                    newForm.css('display', 'none');
                    alert('Unsupported file: could not read');
                    return;
                }
                nameOfSheet = returnedJSON.SheetNames[0];

                /* conforms js-xlsx schema to LEAFPortalApi.js schema
                sheet data is stored in the Sheets property under filename */
                var rawSheet = returnedJSON.Sheets[nameOfSheet];

                /* insures spreadsheet has filename */
                if(typeof (rawSheet) === "undefined"){
                    toggler.attr('style', 'display: none;');
                    existingForm.css('display', 'none');
                    newForm.css('display', 'none');
                    alert('Unsupported file: file requires name');
                    return;
                }

                /* reads layout of sheet */
                var columnNames = _buildColumnsArray(rawSheet['!ref']);
                var rows = parseInt(rawSheet['!ref'].substring(rawSheet['!ref'].indexOf(':'), rawSheet['!ref'].length).replace(/:[A-Z]+/g, '')) - 1;
                var headers = new Object();

                /* converts schema */
                for(var i = 0; i <= rows; i++) {
                    if(i !== 0){
                        cells[i.toString()] = {};
                    }
                    for (var j = 0; j < columnNames.length; j++) {
                        if (i === 0){
                            if (typeof (rawSheet[columnNames[j] + (i + 1).toString()]) === "undefined") {
                            } else {
                                headers[columnNames[j]] = rawSheet[columnNames[j] + (i + 1).toString()].v;
                            }
                        } else if (typeof (rawSheet[columnNames[j] + (i + 1).toString()]) === "undefined") {
                            cells[i.toString()][columnNames[j]] = '';
                            blankIndicators.push(columnNames[j]);
                        } else {
                            cells[i.toString()][columnNames[j]] = rawSheet[columnNames[j] + (i + 1).toString()].v;
                        }
                    }
                }
                sheet_data = {};
                sheet_data.headers = headers;
                sheet_data.cells = cells;
                if (cells.length > 0) {
                    buildFormat(sheet_data);
                    toggler.attr('style', 'display: block;');
                } else {
                    alert('This spreadsheet has no data');
                }
            };
            fileReader.readAsArrayBuffer(file);
        });

    });


</script>
