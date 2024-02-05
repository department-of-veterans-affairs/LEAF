<style type="text/css">
    div#dataFieldContainer, div#progress, button#download {
        display:none;
    }
</style>

<script>
let headerArray = [];
let bodyObj = {};
let indicatorFormats = [];
let processedRecords = 0;

//populate dropdown for forms
$.ajax({
    type: 'GET',
    url: './api/form/categories'
}).done(function(data) {
    for(let i = 0; i < data.length; i++)
    {
        $('select#forms').append($("<option />").val(data[i].categoryID).text(data[i].categoryName));
    }
}).fail(function (jqXHR, error, errorThrown) {
    console.log(jqXHR);
    console.log(error);
    console.log(errorThrown);
});

//when a form is selected, populate the indicator select
$(document).on('change', 'select#forms', function() {
    $('button#download').hide();
    populateIndicators(this.value);
});

//when an indicator is selected, show download button
$(document).on('change', 'select#dataField', function() {
    if(this.value !== '')
    {
        $('button#download').show();
        $('div#progress').hide();
    }
    else
    {
        $('button#download').hide();
        $('div#progress').hide();
    }
});

//when button is clicked, start the export process
$(document).on('click', 'button#download', function() {
    if($('select#dataField').val() !== '')
    {
        buildHeaderArray(indicatorFormats[$('select#dataField').val()]);
        getDataForExport($('select#forms').val(), $('select#dataField').val());
    }
});

//populate dropdown of table input indicators
function populateIndicators(categoryID)
{
    if(categoryID != '')
    {
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
            for(let i = 0; i < data.length; i++)
            {
                const format = data[i].format;
                if (format.match(/^grid/) && data[i].isDisabled === 0) {
                    anyTables = true;
                    $('select#dataField').append($('<option />').val(data[i].indicatorID).text(data[i].name.replace( /(<([^>]+)>)/ig, '').replace('&nbsp;', ' ')));
                    indicatorFormats[data[i].indicatorID] = JSON.parse(format.substring(5));
                }
            }
            if(!anyTables)
            {
                $('div#dataFieldContainer').hide();
                alert('No grid input found in this form.');
            }
            else{
                $('div#dataFieldContainer').show();
            }
        }).fail(function (jqXHR, error, errorThrown) {
            console.log(jqXHR);
            console.log(error);
            console.log(errorThrown);
        });
    }
    else
    {
        $('div#dataFieldContainer').hide();
    }
}

//build the header array
//these will be the headers for the current version of the grid
function buildHeaderArray(columnNames)
{
    headerArray = [];
    if(typeof columnNames !== 'undefined')
    {
        for(let i = 0; i < columnNames.length; i++)
        {
            headerArray.push(columnNames[i].name);
        }
    }
}

//get all submitted records using this form
function getDataForExport(categoryID, indicatorID)
{
    processedRecords = 0;
    $.ajax({
        type: 'GET',
        url: './api/form/_'+categoryID+'/records'
    }).done(function(data) {
        bodyObj = {};
        for(let i = 0; i < data.length; i++)
        {
            if(data[i].submitted != 0)
            {
                bodyObj[data[i].recordID] = [];
            }
        }
        recordIDs = Object.keys(bodyObj);
        for(let i = 0; i < recordIDs.length; i++)
        {
            addRecordData(recordIDs[i], indicatorID)
        }
    }).fail(function (jqXHR, error, errorThrown) {
        console.log(jqXHR);
        console.log(error);
        console.log(errorThrown);
    });
}

//get data for the selected indicator associated with the given recordID
function addRecordData(recordID, indicatorID)
{
    $.ajax({
        type: 'GET',
        url: './api/formEditor/indicator/'+indicatorID,
        data: {
            recordID: recordID
        }
    }).done(function(data) {
        let dataRows = data[indicatorID]['value']['cells'];
        if (dataRows !== null && dataRows !== undefined) {
            for (let i = 0; i < dataRows.length; i++) {
                bodyObj[recordID].push(dataRows[i]);
            }
            updateProgress();
        } else {
            //if the data for this request isn't in table format, just mark as processed
            updateProgress();
        }
    }).fail(function (jqXHR, error, errorThrown) {
        console.log(jqXHR);
        console.log(error);
        console.log(errorThrown);
    });
}

//update the progress dialog
function updateProgress()
{
    let numberOfRecords = Object.keys(bodyObj).length;
    processedRecords++;
    $('div#progress span').html(processedRecords + "/" + numberOfRecords);

    if(processedRecords === numberOfRecords)
    {
        exportCSV();
    }
}

//build and deliver the CSV
function exportCSV()
{
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

    //unhide progress bar
    $('div#progress').show();
    $(output).each(function(idx, thisRow)
    {
        //escape double quotes
        $(thisRow).each(function(idx, col) {
            if(typeof col === 'string')
            {
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
</script>

<div id="tableInputExport">
    <label for="forms">Select a form: </label>
    <select name="forms" id="forms">
        <option value="">-Select Form-</option>
    </select>
    <br/><br/>
    <div id="dataFieldContainer">
        <label for="dataField">Select a data field: </label>
        <select name="dataField" id="dataField">
        </select>
    </div>
    <br/>
    <button class="buttonNorm" type="button" style="font-weight: bold; font-size: 120%" name="download" id="download">
        <img src="dynicons/?img=go-next.svg&amp;w=32" alt="">
        Download&nbsp;
    </button>
    <div id='progress'>Progress: <span></span></div>
</div>
