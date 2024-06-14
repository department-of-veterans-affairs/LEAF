<style type="text/css">
    #bodyarea {
        padding: 1rem;
        min-height: 100vh;
        font-size:14px;
    }
    #tableInputExport {
        display: flex;
        flex-direction: column;
        gap: 1rem;
        align-items: flex-start;
    }
    div#dataFieldContainer, button#download {
        display:none;
    }
    label {
        display: block;
        margin-bottom:2px;
        font-weight: bolder;
    }
    select {
        font: inherit;
    }
</style>

<script>
const msgStart = "Use the dropdowns to select a question";
let headerArray = [];
let bodyObj = {};
let indicatorFormats = [];
let processedRecords = 0;
let totalResults = null;

//when an indicator is selected, show download button
function selectDataField(indicatorID = "") {
    $('#progress').text(msgStart);
    if(this.value !== '') {
        $('button#download').show();
    } else {
        $('button#download').hide();
    }
}

//when button is clicked, start the export process
$(document).on('click', 'button#download', function() {
    if($('select#dataField').val() !== '') {
        $('#progress').text('Processing ...');
        processedRecords = 0;
        totalResults = 0;
        buildHeaderArray(indicatorFormats[$('select#dataField').val()]);
        queryIndicator($('select#forms').val(), $('select#dataField').val());
    }
});

//populate dropdown of table input indicators
function populateIndicators(categoryID) {
    $('#progress').text(msgStart);
    if(categoryID != '') {
        $.ajax({
            type: 'GET',
            url: './api/form/indicator/list',
            data: {
                includeHeadings: 1,
                forms: categoryID
            }
        }).done(function(data) {
            $('select#dataField').empty();
            $('select#dataField').append($('<option />').val('').text('-Select Data Field-'));
            let anyTables = false;
            for(let i = 0; i < data.length; i++) {
                const format = data[i].format;
                if (format.match(/^grid/) && data[i].isDisabled === 0) {
                    anyTables = true;
                    let text = data[i].name.replace( /(<([^>]+)>)/ig, '').replace('&nbsp;', ' ');
                    text = text.length <= 55 ? text : text.slice(0, 55) + '...';
                    $('select#dataField').append($('<option />').val(data[i].indicatorID).text(text));
                    indicatorFormats[data[i].indicatorID] = JSON.parse(format.substring(5));
                }
            }
            if(!anyTables) {
                $('div#dataFieldContainer').hide();
                alert('No grid input found in this form.');
            } else{
                $('div#dataFieldContainer').show();
            }
        }).fail(function (jqXHR, error, errorThrown) {
            console.log(jqXHR);
            console.log(error);
            console.log(errorThrown);
        });

    } else {
        $('div#dataFieldContainer').hide();
    }
}

//build the header array
//these will be the headers for the current version of the grid
function buildHeaderArray(columnNames) {
    headerArray = [];
    if(typeof columnNames !== 'undefined') {
        for(let i = 0; i < columnNames.length; i++) {
            headerArray.push(columnNames[i].name);
        }
    }
}

//get data for the selected indicator associated with the given recordID
function addRecordData(recordID, indicatorID, gridInput = {}) {
    let dataRows = gridInput?.cells;
    bodyObj[recordID] = [];
    if (dataRows !== null && dataRows !== undefined) {
        for (let i = 0; i < dataRows.length; i++) {
            bodyObj[recordID].push(dataRows[i]);
        }
        updateProgress();
    } else {
        //if the data for this request isn't in table format, just mark as processed
        updateProgress();
    }
}

//update the progress dialog
function updateProgress() {
    processedRecords++;
    if(totalResults && processedRecords === totalResults) {
        $('#progress').text('Complete.  Total Results: ' + totalResults);
        exportCSV();
    }
}

//build and deliver the CSV
function exportCSV() {
    let output = [];
    let rows = '';
    let extraHeaderColumns = ['RecordID', 'tableRow'];
    output.push(extraHeaderColumns.concat(headerArray));
    let currentRow = 1;
    $.each( bodyObj, function( recordID, dataRowArray ) {
        $.each( dataRowArray, function( key, dataRow ) {
            let extraBodyColumns = [recordID, currentRow];
            output.push(extraBodyColumns.concat(dataRow));
            currentRow++;
        });
    });

    $(output).each(function(idx, thisRow) {
        //escape double quotes
        $(thisRow).each(function(idx, col) {
            if(typeof col === 'string') {
                thisRow[idx] = col.replace(/\"/g, "\"\"");
            }
        });
        //add to csv string
        rows += '"' + thisRow.join('","') + '",\r\n';
    });

    let download = document.createElement('a');
    let now = new Date().getTime();
    download.setAttribute('href', 'data:text/csv;charset=utf-8,' + encodeURIComponent(rows));
    download.setAttribute('download', 'Exported_' + now + '.csv');
    download.style.display = 'none';

    document.body.appendChild(download);
    if (navigator.msSaveOrOpenBlob) {
        navigator.msSaveOrOpenBlob(new Blob([rows], {type: 'text/csv;charset=utf-8;'}), "Exported_" + now + ".csv");
    } else {
        download.click();
    }
    document.body.removeChild(download);
}

async function queryIndicator(catID='', indicatorID=0) {
    let query = new LeafFormQuery();
    query.getData(indicatorID);
    query.addTerm('deleted', '=', 0);
    query.addTerm('submitted', '>', 0);
    query.addTerm('categoryID', '=', catID);

    let resultSet = {};
    query.onSuccess(function(res, resStatus, resJqXHR) {
        resultSet = Object.assign(resultSet, res);
        totalResults = Object.keys(resultSet)?.length || 0;
        if(totalResults === 0) {
            $('#progress').text("No requests for selection");
        } else {
            bodyObj = {};
            for(let recordID in resultSet) {
                addRecordData(recordID, indicatorID, resultSet[recordID]?.s1?.["id" + indicatorID + "_gridInput"]);
            }
        }
    });
    await query.execute();
}

function main() {
    //populate dropdown for forms
    $.ajax({
        type: 'GET',
        url: './api/form/categories'
    }).done(function(data) {
        for(let i = 0; i < data.length; i++) {
            $('select#forms').append($("<option />").val(data[i].categoryID).text(data[i].categoryName));
        }
        $('#progress').text(msgStart);
    }).fail(function (jqXHR, error, errorThrown) {
        console.log(jqXHR);
        console.log(error);
        console.log(errorThrown);
    });
}

document.addEventListener('DOMContentLoaded', main);
</script>

<div id="tableInputExport">
    <div id='progress'>Loading...</div>
    <div id="formsContainer">
        <label for="forms">Select a form: </label>
        <select name="forms" id="forms" onchange="populateIndicators(this.value)">
            <option value="">-Select Form-</option>
        </select>
    </div>
    <div id="dataFieldContainer">
        <label for="dataField">Select a data field:</label>
        <select name="dataField" id="dataField" onchange="selectDataField(this.value)"></select>
    </div>
    <button class="buttonNorm" type="button" style="font-weight: bold; font-size: 120%" name="download" id="download">
        <img src="dynicons/?img=go-next.svg&amp;w=32" alt="">
        Download
    </button>
</div>