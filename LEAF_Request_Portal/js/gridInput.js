function makeDropdown(options, selected){
    var dropdownElement = 'Select an option<select>';
    for(var i = 0; i < options.length; i++){
        if(selected === options[i]){
            dropdownElement += '<option value="' + options[i] + '" selected="selected">' + options[i] + '</option>';
        } else {
            dropdownElement += '<option value="' + options[i] + '">' + options[i] + '</option>';
        }
    }
    dropdownElement += '</select>';
    return dropdownElement;
}
function printTableInput(gridParameters, values, indicatorID, series){
    var gridBodyElement = '#grid_' + indicatorID + '_' + series + '_input > tbody';
    var gridHeadElement = '#grid_' + indicatorID + '_' + series + '_input > thead';
    var rows = values.length > 0 ? values.length : 1;
    var columns = gridParameters.length;
    var element = '';

    //finds and displays column names
    for(var i = 0; i < columns; i++){
        $(gridHeadElement).append('<td>' + gridParameters[i].name + '</td>');
    }
    $(gridHeadElement).append('<td>&nbsp;</td>');

    //populates table
    for(var i = 0; i < rows; i++){
        $(gridBodyElement).append('<tr></tr>');
        for(var j = 0; j < columns; j++){
            var value = values[i] === undefined || values[i][j] === undefined ? '' : values[i][j];
            if(gridParameters[j].type === 'dropdown'){
                element = makeDropdown(gridParameters[j].options, value);
            } else if(gridParameters[j].type === 'textarea'){
                element = '<textarea style="position: absolute; resize: none; width: -webkit-fill-available; top: 0; left: 0; right: 0; bottom: 0;">'+ value +'</textarea>';
            }
            $(gridBodyElement + ' > tr:eq(' + i + ')').append('<td style="position: relative;">' + element + '</td>');
        }
        if(rows === 1) {
            $(gridBodyElement + ' > tr:eq(' + i + ')').append('<td><img onclick="moveUp()" src="../libs/dynicons/?img=go-up.svg&w=16" title="Move line up" alt="Move line up" style="display: none; cursor: pointer" /></br><img onclick="deleteRow()" src="../libs/dynicons/?img=process-stop.svg&w=16" title="Delete line" alt="Delete line" style="cursor: pointer" /></br><img onclick="moveDown()" src="../libs/dynicons/?img=go-down.svg&w=16" title="Move line down" alt="Move line down" style="display: none; cursor: pointer" /></td>');
        } else {
            switch (i) {
                case 0:
                    $(gridBodyElement + ' > tr:eq(' + i + ')').append('<td><img onclick="moveUp()" src="../libs/dynicons/?img=go-up.svg&w=16" title="Move line up" alt="Move line up" style="display: none; cursor: pointer" /></br><img onclick="deleteRow()" src="../libs/dynicons/?img=process-stop.svg&w=16" title="Delete line" alt="Delete line" style="cursor: pointer" /></br><img onclick="moveDown()" src="../libs/dynicons/?img=go-down.svg&w=16" title="Move line down" alt="Move line down" style="cursor: pointer" /></td>');
                    break;
                case rows - 1:
                    $(gridBodyElement + ' > tr:eq(' + i + ')').append('<td><img onclick="moveUp()" src="../libs/dynicons/?img=go-up.svg&w=16" title="Move line up" alt="Move line up" style="cursor: pointer" /></br><img onclick="deleteRow()" src="../libs/dynicons/?img=process-stop.svg&w=16" title="Delete line" alt="Delete line" style="cursor: pointer" /></br><img onclick="moveDown()" src="../libs/dynicons/?img=go-down.svg&w=16" title="Move line down" alt="Move line down" style="display: none; cursor: pointer" /></td>');
                    break;
                default:
                    $(gridBodyElement + ' > tr:eq(' + i + ')').append('<td><img onclick="moveUp()" src="../libs/dynicons/?img=go-up.svg&w=16" title="Move line up" alt="Move line up" style="cursor: pointer" /></br><img onclick="deleteRow()" src="../libs/dynicons/?img=process-stop.svg&w=16" title="Delete line" alt="Delete line" style="cursor: pointer" /></br><img onclick="moveDown()" src="../libs/dynicons/?img=go-down.svg&w=16" title="Move line down" alt="Move line down" style="cursor: pointer" /></td>');
                    break;
            }
        }
    }
}
function addRow(gridParameters, indicatorID, series){
    var gridBodyElement = '#grid_' + indicatorID + '_' + series + '_input > tbody';
    $(gridBodyElement + ' > tr:last > td:last').find('[title="Move line down"]').css('display', 'inline');
    $(gridBodyElement).append('<tr></tr>');
    for(var i = 0; i < gridParameters.length; i++){
        if(gridParameters[i].type === 'textarea'){
            $(gridBodyElement + ' > tr:last').append('<td style="position: relative;"><textarea style="position: absolute; resize: none; width: -webkit-fill-available; top: 0; left: 0; right: 0; bottom: 0;"></textarea></td>');
        } else if(gridParameters[i].type === 'dropdown'){
            $(gridBodyElement + ' > tr:last').append('<td>' + makeDropdown(gridParameters[i].options, null) + '</td>');
        }
    }
    $(gridBodyElement + ' > tr:last').append('<td><img onclick="moveUp()" src="../libs/dynicons/?img=go-up.svg&w=16" title="Move line up" alt="Move line up" style="cursor: pointer" /></br><img onclick="deleteRow()" src="../libs/dynicons/?img=process-stop.svg&w=16" title="Delete line" alt="Delete line" style="cursor: pointer" /></br><img onclick="moveDown()" style="display: none" src="../libs/dynicons/?img=go-down.svg&w=16" title="Move line down" alt="Move line down" style="cursor: pointer" /></td>');
}
function deleteRow(){
    var row = $(event.target).closest('tr');
    var tbody = $(event.target).closest('tbody');
    switch(tbody.find('tr').length){
        case 1:
            alert('Cannot remove inital row.');
            break;
        case 2:
            row.remove();
            upArrows(tbody.find('tr'), false);
            downArrows(tbody.find('tr'), false);
            break;
        default:
            if(row.find('[title="Move line down"]').css('display') === 'none'){
                downArrows(row.prev(), false);
                upArrows(row.prev(), true);
            }
            if(row.find('[title="Move line up"]').css('display') === 'none'){
                upArrows(row.next(), false);
                downArrows(row.next(), true);
            }
            row.remove();
            break;
    }
}
function upArrows(row, toggle){
    if(toggle){
        row.find('[title="Move line up"]').css('display', 'inline');
    } else {
        row.find('[title="Move line up"]').css('display', 'none');
    }
}
function downArrows(row, toggle){
    if(toggle){
        row.find('[title="Move line down"]').css('display', 'inline');
    } else {
        row.find('[title="Move line down"]').css('display', 'none');
    }
}
function moveDown(){
    var row = $(event.target).closest('tr');
    var nextRowBottom = row.next().find('[title="Move line down"]').css('display') === 'none';
    var rowTop = row.find('[title="Move line up"]').css('display') === 'none';
    upArrows(row, true);
    if(nextRowBottom){
        downArrows(row, false);
        downArrows(row.next(), true);
    }
    if(rowTop){
        upArrows(row.next(), false);
    }
    row.insertAfter(row.next());
}
function moveUp(){
    var row = $(event.target).closest('tr');
    var prevRowTop = row.prev().find('[title="Move line up"]').css('display') === 'none';
    var rowBottom = row.find('[title="Move line down"]').css('display') === 'none';
    downArrows(row, true);
    if(prevRowTop){
        upArrows(row, false);
        upArrows(row.prev(), true);
    }
    if(rowBottom){
        downArrows(row.prev(), false);
    }
    row.insertBefore(row.prev());
}
function printTableOutput(gridParameters, values, indicatorID, series) {
    var gridBodyElement = '#grid_' + indicatorID + '_' + series + '_output > tbody';
    var gridHeadElement = '#grid_' + indicatorID + '_' + series + '_output > thead';
    var rows = values.length;
    var columns = gridParameters.length;

    //finds and displays column names
    for(var i = 0; i < columns; i++){
        $(gridHeadElement).append('<td>' + gridParameters[i].name + '</td>');
    }
    if(rows === 0){
        $(gridBodyElement).append('<tr></tr>');
        for(var i = 0; i < columns; i++){
            $(gridBodyElement + ' > tr').append('<td></td>');
        }
    }

    //populates table
    for (var i = 0; i < rows; i++) {
        $(gridBodyElement).append('<tr></tr>');
        for (var j = 0; j < columns; j++) {
            var value = values[i] === undefined || values[i][j] === undefined ? '[ blank ]' : values[i][j];
            $(gridBodyElement + ' > tr:eq(' + i + ')').append('<td>' + value + '</td>')
        }
    }
}