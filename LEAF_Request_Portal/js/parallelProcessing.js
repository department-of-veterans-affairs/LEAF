function selectForParallelProcessing(recordID, orgChartPath)
{
    var indicatorObject = new Object();//indicators to select from
    var indicatorToSubmit = null;//the selected indicator
    var employeeObj = new Object();//selected employees
    var groupObj = new Object();//selected groups
    var empSel;
    var grpSel;
    var jsonToSubmit;

    function fillIndicatorDropdown() 
    {
        $.ajax({
            type: 'GET',
            url: 'api/?a=formEditor/indicator/'+recordID+'/format/',
            data: {'formats': ['orgchart_employee','orgchart_group']},
            success: function(obj) {
                indicatorObject = obj;
                for (var i = 0; i < indicatorObject.length; i++) {
                    var format = indicatorObject[i].format;
                    $(document.createElement('option'))
                        .attr('value', indicatorObject[i].indicatorID)
                        .html(indicatorObject[i].name)
                        .appendTo($("select#indicator_selector"));
                }
            },
            error: function(xhr, status, error) {
                dialog.hide();
                alert('There must be an indicator of type "orgchart group" or "orgchart employee" to perform begin Parallel Processing.');
            }
        });

        $("select#indicator_selector").on('change', function() {
            selectIndicator(this.value);
        });   
    }

    //show the appropriate selector (group/employee) for the indicatorSelected
    function selectIndicator(selectorValue)
    {
        var newIndicatorToSubmit = null;
        var newFormat = null;
        var doSwitch = false;
        
        //find this indicator
        for (var key in indicatorObject) 
        {
            if(indicatorObject[key].indicatorID == selectorValue)
            {
                newIndicatorToSubmit = indicatorObject[key];
                newFormat = newIndicatorToSubmit.format;
            }
        }

        //compare the selected indicator's format to the previously selected one
        if(indicatorToSubmit === null || indicatorToSubmit.format !== newFormat)
        {
            switch(newFormat) {
                case 'orgchart_group':
                    grpSel = new groupSelector('grpSelector');
                    grpSel.rootPath = orgChartPath+'/';
                    grpSel.apiPath = orgChartPath+'/api/';
                    grpSel.setSelectHandler(function(){
                        $('#'+this.prefixID+'grp'+this.selection).removeClass('groupSelected');
                        $('#'+this.prefixID+'grp'+this.selection).addClass('groupSelector');
                        var name = $('#'+this.prefixID+'grp'+this.selection+' > .groupSelectorTitle').html();
                        addToList(this.selection, name);
                    });
                    grpSel.setResultHandler(function(){
                        if(this.numResults > 0) {
                            $('table.groupSelectorTable tr:first').append('<th>&nbsp;</th>');
                            for(var i in this.selectionData) {
                                $('#'+this.prefixID+'grp'+i).off('click');
                                $('#'+this.prefixID+'grp'+i).append('<td class="groupSelectorAddToList"><button id="btn'+i+'" type="button">+</button></td>');
                            }
                        }
                    });
                    grpSel.initialize();
                    $('.emp_visibility').hide();
                    $('.grp_visibility').show();
                    break;
                case 'orgchart_employee':
                    empSel = new nationalEmployeeSelector('empSelector');
                    empSel.rootPath = orgChartPath+'/';
                    empSel.apiPath = orgChartPath+'/api/';
                    empSel.setSelectHandler(function(){
                        $('#'+this.prefixID+'emp'+this.selection).removeClass('employeeSelected');
                        $('#'+this.prefixID+'emp'+this.selection).addClass('employeeSelector');
                        var name = $('#'+this.prefixID+'emp'+this.selection+' > .employeeSelectorName').html();
                        addToList(this.selection, name);
                    });
                    empSel.setResultHandler(function(){
                        if(this.numResults > 0) {
                            $('table.employeeSelectorTable tr:first').append('<th>&nbsp;</th>');
                            for(var i in this.selectionData) {
                                $('#'+this.prefixID+'emp'+i).off('click');
                                $('#'+this.prefixID+'emp'+i).append('<td class="employeeSelectorAddToList"><button id="btn'+i+'" type="button">+</button></td>');
                            }
                        }
                    });
                    empSel.initialize();
                    $('.grp_visibility').hide();
                    $('.emp_visibility').show();
                    break;
                default:
                    $('.grp_visibility').hide();
                    $('.emp_visibility').hide();
            }
        }

        indicatorToSubmit = newIndicatorToSubmit;
    }

    //add group/employee selected to list to submit
    function addToList(id, name)
    {
        var objToUpdate;
        var listToUpdate;
        switch(indicatorToSubmit.format) {
            case 'orgchart_group':
                objToUpdate = groupObj;
                listToUpdate = $('#selectedGroupList');
                break;
            case 'orgchart_employee':
                objToUpdate = employeeObj;
                listToUpdate = $('#selectedEmployeeList');
                break;
        }

        if(!(id in objToUpdate))
        {
            objToUpdate[id] = name;
            
            var newListItem = $(document.createElement('li'))
                .attr('value',id)
                .appendTo(listToUpdate);
                var removeButton = $(document.createElement('span'))
                    .attr('class','remove_id')
                    .on('click',function(){
                        removeFromList(id);
                    })
                    .html("X")
                    .appendTo(newListItem);
                var itemText = $(document.createElement('span'))
                    .html(name)
                    .appendTo(newListItem);
        }
    }

    //remove group/employee selected to list to submit
    function removeFromList(id)
    {
        var objToUpdate;
        var listToUpdate;
        switch(indicatorToSubmit.format) {
            case 'orgchart_group':
                objToUpdate = groupObj;
                listToUpdate = $('#selectedGroupList');
                break;
            case 'orgchart_employee':
                objToUpdate = employeeObj;
                listToUpdate = $('#selectedEmployeeList');
                break;
        }

        listToUpdate.find('li[value="'+id+'"]').remove();
        delete objToUpdate[id];
    }

    //build json to submit
    function buildParallelProcessingDataJSON()
    {
        var dataToSubmit = Object();
        var result = -1;

        if(indicatorToSubmit !== null)
        {
            switch(indicatorToSubmit.format) {
                case 'orgchart_group':
                    dataToSubmit = groupObj;
                    break;
                case 'orgchart_employee':
                    dataToSubmit = employeeObj;
                    break;
            }
            if(!$.isEmptyObject(dataToSubmit))
            {
                result = JSON.stringify({type: indicatorToSubmit.format, indicatorID: indicatorToSubmit.indicatorID, idsToProcess: Object.keys(dataToSubmit)});
            }
        }

        return result;
    }

    

    $('.buttonNorm').on( "click", function() {
        buildParallelProcessingDataJSON()
    });
    selectForParallelProcessing.buildParallelProcessingDataJSON = buildParallelProcessingDataJSON;
    fillIndicatorDropdown();
    $('#selectDiv').on('click', '.employeeSelector > .employeeSelectorAddToList > button', function(){
        empSel.select(this.id.substring(3));
    });
    $('#selectDiv').on('click', '.groupSelector > .groupSelectorAddToList > button', function(){
        grpSel.select(this.id.substring(3));
    });
}

