<?php
/* Smarty version 3.1.33, created on 2021-08-16 15:47:57
  from '/var/www/html/LEAF_Request_Portal/templates/reports/LEAF_table_input_report.tpl' */

/* @var Smarty_Internal_Template $_smarty_tpl */
if ($_smarty_tpl->_decodeProperties($_smarty_tpl, array (
  'version' => '3.1.33',
  'unifunc' => 'content_611a88ad6b7416_12972874',
  'has_nocache_code' => false,
  'file_dependency' => 
  array (
    '8e01e27040648866e0738df5d70fdc2bd4a76787' => 
    array (
      0 => '/var/www/html/LEAF_Request_Portal/templates/reports/LEAF_table_input_report.tpl',
      1 => 1626204510,
      2 => 'file',
    ),
  ),
  'includes' => 
  array (
  ),
),false)) {
function content_611a88ad6b7416_12972874 (Smarty_Internal_Template $_smarty_tpl) {
?><style type="text/css">
    div#dataFieldContainer, div#progress, button#download {
        display:none;
    }
</style>

<?php echo '<script'; ?>
>
var headerArray = [];
var bodyObj = {};
var indicatorFormats = [];
var processedRecords = 0;

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
    }
    else
    {
        $('button#download').hide();
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
            url: './api/?a=form/indicator/list',
            data: {
                includeHeadings: 1,
                forms: categoryID
            }
        }).done(function(data) {
            $('select#dataField').empty();
            $('select#dataField').append($('<option />').val('').text('-Select Data Field-'));
            var anyTables = false;
            for(var i = 0; i < data.length; i++)
            {
                var format = data[i].format;
                if (format.match("^grid")) {
                    anyTables = true;
                    $('select#dataField').append($('<option />').val(data[i].indicatorID).text(data[i].name));
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
        for(var i = 0; i < columnNames.length; i++)
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
        if(data[indicatorID]['value']['cells'] !== null && data[indicatorID]['value']['cells'] !== undefined)
        {
            var dataRows = data[indicatorID]['value']['cells'];
            for(var i = 0; i < dataRows.length; i++)
            {
                bodyObj[recordID].push(dataRows[i]);
            }
            updateProgress();
        }
        else
        {
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
        console.log(recordID);
        $.each( dataRowArray, function( key, dataRow ) {
            console.log(dataRowArray);
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
<?php echo '</script'; ?>
>

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
        <img src="../libs/dynicons/?img=go-next.svg&amp;w=32" alt="Download"> 
        Download&nbsp; 
    </button>
    <div id='progress'>Progress: <span></span></div>
</div><?php }
}
