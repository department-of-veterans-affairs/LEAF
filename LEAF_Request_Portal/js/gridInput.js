var gridInput = function(gridParameters, indicatorID, series, recordID) {
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
    function printTableInput(values){
        var gridBodyElement = '#grid_' + indicatorID + '_' + series + '_input > tbody';
        var gridHeadElement = '#grid_' + indicatorID + '_' + series + '_input > thead';
        var rows = values.cells !== undefined && values.cells.length > 0 ? values.cells.length : 0;
        var columns = gridParameters.length;
        var element = '';
        var columnOrder = [];

        //fix for report builder
        //prevents duplicate table from being created on edit
        if($(gridHeadElement + ' > td:last').html() !== undefined){
            return 0;
        }

        //finds and displays column names
        //gives each cell in table head unique ID from form editor
        for(var i = 0; i < columns; i++){
            $(gridHeadElement).append('<td><div style="width: 100px;" id="' + gridParameters[i].id + '">' + gridParameters[i].name + '</div></td>');
            columnOrder.push(gridParameters[i].id);
        }

        //columns for row manipulation
        $(gridHeadElement).append('<td style="width: 17px;">&nbsp;</td><td style="width: 17px;">&nbsp;</td>');

        //populates table
        for(var i = 0; i < rows; i++){
            $(gridBodyElement).append('<tr></tr>');

            //generates row layout
            for(var j = 0; j < columns; j++){
                switch (gridParameters[j].type) {
                    case 'dropdown':
                        element = makeDropdown(gridParameters[j].options, null);
                        break;
                    case 'textarea':
                        element = '<textarea style="overflow-y:auto; overflow-x:hidden; resize: none; width:100%; height: 50px; -moz-box-sizing:border-box; -webkit-box-sizing:border-box; box-sizing:border-box; width: -webkit-fill-available; width: -moz-available; width: fill-available;"></textarea>';
                        break;
                    case 'text':
                        element = '<input value=""></input>';
                        break;
                    case 'date':
                        element = '<input data-type="grid-date" value=""></input>';
                        break;
                    default:
                        break;
                }
                $(gridBodyElement + ' > tr:eq(' + i + ')').append('<td aria-label="' + gridParameters[j].name + '">' + element + '</td>');
                $('input[data-type="grid-date"]').datepicker();
            }

            //assigns pre-existing values to cells based on its column
            //if its column has been deleted, the value is not assigned
            for(var j = 0; j < values.columns.length; j++){
                if(columnOrder.indexOf(values.columns[j]) !== -1) {
                    var value = values.cells === undefined || values.cells[i] === undefined || values.cells[i][j] === undefined || columnOrder.indexOf(values.columns[j]) === -1 ? '' : values.cells[i][j];
                    var newCoordinates = gridBodyElement + ' > tr:eq(' + i + ') > td:eq(' + columnOrder.indexOf(values.columns[j]) + ')';
                    switch ($(newCoordinates).children().first().prop("tagName")) {
                        case 'SELECT':
                            $(newCoordinates + ' > select').val(value);
                            break;
                        case 'TEXTAREA':
                            $(newCoordinates + ' > textarea').val(value);
                            break;
                        case 'INPUT':
                            $(newCoordinates + ' > input').val(value);
                            break;
                        default:
                            break;
                    }
                }
            }

            //arrow logic:
            //if there is only one row, arrows are not necessary
            if(rows === 1) {
                $(gridBodyElement + ' > tr:eq(' + i + ')').append('<td><img role="button" tabindex="0" onkeydown="gridInput_' + indicatorID + '_' + series + '.triggerClick(event);" onclick="gridInput_' + indicatorID + '_' + series + '.deleteRow(event)" src="../libs/dynicons/?img=process-stop.svg&w=16" title="Delete line" alt="Delete line" style="cursor: pointer" /></td><td><img role="button" tabindex="0" onkeydown="gridInput_' + indicatorID + '_' + series + '.triggerClick(event);" onclick="gridInput_' + indicatorID + '_' + series + '.moveUp(event)" src="../libs/dynicons/?img=go-up.svg&w=16" title="Move line up" alt="Move line up" style="display: none; cursor: pointer" /></br></br><img role="button" tabindex="0" onkeydown="gridInput_' + indicatorID + '_' + series + '.triggerClick(event);" onclick="gridInput_' + indicatorID + '_' + series + '.moveDown(event)" src="../libs/dynicons/?img=go-down.svg&w=16" title="Move line down" alt="Move line down" style="display: none; cursor: pointer" /></td>');
            } else {
                switch (i) {
                    case 0:
                        //first row only needs down arrow
                        $(gridBodyElement + ' > tr:eq(' + i + ')').append('<td><img role="button" tabindex="0" onkeydown="gridInput_' + indicatorID + '_' + series + '.triggerClick(event);" onclick="gridInput_' + indicatorID + '_' + series + '.deleteRow(event)" src="../libs/dynicons/?img=process-stop.svg&w=16" title="Delete line" alt="Delete line" style="cursor: pointer" /></td><td><img role="button" tabindex="0" onkeydown="gridInput_' + indicatorID + '_' + series + '.triggerClick(event);" onclick="gridInput_' + indicatorID + '_' + series + '.moveUp(event)" src="../libs/dynicons/?img=go-up.svg&w=16" title="Move line up" alt="Move line up" style="display: none; cursor: pointer" /></br></br><img role="button" tabindex="0" onkeydown="gridInput_' + indicatorID + '_' + series + '.triggerClick(event);" onclick="gridInput_' + indicatorID + '_' + series + '.moveDown(event)" src="../libs/dynicons/?img=go-down.svg&w=16" title="Move line down" alt="Move line down" style="cursor: pointer" /></td>');
                        break;
                    case rows - 1:
                        //last row only needs up arrow
                        $(gridBodyElement + ' > tr:eq(' + i + ')').append('<td><img role="button" tabindex="0" onkeydown="gridInput_' + indicatorID + '_' + series + '.triggerClick(event);" onclick="gridInput_' + indicatorID + '_' + series + '.deleteRow(event)" src="../libs/dynicons/?img=process-stop.svg&w=16" title="Delete line" alt="Delete line" style="cursor: pointer" /></td><td><img role="button" tabindex="0" onkeydown="gridInput_' + indicatorID + '_' + series + '.triggerClick(event);" onclick="gridInput_' + indicatorID + '_' + series + '.moveUp(event)" src="../libs/dynicons/?img=go-up.svg&w=16" title="Move line up" alt="Move line up" style="cursor: pointer" /></br></br><img role="button" tabindex="0" onkeydown="gridInput_' + indicatorID + '_' + series + '.triggerClick(event);" onclick="gridInput_' + indicatorID + '_' + series + '.moveDown(event)" src="../libs/dynicons/?img=go-down.svg&w=16" title="Move line down" alt="Move line down" style="display: none; cursor: pointer" /></td>');
                        break;
                    default:
                        //everything else needs both
                        $(gridBodyElement + ' > tr:eq(' + i + ')').append('<td><img role="button" tabindex="0" onkeydown="gridInput_' + indicatorID + '_' + series + '.triggerClick(event);" onclick="gridInput_' + indicatorID + '_' + series + '.deleteRow(event)" src="../libs/dynicons/?img=process-stop.svg&w=16" title="Delete line" alt="Delete line" style="cursor: pointer" /></td><td><img role="button" tabindex="0" onkeydown="gridInput_' + indicatorID + '_' + series + '.triggerClick(event);" onclick="gridInput_' + indicatorID + '_' + series + '.moveUp(event)" src="../libs/dynicons/?img=go-up.svg&w=16" title="Move line up" alt="Move line up" style="cursor: pointer" /></br></br><img role="button" tabindex="0" onkeydown="gridInput_' + indicatorID + '_' + series + '.triggerClick(event);" onclick="gridInput_' + indicatorID + '_' + series + '.moveDown(event)" src="../libs/dynicons/?img=go-down.svg&w=16" title="Move line down" alt="Move line down" style="cursor: pointer" /></td>');
                        break;
                }
            }
        }
    }
    function addRow(){
        var gridBodyElement = '#grid_' + indicatorID + '_' + series + '_input > tbody';
        //makes down arrow in last row visible
        $(gridBodyElement + ' > tr:last > td:last').find('[title="Move line down"]').css('display', 'inline');
        $(gridBodyElement).append('<tr></tr>');
        for(var i = 0; i < gridParameters.length; i++){
            switch (gridParameters[i].type) {
                case 'dropdown':
                    $(gridBodyElement + ' > tr:last').append('<td aria-label="' + gridParameters[i].name + '">' + makeDropdown(gridParameters[i].options, null) + '</td>');
                    break;
                case 'textarea':
                    $(gridBodyElement + ' > tr:last').append('<td aria-label="' + gridParameters[i].name + '"><textarea style="overflow-y:auto; overflow-x:hidden; resize: none; width:100%; height: 50px; -moz-box-sizing:border-box; -webkit-box-sizing:border-box; box-sizing:border-box; width: -webkit-fill-available; width: -moz-available; width: fill-available;"></textarea></td>');
                    break;
                case 'text':
                    $(gridBodyElement + ' > tr:last').append('<td aria-label="' + gridParameters[i].name + '"><input value=""></input></td>');
                    break;
                case 'date':
                    $(gridBodyElement + ' > tr:last').append('<td aria-label="' + gridParameters[i].name + '"><input data-type="grid-date" value=""></input></td>');
                    $('input[data-type="grid-date"]').datepicker();
                    break;
                default:
                    break;
            }
        }
        if($(gridBodyElement).children().length === 1){
            $(gridBodyElement + ' > tr:last').append('<td><img role="button" tabindex="0" onkeydown="gridInput_' + indicatorID + '_' + series + '.triggerClick(event);" onclick="gridInput_' + indicatorID + '_' + series + '.deleteRow(event)" src="../libs/dynicons/?img=process-stop.svg&w=16" title="Delete line" alt="Delete line" style="cursor: pointer" /></td><td><img role="button" tabindex="0" onkeydown="gridInput_' + indicatorID + '_' + series + '.triggerClick(event);" onclick="gridInput_' + indicatorID + '_' + series + '.moveUp(event)" src="../libs/dynicons/?img=go-up.svg&w=16" title="Move line up" alt="Move line up" style="cursor: pointer; display: none;" /></br></br><img role="button" tabindex="0" onkeydown="gridInput_' + indicatorID + '_' + series + '.triggerClick(event);" onclick="gridInput_' + indicatorID + '_' + series + '.moveDown(event)" style="display: none" src="../libs/dynicons/?img=go-down.svg&w=16" title="Move line down" alt="Move line down" style="cursor: pointer" /></td>');
        } else {
            $(gridBodyElement + ' > tr:last').append('<td><img role="button" tabindex="0" onkeydown="gridInput_' + indicatorID + '_' + series + '.triggerClick(event);" onclick="gridInput_' + indicatorID + '_' + series + '.deleteRow(event)" src="../libs/dynicons/?img=process-stop.svg&w=16" title="Delete line" alt="Delete line" style="cursor: pointer" /></td><td><img role="button" tabindex="0" onkeydown="gridInput_' + indicatorID + '_' + series + '.triggerClick(event);" onclick="gridInput_' + indicatorID + '_' + series + '.moveUp(event)" src="../libs/dynicons/?img=go-up.svg&w=16" title="Move line up" alt="Move line up" style="cursor: pointer" /></br></br><img role="button" tabindex="0" onkeydown="gridInput_' + indicatorID + '_' + series + '.triggerClick(event);" onclick="gridInput_' + indicatorID + '_' + series + '.moveDown(event)" style="display: none" src="../libs/dynicons/?img=go-down.svg&w=16" title="Move line down" alt="Move line down" style="cursor: pointer" /></td>');
        }
        $('#tableStatus').attr('aria-label', 'Row number ' + $(gridBodyElement).children().length + ' added, ' + $(gridBodyElement).children().length + ' total.');
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
        var rowDeleted = parseInt($(row).index()) + 1;
        var focus;
        switch(tbody.find('tr').length){
            case 1:
                row.remove();
                setTimeout(function () {
                    $('#addRowBtn').focus();
                }, 0);
            case 2:
                row.remove();
                focus = tbody.find('[title="Delete line"]');
                upArrows(tbody.find('tr'), false);
                downArrows(tbody.find('tr'), false);
                break;
            default:
                focus = row.next().find('[title="Delete line"]');
                if(row.find('[title="Move line down"]').css('display') === 'none'){
                    downArrows(row.prev(), false);
                    upArrows(row.prev(), true);
                    focus = row.prev().find('[title="Delete line"]');
                }
                if(row.find('[title="Move line up"]').css('display') === 'none'){
                    upArrows(row.next(), false);
                    downArrows(row.next(), true);
                }
                row.remove();
                break;
        }
        if (focus !== undefined) {
            //ie11 fix
            setTimeout(function () {
                focus.focus();
            }, 0);
        }

        $('#tableStatus').attr('aria-label', 'Row ' + rowDeleted + ' removed, ' + $(tbody).children().length + ' total.');
    }

    function moveDown(event){
        var row = $(event.target).closest('tr');
        var nextRowBottom = row.next().find('[title="Move line down"]').css('display') === 'none';
        var rowTop = row.find('[title="Move line up"]').css('display') === 'none';
        var focus;
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
            focus = row.find('td:last > img[title="Move line up"]');
        } else {
            focus = row.find('td:last > img[title="Move line down"]');
        }
        //ie11 fix
        setTimeout(function () {
            focus.focus();
        }, 0);
        $('#tableStatus').attr('aria-label', 'Moved down to row ' + (parseInt($(row).index()) + 1) + ' of ' + $(event.target).closest('tbody').children().length);
    }
    function moveUp(event){
        var row = $(event.target).closest('tr');
        var prevRowTop = row.prev().find('[title="Move line up"]').css('display') === 'none';
        var rowBottom = row.find('[title="Move line down"]').css('display') === 'none';
        var focus;
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
            focus = row.find('td:last > img[title="Move line down"]');
        } else {
            focus = row.find('td:last > img[title="Move line up"]');
        }
        //ie11 fix
        setTimeout(function () {
            focus.focus();
        }, 0);
        $('#tableStatus').attr('aria-label', 'Moved up to row ' + (parseInt($(row).index()) + 1) + ' of ' + $(event.target).closest('tbody').children().length);
    }
    function printTableOutput(values) {
        var gridBodyElement = '#grid_' + indicatorID + '_' + series + '_' + recordID + '_output > tbody';
        var gridHeadElement = '#grid_' + indicatorID + '_' + series + '_' + recordID + '_output > thead';
        var rows = values.cells === undefined ? 0 : values.cells.length;
        var columns = gridParameters.length;
        var columnOrder = [];

        //finds and displays column names
        for(var i = 0; i < columns; i++){
            $(gridHeadElement).append('<td style="width:100px">' + gridParameters[i].name + '</td>');
            columnOrder.push(gridParameters[i].id);
        }

        //populates table
        for (var i = 0; i < rows; i++) {
            $(gridBodyElement).append('<tr></tr>');

            //generates row layout
            for (var j = 0; j < columns; j++) {
                $(gridBodyElement + ' > tr:eq(' + i + ')').append('<td style="width:100px"></td>')
            }

            //assigns pre-existing values to cells based on its column
            //if its column has been deleted, the value is not assigned
            for (var j = 0; j < values.columns.length; j++) {
                if(columnOrder.indexOf(values.columns[j]) !== -1) {
                    var value = values.cells[i] === undefined || values.cells[i][j] === undefined ? '' : values.cells[i][j];
                    $(gridBodyElement + ' > tr:eq(' + i + ') > td:eq(' + columnOrder.indexOf(values.columns[j]) + ')').html(value);
                }
            }
        }
    }
    function printTablePreview(){
        var previewElement = '#grid' + indicatorID + '_' + series;

        for(var i = 0; i < gridParameters.length; i++){
            $(previewElement).append('<div style="padding: 10px; vertical-align: top; display: inline-block; flex: 1; order: '+ (i + 1) + '"><b>Column #' + (i + 1) + '</b></br>Title:' + gridParameters[i].name + '</br>Type:' + gridParameters[i].type + '</br></div>');
            if(gridParameters[i].type === 'dropdown'){
                $(previewElement + '> div:eq(' + i + ')').append('Options:</br><li>' + gridParameters[i].options.toString().replace(/,/g, "</li><li>") + '</li></br>');
            }
        }
    }
    return {
        addRow: addRow,
        preview: printTablePreview,
        output: printTableOutput,
        input: printTableInput,
        deleteRow: deleteRow,
        moveUp: moveUp,
        moveDown: moveDown,
        triggerClick: triggerClick
    };
};