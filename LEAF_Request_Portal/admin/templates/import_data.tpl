<style>
    #import_data_main {
        padding: 20px;
    }

    #category_indicators thead tr {
        background-color: rgb(185, 185, 185);
    }

    #category_indicators thead tr th {
        padding: 7px;
    }

    #category_indicators td {
        padding: 7px;
    }
</style>

<div id="import_data_main">
    <h4><label for="file_select">Choose a File</label></h4>
    A spreadsheet must be upload through the <a href="?a=mod_file_manager">File Manager</a> first. The first row of the file
    must be headers for the columns.

    <br />

    <select id="file_select">
        <option value="-1"></option>
    </select>

    <div id="import_info" style="display: none">
        <h4>Select a Form</h4>
        <select id="category_select"></select>

        <button id="import_btn" type="button">Import</button>

        <br/><br/>

        <label for="titleInput"><b>Title of Requests</b></label>
        <input type="text" id="titleInput" />
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
</div>

<script>
    var CSRFToken = '<!--{$CSRFToken}-->';
    var orgChartPath = '<!--{$orgchartPath}-->';

    var nexusAPI = LEAFNexusAPI();
    nexusAPI.setBaseURL('/' + orgChartPath + '/api/?a=');
    nexusAPI.setCSRFToken(CSRFToken);

    var portalAPI = LEAFRequestPortalAPI();
    portalAPI.setBaseURL('./../api/?a=');
    portalAPI.setCSRFToken(CSRFToken);

    var categorySelect = $('#category_select');
    var categoryIndicators = $('#category_indicators tbody');
    var fileSelect = $('#file_select');
    var importBtn = $('#import_btn');
    var importInfo = $('#import_info');
    var titleInput = $('#titleInput');

    var currentIndicators = [];
    var sheet_data = {};

    // build the select input with options for the given indicator
    // the indicatorID corresponds to the select input id
    function buildSheetSelect(indicatorID, sheetData) {
        var select = $(document.createElement('select'))
            .attr('id', indicatorID + '_sheet_column')
            .attr('class', 'indicator_column_select');

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
            .append(buildSheetSelect(indicator.indicatorID, sheet_data))
            .appendTo(row);

        return row;
    }

    $(function () {
        importBtn.on('click', function () {
            var createCount = 0;

            // iterate through the sheet cells, which are organized by row
            for (var i = 0; i < sheet_data.cells.length; i++) {
                var row = sheet_data.cells[i];
                var requestData = { 'title': titleInput.val() };
                var changeToInitiator = null;

                // who the request initiator will be changed to
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
                                                changeToInitiator = emp.userName;
                                                requestData[parseInt(indicator.indicatorID)] = parseInt(emp.empUID);
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

                        for (var k=0; k< children.length; k++) {
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

                portalAPI.Forms.newRequest(
                    categorySelect.val(),
                    requestData,
                    function (recordID) {
                    
                        // recordID is the recordID of the newly created request, it's 0 if there was an error
                        if (recordID > 0) {
                            createCount += 1;

                            if (changeToInitiator !== undefined && changeToInitiator != null) {
                                // set the initiator so they can see the request associated with their availability
                                portalAPI.Forms.setInitiator(
                                    recordID, 
                                    changeToInitiator,
                                    function (results) {},
                                    function (err) {
                                        console.log(err);
                                    });
                            }
                        }

                        if (createCount === sheet_data.cells.length) {
                            alert('Import Successful!');
                        }
                    },
                    function (error) {
                        alert('Error importing row: ' + i);
                        console.log(error);
                    }
                );
            }
        });

        // for now, the imported file must be uploaded through the File Manager
        portalAPI.System.getFileList(
            function (fileList) {
                for (var i = 0; i < fileList.length; i++) {
                    var opt = $(document.createElement('option'))
                        .attr('value', fileList[i])
                        .html(fileList[i]);
                    fileSelect.append(opt);
                }
            },
            function (error) {
                console.log(error);
            }
        );

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
                    for (var i=0; i<children.length; i++) {
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

        fileSelect.on('change', function () {
            if (fileSelect.val() !== "-1") {
                portalAPI.Import.parseXLS(
                    fileSelect.val(),
                    true,
                    function (sheetData) {
                        sheet_data = sheetData;
                        importInfo.attr('style', 'display: block;')
                    },
                    function (error) {
                        sheet_data = {};
                        console.log(error);
                    }
                );
            } else {
                importInfo.attr('style', 'display: none;')
            }
        });
    });

</script>