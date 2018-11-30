<style type="text/css">
    select#indicators, div#progress {
        display:none;
    }
</style>

<script>
var headerArray = [];
var bodyObj = {};
var indicatorFormats = [];
var processedRecords = 0;

$(document).on('change', 'select#forms', function() {
    populateIndicators(this.value);
});

$(document).on('change', 'select#indicators', function() {
    buildHeaderArray(indicatorFormats[this.value]);
    getDataForExport($('select#forms').val(), this.value);
});

//populate dropdown for forms
$.ajax({
    type: 'GET',
    url: './api/?a=form/categories'
}).done(function(data) {
    for(var i = 0; i < data.length; i++)
    {
        $('select#forms').append($("<option />").val(data[i].categoryID).text(data[i].categoryName));
    }
}).fail(function (jqXHR, error, errorThrown) {
    console.log(jqXHR);
    console.log(error);
    console.log(errorThrown);
});

//populate dropdown of table input indicators
function populateIndicators(categoryID)
{
    if(categoryID != '')
    {
        $.ajax({
            type: 'GET',
            url: './api/?a=form/indicator/list',
            data: {
                includeHeadings: 1,
                forms: categoryID
            }
        }).done(function(data) {
            $('select#indicators').empty();
            $('select#indicators').append($('<option />').val('').text('-Select Indicator-'));
            var anyTables = false;
            for(var i = 0; i < data.length; i++)
            {
                var format = data[i].format;
                if (format.match("^grid")) {
                    anyTables = true;
                    $('select#indicators').append($('<option />').val(data[i].indicatorID).text(data[i].name));
                    indicatorFormats[data[i].indicatorID] = JSON.parse(format.substring(5));
                }
            }
            if(!anyTables)
            {
                $('select#indicators').hide();
                alert('No grid input found in this form.');
            }
            else{
                $('select#indicators').show();
            }
        }).fail(function (jqXHR, error, errorThrown) {
            console.log(jqXHR);
            console.log(error);
            console.log(errorThrown);
        });
    }
    else
    {
        $('select#indicators').hide();
    }
}

//get all submitted records using this form
function getDataForExport(categoryID, indicatorID)
{
    processedRecords = 0;
    $.ajax({
        type: 'GET',
        url: './api/?a=form/_'+categoryID+'/records'
    }).done(function(data) {
        bodyObj = {};
        for(var i = 0; i < data.length; i++)
        {
            if(data[i].submitted != 0)
            {
                bodyObj[data[i].recordID] = [];
            }
        }
        recordIDs = Object.keys(bodyObj);
        for(var i = 0; i < recordIDs.length; i++)
        {
            addRecordData(recordIDs[i], indicatorID)
        }
    }).fail(function (jqXHR, error, errorThrown) {
        console.log(jqXHR);
        console.log(error);
        console.log(errorThrown);
    });
}

//build the header array
function buildHeaderArray(columnNames)
{
    headerArray = [];
    if(typeof columnNames !== 'undefined')
    {
        for(var i = 0; i < columnNames.length; i++)
        {
            headerArray.push(columnNames[i].name);
        }
    }
}

//get data for the selected indicator associated with the given recordID
function addRecordData(recordID, indicatorID)
{
    $.ajax({
        type: 'GET',
        url: './api/?a=formEditor/indicator/'+indicatorID,
        data: {
            recordID: recordID
        }
    }).done(function(data) {
        var dataRows = data[indicatorID]['value']['cells'];
        for(var i = 0; i < dataRows.length; i++)
        {
            bodyObj[recordID] = dataRows[i];
        }
        updateProgress();
    }).fail(function (jqXHR, error, errorThrown) {
        console.log(jqXHR);
        console.log(error);
        console.log(errorThrown);
    });
}

//update the progress dialog
function updateProgress()
{
    var numberOfRecords = Object.keys(bodyObj).length;
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
    var output = [];
    var rows = '';

    var extraHeaderColumns = ['RecordID', 'tableRow'];
    output.push(extraHeaderColumns.concat(headerArray));

    var currentRow = 1;
    $.each( bodyObj, function( recordID, dataRowArray ) {
        $.each( bodyObj, function( key, dataRow ) {
            var extraBodyColumns = [recordID, currentRow];
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

    var download = document.createElement('a');
    var now = new Date().getTime();
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
    <select id="forms">
        <option value="">-Select Form-</option>
    </select>
    <br/>
    <select id="indicators">
    </select>
    <div id='progress'>Progress: <span></span></div>
</div>