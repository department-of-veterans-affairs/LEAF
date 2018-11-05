function makeDropdown(options, selected){
    var dropdownElement = 'Select an option<select>';
    for(var i = 0; i < options.length; i++){
        if(selected === options[i]){
            dropdownElement += '<option value="' + options[i] + '" selected="selected">' + options[i] + '</option>';
        }
        dropdownElement += '<option value="' + options[i] + '">' + options[i] + '</option>';
    }
    dropdownElement += '</select>';
    return dropdownElement;
}
function printTableInput(gridParameters, values, indicatorID, series){
    var gridBodyElement = '#grid_' + indicatorID + '_' + series + '_input > tbody';
    var rows = values.length;
    var columns = gridParameters.length;
    var element = '';

    //finds and displays column names
    $(gridBodyElement).append('<tr></tr>');
    for(var i = 0; i < columns; i++){
        $(gridBodyElement + ' > tr:eq(0)').append('<td><b>' + gridParameters[i].name + '</b></td>');
    }

    //populates table
    for(var i = 0; i < rows; i++){
        $(gridBodyElement).append('<tr></tr>');
        for(var j = 0; j < columns; j++){
            var value = values[i] === undefined || values[i][j] === undefined ? '[ blank ]' : values[i][j];
            if(gridParameters[j].type === 'dropdown'){
                element = makeDropdown(gridParameters[j].options, value);
            } else if(gridParameters[j].type === 'textarea'){
                element = '<textarea style="padding: 1px; vertical-align: middle; height: 50px; resize: none; width: 98%;">'+ value +'</textarea>';
            }
            $(gridBodyElement + ' > tr:eq(' + (i + 1) + ')').append('<td>' + element + '</td>')
        }
    }
}
function addRow(gridParameters, indicatorID, series){
    var gridBodyElement = '#grid_' + indicatorID + '_' + series + '_input > tbody';
    $(gridBodyElement).append('<tr></tr>');
    for(var i = 0; i < gridParameters.length; i++){
        if(gridParameters[i].type === 'textarea'){
            $(gridBodyElement + ' > tr:last').append('<td><textarea style="padding: 1px; vertical-align: middle; height: 50px; resize: none; width: 98%;"></textarea></td>');
        } else if(gridParameters[i].type === 'dropdown'){
            $(gridBodyElement + ' > tr:last').append('<td>' + makeDropdown(gridParameters[i].options, null) + '</td>');
        }
    }
}
function deleteRow(indicatorID, series){
    var gridBodyElement = '#grid_' + indicatorID + '_' + series + '_input > tbody';

    //prevents deletion of column name row
    if($(gridBodyElement).find('tr').length > 1){
        $(gridBodyElement + ' > tr:last').remove();
    } else {
        alert('Cannot remove inital row.');
    }
}
function printTableOutput(gridParameters, values, indicatorID, series) {
    var gridBodyElement = '#grid_' + indicatorID + '_' + series + '_output > tbody';
    var rows = values.length;
    var columns = gridParameters.length;

    //finds and displays column names
    $(gridBodyElement).append('<tr></tr>');
    for(var i = 0; i < columns; i++){
        $(gridBodyElement + ' > tr:eq(0)').append('<td style="flex: 1; background-color: gainsboro; font-size: 20px; word-wrap:break-word">' + gridParameters[i].name + '</td>');
    }

    //populates table
    for (var i = 0; i < rows; i++) {
        $(gridBodyElement).append('<tr></tr>');
        for (var j = 0; j < columns; j++) {
            var value = values[i] === undefined || values[i][j] === undefined ? '[ blank ]' : values[i][j];
            $(gridBodyElement + ' > tr:eq(' + (i + 1) + ')').append('<td style="flex: 1; word-wrap:break-word">' + value + '</td>')
        }
    }
}