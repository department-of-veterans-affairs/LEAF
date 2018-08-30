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
    <h4>Choose a File</h4>
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

    function buildSheetSelect(indicatorID, sheetData) {
        var select = $(document.createElement('select'))
            .attr('id', indicatorID + '_sheet_column')
            .attr('class', 'indicator_column_select');

        // "blank" option
        var option = $(document.createElement('option'))
            .attr('value', '-1')
            .html('');

        select.append(option);

        var keys = Object.keys(sheetData.headers);
        for (var i = 0; i < keys.length; i++) {
            var option = $(document.createElement('option'))
                .attr('value', keys[i])
                .html(keys[i] + ': ' + sheetData.headers[keys[i]]);

            select.append(option);
        }

        return select;
    }

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
            for (var i = 0; i < sheet_data.cells.length; i++) {
                var row = sheet_data.cells[i];
                var requestData = { 'title': titleInput.val() };

                for (var j = 0; j < currentIndicators.length; j++) {
                    var indicator = currentIndicators[j];
                    var indicatorColumn = $('#' + indicator.indicatorID + '_sheet_column').val();

                    if (indicator.format == 'orgchart_employee') {
                        nexusAPI.Employee.getByEmailNational(
                            row[indicatorColumn],
                            function (user) {
                                var emp = user[Object.keys(user)[0]];
                                requestData[parseInt(indicator.indicatorID)] = parseInt(emp.empUID);
                            },
                            function (error) {
                                console.log(error);
                            }
                        );
                    } else {
                        requestData[parseInt(indicator.indicatorID)] = row[indicatorColumn];
                    }
                }

                portalAPI.Forms.newRequest(
                    categorySelect.val(),
                    requestData,
                    function (recordID) {
                        if (recordID == 1) {
                            createCount += 1;
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
                // $('#import_data_main').html(JSON.stringify(results));
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

        categorySelect.on('change', function () {
            categoryIndicators.html('');

            portalAPI.Forms.getIndicatorsForForm(categorySelect.val(),
                function (results) {
                    currentIndicators = results;

                    for (var i = 0; i < results.length; i++) {
                        var indicator = results[i];
                        if (indicator !== undefined && indicator !== null) {
                            categoryIndicators.append(buildIndicatorRow(indicator));
                        }
                    }
                },
                function (error) {
                    console.log(error);
                }
            );
        })

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