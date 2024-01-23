<link rel="stylesheet" href='<!--{$app_css_path}-->/leaf.css' />
<script src="https://cdnjs.cloudflare.com/ajax/libs/xlsx/0.16.1/xlsx.full.min.js"></script>
  <link rel="stylesheet" href="https://code.jquery.com/ui/1.12.1/themes/base/jquery-ui.css">
<script src="<!--{$app_js_path}-->/promise-pollyfill/polyfill.min.js"></script>
  <script src="https://code.jquery.com/ui/1.12.1/jquery-ui.js"></script>

<style>
    .errorMessage{
        font-size: smaller;
        max-width: 30%;
        color: red;
    }

    .modalBackground {
        width: 100%;
        height: 100%;
        z-index: 5;
        position: absolute;
        background-color: grey;
        margin-top: 0px;
        margin-left: 0px;
        opacity: 0.5;
    }

</style>

<script>
    var CSRFToken = '<!--{$CSRFToken}-->';
    var workbook;
    var headers;
    var results;
    var totalRecords;
    var totalImported = 0;
    var workbookData = [];
    var previewData = [];
    var previewShowing = false;

    $( function() {
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
                progressTimer = setTimeout( progress, 2000 );
            }
        });

        progressbar.progressbar({
            value: false,
            change: function() {
                progressLabel.text( "Current Progress: " + progressbar.progressbar( "value" ) + "%" );
            },
            complete: function() {
                closeImport();
            }
        });

        $(".header-select").change(function(){

            if(previewShowing){
                $("#preview-tbody").empty();
                $("#preview-data").hide();
                $("#step2btn").hide();
                $("#preview-btn").show();
            }

        });

        // step 1
        $("#step1btn").click( function(){

            var input = document.getElementById('import-fileInput');
            if (input.files[0] != null) {
                workbook = new WorkbookHelper(input.files[0]);
                workbook.init().then(function(){
                    headers = workbook.getHeaders();
                    fillDropdown();
                    moveToStepTwo();
                });
            }
            else {
                $('#input-error-message1').show();
            }
        });
        // step 2
        $("#step2btn").click( function(){

            dialog.dialog( "open" );
            importFromWorkbook().then(function(results){
                $("#importStep2").hide();
                moveToComplete(results);
            });

        });

        $("#preview-btn").click(function(){

            var employeeEmailIndex = $('#employee-select').val();
            var supervisorEmailIndex = $('#supervisor-select').val();
            var positionIndex = $('#position-select').val();

            if(previewData.length == 0){
                previewData = workbook.getData(1, 6); //getting first five rows, skipping first row of headers
            }

            totalRecords = previewData.length;

            var recordsToShow = (totalRecords > 5) ? 5 : totalRecords;

            $("#preview-number").html(recordsToShow);

            for(var i=0; i< recordsToShow; i++){
                var workbookItem = previewData[i];
                $("#preview-tbody").append("<tr>"+
                    "<td>"+
                        workbookItem[employeeEmailIndex] +
                    "</td>"+
                    "<td>"+
                        workbookItem[supervisorEmailIndex] +
                    "</td>"+
                    "<td>"+
                        workbookItem[positionIndex] +
                    "</td>"+
                "</tr>");
            }

            previewShowing = true;
            $("#preview-btn").hide();
            $("#step2btn").show();
            $("#preview-data").show();
        });

        $("#step2backBtn").click(function(){
            $("#importStep1").show();
            $("#step1").removeClass('complete').addClass('current');
            $("#importStep2").hide();
            $("#step2").removeClass('current').addClass('next');
        });

         function importFromWorkbook(){
            var employeeEmailIndex = $('#employee-select').val();
            var supervisorEmailIndex = $('#supervisor-select').val();
            var positionIndex = $('#position-select').val();

            workbookData = workbook.getData(1); //skipping first row of headers

            var importedDataPromises = [];

            for(var i= 0; i <workbookData.length; i++){
                var workbookItem = workbookData[i];
                importedDataPromises.push(
                    doImport(
                        new EmployeeData(
                            workbookItem[employeeEmailIndex],
                            workbookItem[supervisorEmailIndex],
                            workbookItem[positionIndex])
                    )
                );
            }
            return Promise.all(importedDataPromises);

        }

         function doImport(employee){

            return new Promise( function(resolve){
                var valid = true;

                var validationPromises = [];

                validationPromises.push(checkUserExistsNational(employee.email));
                validationPromises.push(checkUserExistsNational(employee.supervisorEmail));
                validationPromises.push(checkPosition(employee.position));

                var responses;
                Promise.all(validationPromises).then(function(res){
                responses = res;
                var userResponse = responses[0][Object.keys(responses[0])[0]];
                var supervisorResponse = responses[1][Object.keys(responses[1])[0]];
                var positionResponse = responses[2];
                var userValid = userResponse && userResponse.userName;
                var supervisorValid = supervisorResponse && supervisorResponse.userName;
                var positionValid = positionResponse && positionResponse.positionID;
                var localEmployeeData;
                var userImported = false;

                if(userValid){
                    // user exists in National
                    employee.userName = userResponse.userName;
                    employee.empUID = userResponse.empUID;
                    employee.displayName = userResponse.firstName + ' ' + userResponse.lastName;

                    // check if user exists in local to see if it needs to be imported
                    var localResult;

                    getLocalEmployeeData(employee.email).then(function(result){
                        localResult = result;
                        var localEmployeeData = null;

                        if(Object.keys(localResult).length > 0){
                            localEmployeeData = localResult[Object.keys(localResult)[0]];
                        }

                        if(!localEmployeeData){
                            // if user does not exist in local, import them.
                            addEmployee(employee).then(function(importResult){
                                if(importResult < 0){
                                    userValid = false;
                                    employee.errorMessage += "Unable to import user. ";
                                }
                                else{
                                    employee.userID = importResult;
                                    userImported = true;
                                }

                                if(userImported){

                                    if(supervisorValid){
                                        employee.supervisorDisplayName = supervisorResponse.firstName + ' ' + supervisorResponse.lastName;
                                    }
                                    else{
                                        employee.errorMessage += "Supervisor not found in national orgchart. ";
                                        supervisorValid = false;
                                        totalImported++;
                                        resolve(employee);
                                    }

                                    valid = userValid && supervisorValid && positionValid;

                                    if(valid){

                                        var found = false;

                                        var supervisorLocalResult;

                                        getLocalEmployeeData(employee.supervisorEmail).then(function(result){

                                            supervisorLocalResult = result;

                                            var fullSupervisorInfo = null;

                                            if(Object.keys(supervisorLocalResult).length > 0){
                                                fullSupervisorInfo = supervisorLocalResult[Object.keys(supervisorLocalResult)[0]];

                                                var supervisorPositions;

                                                getEmployeePositionData(fullSupervisorInfo.empUID).then(function(result){

                                                    supervisorPositions = result;
                                                    var positionSupervisors = getPositionSupervisors(positionResponse.supervisor);

                                                    if(supervisorPositions){
                                                        var positions = supervisorPositions;

                                                        for(var i=0; i< positions.length; i++){
                                                            if(positionSupervisors.indexOf(positions[i].empUID) >= 0){
                                                                found = true;
                                                            }
                                                        }
                                                    }

                                                    if(found){
                                                        addEmployeeToPosition(employee.empUID, positionResponse.positionID).then(function(){
                                                            employee.success = true;
                                                            totalImported++;
                                                            resolve(employee);
                                                        });
                                                    }
                                                    else{
                                                        employee.errorMessage += "Provided supervisor not assigned to position. ";
                                                        totalImported++;
                                                        resolve(employee);
                                                    }
                                                });

                                            }

                                        });


                                    }
                                    else{
                                        employee.errorMessage += "Position not found. ";
                                        valid = false;
                                        totalImported++;
                                        resolve(employee);
                                    }
                                }
                                else{
                                    totalImported++;
                                    resolve(employee);
                                }

                            });


                        }
                        else{
                            userValid = false;
                            employee.errorMessage += "User already imported!";
                            totalImported++;
                            resolve(employee);
                        }


                    });


                }
                else{
                    employee.errorMessage += "User not found in national orgchart. ";
                    userValid = false;
                    totalImported++;
                    resolve(employee);
                }
                });

            });

        };

        function getPositionSupervisors(supervisors){
            var result = [];

            for(var i=0; i < supervisors.length; i++){
                if(supervisors[i] && supervisors[i].empUID){
                    result.push(supervisors[i].empUID);
                }
            }

            return result;
        }

        function addEmployeeToPosition(employeeID, positionID){

            return new Promise(function(resolve, reject){
                $.ajax({
                    type: 'POST',
                    url: '../api/position/' + positionID +'/employee',
                    dataType: 'json',
                    data: {CSRFToken: CSRFToken, empUID: employeeID},
                    success: function(response) {
                        resolve();
                    },
                    error: function(response){
                        reject();
                    },
                    cache: false
                });
            });
        }

        function getLocalEmployeeData(email){

            return new Promise(function(resolve, reject){
                $.ajax({
                    type: 'GET',
                    url: '../api/employee/search?q=' + email + '&noLimit=0',
                    dataType: 'json',
                    data: {CSRFToken: CSRFToken},
                    success: function(response) {

                        resolve(response);
                    },
                    error: function(response){

                        reject(response);
                    },
                    cache: false
                })

            });
        }

        function getEmployeePositionData(empUID){
            return new Promise(function(resolve, reject){
                $.ajax({
                    type: 'GET',
                    url: '../api/employee/' + empUID,
                    dataType: 'json',
                    data: {CSRFToken: CSRFToken},
                    success: function(response) {
                        resolve(response.employee.positions);
                    },
                    error: function(response){

                        reject(response);
                    },
                    cache: false
                })

            });
        }

        function closeImport() {
            $("#modal-background").removeClass("modalBackground");
            clearTimeout( progressTimer );
            dialog
                .dialog( "close" );
            progressbar.progressbar( "value", false );
            progressLabel
                .text( "Starting import..." );
        }

        function checkPosition(position){
            return new Promise(function(resolve, reject){
                $.ajax({
                    type: 'GET',
                    url: '../api/position/search?q=' + position + '&noLimit=0',
                    dataType: 'json',
                    data: {CSRFToken: CSRFToken},
                    success: function(response) {
                        resolve(response[0]);
                    },
                    error: function(response){
                        reject();
                    },
                    cache: false
                });
            });
        }

        function addEmployee(employee){
            return new Promise(function(resolve){
                $.ajax({
                    type: 'POST',
                    url: '../api/employee/import/_' + employee.userName,
                    dataType: 'json',
                    data: {CSRFToken: CSRFToken},
                    success: function(response) {
                        resolve(response);
                    },
                    cache: false
                });
            });
        }

        function checkUserExistsNational(email){

            return new Promise(function(resolve, reject){
                $.ajax({
                    type: 'GET',
                    url: '../api/national/employee/search?q=' + email + '&noLimit=0',
                    dataType: 'json',
                    success: function(response) {
                        if (response != null){
                            resolve(response);
                        };
                        reject();
                    },
                    error: function(response){
                        reject();
                    },
                    cache: false
                });
            });

        }

        function fillDropdown(){

            for(var i =0; i<headers.length; i++){
                var newOption = $('<option value='+i+'>'+ (headers[i] ? headers[i] : '') +'</option>');
                $(".header-select").append(newOption);
            }

        }

        function moveToStepTwo(){
            $("#importStep1").hide();
            $("#step1").removeClass('current').addClass('complete');
            $("#importStep2").show();
            $("#step2").removeClass('next').addClass('current');
            $('#input-error-message1').hide();
        }

        function progress() {
            var val = progressbar.progressbar( "value" ) || 0;

            progressbar.progressbar( "value", Math.floor( totalImported/totalRecords *100) );

            if ( val <= 99 ) {
                progressTimer = setTimeout( progress, 50 );
            }
        }

        function buildResultsTable(results){

            var tableHtml = '';

            var errorCounter = 0;

            for(var i=0; i < results.length; i++){
                var html = '<tr>';
                    html += '<td style="background-color:inherit;">' + (results[i].userID ? results[i].userID  : '') + '</td>';
                    html += '<td style="background-color:inherit;">' + (results[i].displayName ? results[i].displayName : '') + '</td>';
                    html += '<td style="background-color:inherit;">' + (results[i].supervisorDisplayName ? results[i].supervisorDisplayName : '') + '</td>';
                    html += '<td style="background-color:inherit;">' + (results[i].position ? results[i].position: '') + '</td>';
                html += '</tr>';

                var newRow = $(html);

                $("#table-body").append(newRow);

                if(!results[i].success){
                    errorCounter++;
                    $(newRow).css("background-color", "#FFC0CB");
                    $(newRow).append("<td class='errorMessage' style='border-style:none;'>" + results[i].errorMessage+ "</td>");

                }


            }

            $("#status").text("Import successful, "+ (results.length - errorCounter) + " row(s) imported with " + errorCounter + " error(s).");

        }

        function moveToComplete(results){

            buildResultsTable(results);


            $("#step2").removeClass('current').addClass('complete');
            $("#importStep3").show();
            $("#step2").removeClass('next').addClass('complete');
            $("#step3").removeClass('next').addClass('complete');
        }

    });


    function EmployeeData(email,supervisorEmail,position){
        this.displayName = '';
        this.supervisorDisplayName = '';
        this.userName = '';
        this.userID = '';
        this.empUID = '';
        this.supervisorID = '';
        this.email = email;
        this.supervisorEmail = supervisorEmail;
        this.position = position;
        this.success = false;
        this.errorMessage = '';
    }
</script>
<div id="modal-background"></div>
<main id="main-content">

    <div class="grid-container">

        <div class="grid-row">
            <div class="grid-col-12">
                <h1>Import Organization Chart</h1>
                <div>
                    <ul class="leaf-progress-bar">
                        <li class="current" id="step1">
                            <h6>Select File</h6>
                            <span class="left"></span>
                            <span class="right"></span>
                        </li>
                        <li class="next" id="step2">
                            <h6>Org Chart Preview</h6>
                            <span class="left"></span>
                            <span class="right"></span>
                        </li>
                        <li class="next" id="step3">
                            <h6>Import Complete</h6>
                            <span class="left"></span>
                            <span class="right"></span>
                        </li>
                    </ul>
                </div>
            </div>
        </div>

        <div id="importStep1" class="leaf-content-show">

            <div class="grid-row">
                <div class="grid-col-12">
                    <h2><label for="import-fileInput">Step 1: Select Spreadsheet for Import</label></h2>
                    <p>Select a file to import and click Continue. The first row of the spreadsheet must contain the headers of the columns.</p>
                    <div>
                        <span class="usa-error-message leaf-content-hide" id="input-error-message1" role="alert">No file selected, select a file to continue.</span>
                    </div>
                    <div class="leaf-grey-box leaf-width50pct">
                        <input type="file" id="import-fileInput" accept=".xlsx"/>
                    </div>
                </div>
            </div>
            <div class="grid-row leaf-buttonBar" style="text-align:left;">
                <div class="leaf-displayInlineBlock leaf-width100pct">
                    <button class="usa-button usa-button--big" id="step1btn">Continue</button>
                </div>
            </div>

        </div>

        <div id="importStep2" class="leaf-content-hide">

            <div class="grid-row">
                <div class="grid-col-12">
                    <h2>Step 2: Org Chart Preview</h2>
                    <p>Select the columns from the import that map to Employee Email, Supervisor Email, and Position Title. Click Import Data to complete the import.</p>
                    <table class="usa-table">
                        <thead>
                            <tr>
                            <th scope="col">Employee Email</th>
                            <th scope="col">Supervisor Email</th>
                            <th scope="col">Position Title</th>
                            </tr>
                        </thead>
                        <tbody>
                            <tr>
                                <td>
                                    <select class="usa-select header-select" id="employee-select">
                                    </select>
                                </td>
                                <td>
                                    <select class="usa-select header-select" id="supervisor-select">
                                    </select>
                                </td>
                                <td>
                                    <select class="usa-select header-select" id="position-select">
                                    </select>
                                </td>
                            </tr>
                        </tbody>
                    </table>
                </div>
            </div>

            <div class="grid-col-12" id="preview-data" style="display:none;">
            <p>
                <em>Showing preview of first <span id="preview-number"></span> records:</em>
            </p>
                <table class="usa-table" >
                    <thead>
                        <th scope="col">Employee Email</th>
                        <th scope="col">Supervisor Email</th>
                        <th scope="col">Position</th>
                    </thead>
                    <tbody id="preview-tbody">
                    </tbody>
                </table>
            </div>
            <div class="grid-row leaf-buttonBar" style="text-align:left;">
                <div class="leaf-displayInlineBlock leaf-width100pct">

                    <button class="usa-button usa-button--big" id="step2btn" style="display:none;">
                        Import Data
                    </button>
                    <button class="usa-button usa-button--big" id="preview-btn">
                        Preview Import
                    </button>
                    <button class="usa-button usa-button--base usa-button--big" id="step2backBtn">Go Back</button>
                </div>
            </div>

        </div>

        <div id="importStep3" class="leaf-content-hide">

            <div class="grid-row">
                <div class="grid-col-12">
                    <h2>Import Complete</h2>
                    <p id="status"></p>
                    <table class="usa-table" id="result-table">
                        <thead>
                            <tr>
                                <th scope="col">UID</th>
                                <th scope="col">Employee Name</th>
                                <th scope="col">Supervisor Name</th>
                                <th scope="col">Position Title</th>
                            </tr>
                        </thead>
                        <tbody id="table-body">

                        </tbody>
                    </table>
                </div>
            </div>
            <div class="grid-row leaf-buttonBar" style="text-align:left;">
                <div class="leaf-displayInlineBlock leaf-width100pct">
                    <a href="./"><button class="usa-button usa-button--big">Return to OC Admin</button></a>
                </div>
            </div>

            <div id="dialog" title="Employee import" style="z-index:100;">
                <div class="progress-label">Starting import...</div>
                <div id="progressbar"></div>
            </div>


        </div>
    </div>

</main>