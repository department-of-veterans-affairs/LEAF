function makeDropdown(options, selected){
    var dropdownElement = '<select role="dropdown" style="width:100%; -moz-box-sizing:border-box; -webkit-box-sizing:border-box; box-sizing:border-box; width: -webkit-fill-available; width: -moz-available; width: fill-available;">';
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
function printTableInput(gridParameters, values, indicatorID, series){
    var gridBodyElement = '#grid_' + indicatorID + '_' + series + '_input > tbody';
    var gridHeadElement = '#grid_' + indicatorID + '_' + series + '_input > thead';
    var rows = values.cells !== undefined && values.cells.length > 0 ? values.cells.length : 0;
    var columns = gridParameters.length;
    var element = '';

    //fix for report builder
    //prevents duplicate table from being created on edit
    if($(gridHeadElement + ' > td:last').html() !== undefined){
        return 0;
    }

    //finds and displays column names
    for(var i = 0; i < columns; i++){
        $(gridHeadElement).append('<td>' + gridParameters[i].name + '</td>');
    }
    $(gridHeadElement).append('<td style="width: 17px;">&nbsp;</td>');

    //populates table
    for(var i = 0; i < rows; i++){
        $(gridBodyElement).append('<tr></tr>');
        for(var j = 0; j < columns; j++){
            var value = values.cells === undefined || values.cells[i] === undefined || values.cells[i][j] === undefined ? '' : values.cells[i][j];
            if(gridParameters[j].type === 'dropdown'){
                element = makeDropdown(gridParameters[j].options, value);
            } else if(gridParameters[j].type === 'textarea'){
                element = '<textarea style="overflow-y:auto; overflow-x:hidden; resize: none; width:100%; height: 50px; -moz-box-sizing:border-box; -webkit-box-sizing:border-box; box-sizing:border-box; width: -webkit-fill-available; width: -moz-available; width: fill-available;">'+ value +'</textarea>';
            }
            $(gridBodyElement + ' > tr:eq(' + i + ')').append('<td>' + element + '</td>');
        }
        //arrow logic:
        //if there is only one row, arrows are not necessary
        if(rows === 1) {
            $(gridBodyElement + ' > tr:eq(' + i + ')').append('<td><img role="button" tabindex="0" onkeydown="triggerClick(event);" onclick="moveUp(event)" src="../libs/dynicons/?img=go-up.svg&w=16" title="Move line up" alt="Move line up" style="display: none; cursor: pointer" /></br><img role="button" tabindex="0" onkeydown="triggerClick(event);" onclick="deleteRow(event)" src="../libs/dynicons/?img=process-stop.svg&w=16" title="Delete line" alt="Delete line" style="cursor: pointer" /></br><img role="button" tabindex="0" onkeydown="triggerClick(event);" onclick="moveDown(event)" src="../libs/dynicons/?img=go-down.svg&w=16" title="Move line down" alt="Move line down" style="display: none; cursor: pointer" /></td>');
        } else {
            switch (i) {
                case 0:
                    //first row only needs down arrow
                    $(gridBodyElement + ' > tr:eq(' + i + ')').append('<td><img role="button" tabindex="0" onkeydown="triggerClick(event);" onclick="moveUp(event)" src="../libs/dynicons/?img=go-up.svg&w=16" title="Move line up" alt="Move line up" style="display: none; cursor: pointer" /></br><img role="button" tabindex="0" onclick="deleteRow(event)" onkeydown="triggerClick(event);" src="../libs/dynicons/?img=process-stop.svg&w=16" title="Delete line" alt="Delete line" style="cursor: pointer" /></br><img role="button" tabindex="0" onkeydown="triggerClick(event);" onclick="moveDown(event)" src="../libs/dynicons/?img=go-down.svg&w=16" title="Move line down" alt="Move line down" style="cursor: pointer" /></td>');
                    break;
                case rows - 1:
                    //last row only needs up arrow
                    $(gridBodyElement + ' > tr:eq(' + i + ')').append('<td><img role="button" tabindex="0" onkeydown="triggerClick(event);" onclick="moveUp(event)" src="../libs/dynicons/?img=go-up.svg&w=16" title="Move line up" alt="Move line up" style="cursor: pointer" /></br><img role="button" tabindex="0" onclick="deleteRow(event)" onkeydown="triggerClick(event);" src="../libs/dynicons/?img=process-stop.svg&w=16" title="Delete line" alt="Delete line" style="cursor: pointer" /></br><img role="button" tabindex="0" onkeydown="triggerClick(event);" onclick="moveDown(event)" src="../libs/dynicons/?img=go-down.svg&w=16" title="Move line down" alt="Move line down" style="display: none; cursor: pointer" /></td>');
                    break;
                default:
                    //everything else needs both
                    $(gridBodyElement + ' > tr:eq(' + i + ')').append('<td><img role="button" tabindex="0" onkeydown="triggerClick(event);" onclick="moveUp(event)" src="../libs/dynicons/?img=go-up.svg&w=16" title="Move line up" alt="Move line up" style="cursor: pointer" /></br><img role="button" tabindex="0" onclick="deleteRow(event)" onkeydown="triggerClick(event);" src="../libs/dynicons/?img=process-stop.svg&w=16" title="Delete line" alt="Delete line" style="cursor: pointer" /></br><img role="button" tabindex="0" onkeydown="triggerClick(event);" onclick="moveDown(event)" src="../libs/dynicons/?img=go-down.svg&w=16" title="Move line down" alt="Move line down" style="cursor: pointer" /></td>');
                    break;
            }
        }
    }
}
function addRow(gridParameters, indicatorID, series){
    var gridBodyElement = '#grid_' + indicatorID + '_' + series + '_input > tbody';
    //makes down arrow in last row visible
    $(gridBodyElement + ' > tr:last > td:last').find('[title="Move line down"]').css('display', 'inline');
    $(gridBodyElement).append('<tr></tr>');
    for(var i = 0; i < gridParameters.length; i++){
        if(gridParameters[i].type === 'textarea'){
            $(gridBodyElement + ' > tr:last').append('<td><textarea style="overflow-y:auto; overflow-x:hidden; resize: none; width:100%; height: 50px; -moz-box-sizing:border-box; -webkit-box-sizing:border-box; box-sizing:border-box; width: -webkit-fill-available; width: -moz-available; width: fill-available;"></textarea></td>');
        } else if(gridParameters[i].type === 'dropdown'){
            $(gridBodyElement + ' > tr:last').append('<td>' + makeDropdown(gridParameters[i].options, null) + '</td>');
        }
    }
    if($(gridBodyElement).children().length === 1){
        $(gridBodyElement + ' > tr:last').append('<td><img role="button" tabindex="0" onkeydown="triggerClick(event);" onclick="moveUp(event)" src="../libs/dynicons/?img=go-up.svg&w=16" title="Move line up" alt="Move line up" style="cursor: pointer; display: none;" /></br><img role="button" tabindex="0" onkeydown="triggerClick(event);" onclick="deleteRow(event)" src="../libs/dynicons/?img=process-stop.svg&w=16" title="Delete line" alt="Delete line" style="cursor: pointer" /></br><img role="button" tabindex="0" onkeydown="triggerClick(event);" onclick="moveDown(event)" style="display: none" src="../libs/dynicons/?img=go-down.svg&w=16" title="Move line down" alt="Move line down" style="cursor: pointer" /></td>');
    } else {
        $(gridBodyElement + ' > tr:last').append('<td><img role="button" tabindex="0" onkeydown="triggerClick(event);" onclick="moveUp(event)" src="../libs/dynicons/?img=go-up.svg&w=16" title="Move line up" alt="Move line up" style="cursor: pointer" /></br><img role="button" tabindex="0" onkeydown="triggerClick(event);" onclick="deleteRow(event)" src="../libs/dynicons/?img=process-stop.svg&w=16" title="Delete line" alt="Delete line" style="cursor: pointer" /></br><img role="button" tabindex="0" onkeydown="triggerClick(event);" onclick="moveDown(event)" style="display: none" src="../libs/dynicons/?img=go-down.svg&w=16" title="Move line down" alt="Move line down" style="cursor: pointer" /></td>');
    }
}
// click function for 508 compliance
function triggerClick(event){
    if(event.keyCode === 13){
        $(event.target).trigger('click');
    }
}
function deleteRow(event){
    var row = $(event.target).closest('tr');
    var tbody = $(event.target).closest('tbody');
    switch(tbody.find('tr').length){
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

function moveDown(event){
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
    if(nextRowBottom){
        row.find('td:last > img[title="Move line up"]').focus();
    } else {
        row.find('td:last > img[title="Move line down"]').focus();
    }
}
function moveUp(event){
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
    if(prevRowTop){
        row.find('td:last > img[title="Move line down"]').focus();
    } else {
        row.find('td:last > img[title="Move line up"]').focus();
    }
}
function printTableOutput(gridParameters, values, indicatorID, series) {
    var gridBodyElement = '#grid_' + indicatorID + '_' + series + '_output > tbody';
    var gridHeadElement = '#grid_' + indicatorID + '_' + series + '_output > thead';
    var rows = values.cells === undefined ? 0 : values.cells.length;
    var columns = gridParameters.length;

    //finds and displays column names
    for(var i = 0; i < columns; i++){
        $(gridHeadElement).append('<td style="width:100px">' + gridParameters[i].name + '</td>');
    }

    //populates table
    for (var i = 0; i < rows; i++) {
        $(gridBodyElement).append('<tr></tr>');
        for (var j = 0; j < columns; j++) {
            var value = values.cells[i] === undefined || values.cells[i][j] === undefined ? '' : values.cells[i][j];
            $(gridBodyElement + ' > tr:eq(' + i + ')').append('<td style="width:100px">' + value + '</td>')
        }
    }
}
function printTablePreview(gridParameters, indicatorID, series){
    var previewElement = '#grid' + indicatorID + '_' + series;

    for(var i = 0; i < gridParameters.length; i++){
        $(previewElement).append('<div style="padding: 10px; vertical-align: top; display: inline-block; flex: 1; order: '+ (i + 1) + '"><b>Column #' + (i + 1) + '</b></br>Title:' + gridParameters[i].name + '</br>Type:' + gridParameters[i].type + '</br></div>');
        if(gridParameters[i].type === 'dropdown'){
            $(previewElement + '> div:eq(' + i + ')').append('Options:</br><li>' + gridParameters[i].options.toString().replace(/,/g, "</li><li>") + '</li></br>');
        }
    }
}