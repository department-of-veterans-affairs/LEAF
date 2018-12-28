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
</style>
<script type="text/javascript" src="https://cdn.jsdelivr.net/gh/SheetJS/js-xlsx@1eb1ec/dist/xlsx.full.min.js"></script>
<script type="text/javascript" src="https://cdn.jsdelivr.net/gh/SheetJS/js-xlsx@64798fd/shim.js"></script>
<script type="text/javascript" src="js/lz-string/lz-string.min.js"></script>
<div id="status" style="background-color: black; color: white; font-weight: bold; font-size: 140%"></div>
<div id="uploadBox">
    <h4>Choose a Spreadsheet</h4>
    The first row of the file must be headers for the columns.
    <br/>

    <input id="sheet_upload" type="file"></input>

    <br />
    <br />
</div>
<div id="toggler" style="display: none">
    <input id="newFormToggler" name="toggle" onclick="toggleImport(event)" type="radio">New Form</input>
    <input id="existingFormToggler" name="toggle" onclick="toggleImport(event)" type="radio">Existing Form</input>
</div>
<div id="import_data_new_form" style="display: none;">
    <h4>Create a Form</h4>
    <button id="import_btn_new" type="button">Import</button>
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
    This will be the title for all imported requests.
    <br/><br/>
</div>
<div id="import_data_existing_form" style="display: none;">
    <h4>Select a Form</h4>
    <select id="category_select"></select>

    <button id="import_btn_existing" type="button">Import</button>

    <br/><br/>

    <label for="title_input_existing"><b>Title of Requests</b></label>
    <input type="text" id="title_input_existing" />
    This will be the title for all imported requests.

    <br/><br/>

    <table id="category_indicators">
        <thead>
            <tr>
                <th>ID</th>
                <th>Name</th>
                <th>Format</th>
                <th>Description</th>
                <th>Required</th>
                <th>Sheet Column</th>
            </tr>
        </thead>
        <tbody></tbody>
    </table>
</div>
<div id="request_status" style="padding: 20px;"></div>

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

    var createdRequests = 0;
    var failedRequests = 0;
    var currentIndicators = [];
    var blankIndicators = [];
    var sheet_data = {};

    function toggleImport(e) {
        if(e.target.id === "newFormToggler") {
            newForm.css('display', 'block');
            existingForm.css('display', 'none');
        } else if (e.target.id === "existingFormToggler") {
            newForm.css('display', 'none');
            existingForm.css('display', 'block');
        }
    }

    function buildFormat(spreadSheet) {
        $('#new_form_indicators').remove();
        var table =
            '<table id="new_form_indicators" style="text-align: center;">' +
            '   <thead>' +
            '       <tr>' +
            '           <th> Sheet Column </th>' +
            '           <th> Name </th>' +
            '           <th> Format </th>' +
            '           <th> Required </th>' +
            '           <th> Sensitive </th>' +
            '       </tr>' +
            '   <thead>' +
            '<tbody>';
        $.each(spreadSheet.headers, function(key, value) {
            var requiredCheckbox = blankIndicators.indexOf(key) === -1 ? '<input type="checkbox"></input>' : '<input type="checkbox" onclick="return false;" disabled="disabled" title="Cannot set as required when a row in this column is blank."></input>';
            table +=
                '<tr>' +
                '   <td>' + key + '</td>' +
                '   <td>' + value + '</td>' +
                '   <td>' +
                '       <select>' +
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
                '   <td><input type="checkbox"></input></td>' +
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
        if (blankIndicators.includes($(e.target).val())) {
            $(e.target).val("-1");
            alert('Column can\'t be selected because it contains blank entries.');
        }
    }

    // build the select input with options for the given indicator
    // the indicatorID corresponds to the select input id
    function buildSheetSelect(indicatorID, sheetData, required) {
        var select = $(document.createElement('select'))
            .attr('id', indicatorID + '_sheet_column')
            .attr('class', 'indicator_column_select');

        if (required === "1") {
            select.attr('onchange', 'searchBlankRow(event);');
        }

        // "blank" option
        var option = $(document.createElement('option'))
            .attr('value', '-1')
            .html('');

        select.append(option);

        // the value of each option is the column header, which is the key of the sheetData.headers object
        var keys = Object.keys(sheetData.headers);
        for (var i = 0; i < keys.length; i++) {
            var option = $(document.createElement('option'))
                .attr('value', keys[i])
                .html(keys[i] + ': ' + sheetData.headers[keys[i]]);

            select.append(option);
        }

        return select;
    }

    // build the table row and data (<tr> and <td>) for the given indicator
    function buildIndicatorRow(indicator) {
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

        var columnSelect = $(document.createElement('td'))
            .append(buildSheetSelect(indicator.indicatorID, sheet_data, indicator.required))
            .appendTo(row);

        return row;
    }

    function generateReport() {
        urlTitle = "Requests have been generated for each row of the imported spreadsheet";
        urlQueryJSON = '{"terms":[{"id":"title","operator":"LIKE","match":"*' + nameOfSheet + '*"},{"id":"deleted","operator":"=","match":0}],"joins":["service"],"sort":{}}';
        urlIndicatorsJSON = '[{"indicatorID":"","name":"","sort":0},{"indicatorID":"title","name":"","sort":0}]';

        urlTitle = encodeURIComponent(btoa(urlTitle));
        urlQuery = encodeURIComponent(LZString.compressToBase64(urlQueryJSON));
        urlIndicators = encodeURIComponent(LZString.compressToBase64(urlIndicatorsJSON));

        $('#status').html('Data has been imported');
        requestStatus.html(
            'Import Completed! ' + createdRequests + ' requests made, ' + failedRequests + ' failures.<br/><br/>' +
            '<a class="buttonNorm" role="button" href="./?a=reports&v=3&title=' + urlTitle + '&query=' + urlQuery + '&indicators=' + urlIndicators + '">View Report<\a>'
        );
    }

    function makeRequests(categoryID, initiator, requestData) {
        console.log(requestData);
        portalAPI.Forms.newRequest(
            categoryID,
            requestData,
            function (recordID) {

                // recordID is the recordID of the newly created request, it's 0 if there was an error
                if (recordID > 0) {
                    createdRequests++;
                    requestStatus.html(createdRequests + ' out of ' + (sheet_data.cells.length - 1) + ' requests completed, ' + failedRequests + ' failures.');

                    //if (changeToInitiator !== undefined && changeToInitiator != null) {
                    // set the initiator so they can see the request associated with their availability
                    portalAPI.Forms.setInitiator(
                        recordID,
                        initiator,
                        function (results) {},
                        function (err) {
                            console.log(err);
                        });
                    //}
                } else {
                    console.log('Error creating request for the following data: ' + requestData);
                    failedRequests++;
                }

                if (createdRequests + failedRequests === (sheet_data.cells.length - 1)) {
                    generateReport();
                    createdRequests = 0;
                    failedRequests = 0;
                }
            },
            function (error) {
                alert('Error importing row: ' + i);
                console.log(error);
                failedRequests++;
                requestStatus.html(createdRequests + ' out of ' + (sheet_data.cells.length - 1) + ' requests completed, ' + failedRequests + ' failures.');
                if (failedRequests === (sheet_data.cells.length - 1)) {
                    requestStatus.html('All requests failed!  See log for details.');
                }else if (createdRequests + failedRequests === (sheet_data.cells.length - 1)) {
                    generateReport();
                    createdRequests = 0;
                    failedRequests = 0;
                }
            }
        );
    }

    $(function () {

        //builds select options of workflows
        //if no workflows are found, prompts user to go make one
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
                else {
                    $('#formWorkflowSelect').html('<span style="color: red">A workflow must be set up first</span>');
                }
            },
            function (err) {
                console.log(err);
            }
        );

        importBtnNew.on('click', function() {
            $('#status').html('Processing...'); // UI hint
            var newFormIndicators = $('#new_form_indicators');
            var workflowID = $('#workflowID > option:selected').val();
            var formData = {"name": formTitle.val(), "description": formDescription.val()};
            var indicators = [];
            var initiators = {};

            //creates custom form
            portalAPI.FormEditor.createCustomForm(
                formData.name,
                formData.description,
                function(categoryID) {
                    requestStatus.html('Making custom form...');
                    portalAPI.FormEditor.assignFormWorkflow(
                        categoryID.replace(/"/g,""),
                        workflowID,
                        function(msg){
                            // console.log(msg);
                        },
                        function(err){
                            console.log(err);
                        }
                    );

                    //parses user's input and makes an indicator for each row of the table
                    newFormIndicators.children('tbody').find('tr').each(function(index) {
                        var indicatorObj = {};
                        indicatorObj.name = $("td:eq(1)", this).html();
                        indicatorObj.format = $("td:eq(2) > select > option:selected", this).val();
                        indicatorObj.required = $("td:eq(3) > input", this).is(":checked") === true ? 1 : 0;
                        indicatorObj.is_sensitive = $("td:eq(4) > input", this).is(":checked") === true ? 1 : 0;

                        //creates indicator from indicatorObj
                        portalAPI.FormEditor.createFormIndicator(
                            indicatorObj.name,
                            indicatorObj.format,
                            categoryID.replace(/"/g,""),
                            indicatorObj.required,
                            indicatorObj.is_sensitive,
                            function(indicatorID) {

                                //adds indicators to array
                                //when all indicators are parsed, moves on to next step of filling out requests
                                indicators.push(indicatorID.replace(/"/g,""));
                                if(indicators.length === newFormIndicators.children('tbody').find('tr').length){

                                    // iterate through the sheet cells, which are organized by row
                                    for (var i = 0; i < sheet_data.cells.length - 1; i++) {

                                        // js-xlsx rows are 1-based instead of 0-based, so reads them as i+1
                                        var row = sheet_data.cells[i + 1];
                                        var requestData = new Object();
                                        var changeToInitiator = null;
                                        var title = titleInputNew.val() === '' ? titleInputNew.val() : titleInputNew.val() + '_';
                                        requestData['title'] = title + nameOfSheet +'_' + (i + 1);
                                        $.each(indicators, function( key, value ) {
                                            var column = newFormIndicators.find('tbody > tr:eq(' + key.toString() + ') > td:first').html();
                                            if (indicatorObj.format === 'orgchart_employee') {
                                                nexusAPI.Employee.getByEmailNational(
                                                    row[value],
                                                    function (user) {
                                                        var emp = user[Object.keys(user)[0]];
                                                        if (emp !== undefined && emp !== null) {
                                                            nexusAPI.Employee.importFromNational(
                                                                emp.userName,
                                                                false,
                                                                function (results) {
                                                                    requestData[value] = parseInt(results);
                                                                    initiators[parseInt(results)] = emp.userName;
                                                                    changeToInitiator = emp.userName;

                                                                },
                                                                function (err) {
                                                                    console.log("Error retrieving employee on sheet row " + (i + 1) + " for indicator " + index + ": " + err);
                                                                }
                                                            );
                                                        }
                                                    },
                                                    function (err) {
                                                        console.log("Error retrieving email for employee on sheet row "  + (i + 1) + " indicator " + index + ": " + err);
                                                    }
                                                );
                                            } else {
                                                requestData[value] = sheet_data.cells[i + 1][column];
                                            }
                                        });
                                        makeRequests(categoryID.replace(/"/g,""), changeToInitiator, requestData);
                                    }
                                }
                            },
                            function(err) {
                                console.log("Could not create indicator at row " + index + ": " + err);
                                alert("Error creating form.  See log for details.");
                            }
                        );
                    });
                },
                function (err) {
                    console.log("Could not create custom form: " + err);
                }
            );

        });

        importBtnExisting.on('click', function () {
            $('#status').html('Processing...'); // UI hint

            // who the request initiator will be changed to
            var initiators = {};

            // iterate through the sheet cells, which are organized by row
            for (var i = 0; i < sheet_data.cells.length - 1; i++) {

                // js-xlsx rows are 1-based instead of 0-based, so reads them as i+1
                var row = sheet_data.cells[i+1];
                var title = titleInputExisting.val() === '' ? titleInputExisting.val() : titleInputExisting.val() + '_';
                var requestData = {'title': title + nameOfSheet +'_' + (i + 1)};
                var changeToInitiator = null;


                // currentIndicators are the indicators of the form chosen in the form select
                for (var j = 0; j < currentIndicators.length; j++) {
                    function processIndicator(indicator) {

                        var indicatorColumn = $('#' + indicator.indicatorID + '_sheet_column').val();

                        if (indicator.format == 'orgchart_employee') {
                            nexusAPI.Employee.getByEmailNational(
                                row[indicatorColumn],
                                function (user) {
                                    var emp = user[Object.keys(user)[0]];
                                    if (emp != undefined && emp != null) {
                                        nexusAPI.Employee.importFromNational(
                                            emp.userName,
                                            false,
                                            function (results) {
                                                requestData[parseInt(indicator.indicatorID)] = parseInt(results);
                                                initiators[parseInt(results)] = emp.userName;
                                                if (parseInt(indicator.indicatorID) == 137) {
                                                    changeToInitiator = emp.userName;
                                                }

                                            },
                                            function (err) {
                                                console.log(err);
                                            });
                                    }
                                },
                                function (error) {
                                    console.log(error);
                                }
                            );
                        } else {
                            requestData[parseInt(indicator.indicatorID)] = row[indicatorColumn];
                        }
                    }

                    // process the children of any indicator, their data is formatted slightly differently than the parent
                    function processChildren(indicatorChildren) {
                        var children = Object.keys(indicatorChildren);

                        for (var k = 0; k < children.length; k++) {
                            var child = indicatorChildren[children[k]];
                            processIndicator(child);

                            // process the children of the children...
                            if (child.child != undefined && child.child != null) {
                                processChildren(child.child);
                            }
                        }
                    }

                    var indicator = currentIndicators[j];
                    processIndicator(indicator);
                    if (indicator.child != undefined && indicator.child != null) {
                        processChildren(indicator.child);
                    }
                }

                var payload = {};
                payload.changeToInitiator = changeToInitiator;
                payload.requestData = requestData;

                (function (forceVarInScope) {
                    makeRequests(categorySelect.val(), forceVarInScope.changeToInitiator, forceVarInScope.requestData);
                })(payload);

            }

            $('#status').html('Data has been imported');
        });

        portalAPI.Forms.getAllForms(
            function (results) {
                // build a select options for each form
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
                console.log(error);
            }
        );


        //  build the rows for the given indicator data, also processes its children if present
        function buildRows(indicator) {
            if (indicator !== undefined && indicator !== null) {
                categoryIndicators.append(buildIndicatorRow(indicator));

                if (indicator.child != undefined && indicator.child != null) {
                    var children = Object.keys(indicator.child);
                    for (var i = 0; i < children.length; i++) {
                        var child = indicator.child[children[i]];

                        buildRows(child);
                    }
                }
            }
        };

        categorySelect.on('change', function () {
            categoryIndicators.html('');

            portalAPI.Forms.getIndicatorsForForm(categorySelect.val(),
                function (results) {
                    console.log(results);
                    currentIndicators = results;

                    for (var i = 0; i < results.length; i++) {
                        var indicator = results[i];
                        buildRows(indicator);
                    }
                },
                function (error) {
                    console.log(error);
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

                // passes file through js-xlsx library
                try {
                    var returnedJSON = XLSX.read(data, {type: 'array'});
                }
                catch (err) {
                    console.log(err);
                    toggler.attr('style', 'display: none;');
                    existingForm.css('display', 'none');
                    newForm.css('display', 'none');
                    alert('Unsupported file: could not read');
                    return;
                }
                nameOfSheet = returnedJSON.SheetNames[0];

                // conforms js-xlsx schema to LEAFPortalApi.js schema
                // sheet data is stored in the Sheets property under filename
                var rawSheet = returnedJSON.Sheets[nameOfSheet];

                // insures spreadsheet has filename
                if(rawSheet === undefined){
                    toggler.attr('style', 'display: none;');
                    existingForm.css('display', 'none');
                    newForm.css('display', 'none');
                    alert('Unsupported file: file requires name');
                    return;
                }

                // reads layout of sheet
                var columnNames = _buildColumnsArray(rawSheet['!ref']);
                var rows = parseInt(rawSheet['!ref'].substring(rawSheet['!ref'].indexOf(':'), rawSheet['!ref'].length).replace(/:[A-Z]/g, '')) - 1;
                var headers = new Object();

                // converts schema
                for(var i = 0; i <= rows; i++) {
                    if(i !== 0){
                        cells[i.toString()] = {};
                    }
                    for (var j = 0; j < columnNames.length; j++) {
                        if (i === 0){
                            if (rawSheet[columnNames[j] + (i + 1).toString()] === undefined) {
                                console.log('Header at column ' + columnNames[j] + ' is ' + rawSheet[columnNames[j] + (i + 1).toString()]);
                            } else {
                                headers[columnNames[j]] = rawSheet[columnNames[j] + (i + 1).toString()].v;
                            }
                        } else if (rawSheet[columnNames[j] + (i + 1).toString()] === undefined) {
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
                buildFormat(sheet_data);
                toggler.attr('style', 'display: block;');
            };
            fileReader.readAsArrayBuffer(file);
        });

    });

</script>
