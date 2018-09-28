function selectForParallelProcessing(recordID, orgChartPath, CSRFToken, categoryID)
{
    var indicatorObject = new Object();//indicators to select from
    var indicatorToSubmit = null;//the selected indicator
    var employeeObj = new Object();//selected employees
    var groupObj = new Object();//selected groups
    var jsonToSubmit;
    var loadingBarSize = 0;
    var currentRequestsSubmitted = 0;

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
                alert('There must be an indicator of type "orgchart group" or "orgchart employee" to begin Parallel Processing.');
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
                    var grpSel = new groupSelector('grpSelector');
                    grpSel.rootPath = orgChartPath+'/';
                    grpSel.apiPath = orgChartPath+'/api/';
                    grpSel.setSelectHandler(function(){
                        var name = $('#'+grpSel.prefixID+'grp'+grpSel.selection+' > .groupSelectorTitle').html();
                        addToList(grpSel.selection, name);
                    });
                    grpSel.initialize();
                    $('.emp_visibility').hide();
                    $('.grp_visibility').show();
                    break;
                case 'orgchart_employee':
                    var empSel = new nationalEmployeeSelector('empSelector');
                    empSel.rootPath = orgChartPath+'/';
                    empSel.apiPath = orgChartPath+'/api/';
                    empSel.setSelectHandler(function(){
                        var name = $('#'+empSel.prefixID+'emp'+empSel.selection+' > .employeeSelectorName').html();
                        addToList(empSel.selection, name);
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
    function buildParallelProcessingData()
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
                result = {type: indicatorToSubmit.format, indicatorID: indicatorToSubmit.indicatorID, idsToProcess: Object.keys(dataToSubmit)};
            }
        }

        return result;
    }

    function beginProcessing()
    {
        // 1. Read api/form/[record ID]/data to local
        $.ajax({
            type: 'POST',
            url: './api/form/'+recordID+'/data',
            data: {CSRFToken: CSRFToken},
            success: function(res) {
                loopThroughSubmissions(res);
            },
            cache: false
        });

        // 2. Loop through list of users/groups (progress bar)

        //     2a. Create new form for each entity. Append unique ID to the user supplied title: POST: api/form/new -> returns recordID

        //     2b. Add data for each form for each recordID: POST: api/form/[recordID]

        //     2c. Submit action: POST: api/[recordID]/submit

        // 3. Delete original form -- subtask to move ajaxIndex.php (~line 212) into api/FormController.php

        // 4. Generate Report Builder link (for report columns need at least title, status)

        // 5. Redirect user to new report 
    }

    function loopThroughSubmissions(formData)
    {
        var submissionObj = buildParallelProcessingData();
        rand = ((Date.now() + Math.floor(Math.random() * 12345))+"");
        rand = rand.substring(rand.length-6, rand.length);

        //TODO_PP: assess all these, except csrf
        var ajaxData = new Object();
        ajaxData['CSRFToken'] = CSRFToken;
        ajaxData['service'] = 'service';
        ajaxData['title'] = 'title'+'-'+rand;
        ajaxData['priority'] = 0;
        ajaxData['num'+categoryID] = 1;

        $.each( submissionObj.idsToProcess, function( i, val ) {
            $.ajax({
                type: 'POST',
                url: './api/form/new',
                data: ajaxData,
                success: function(res) {
                    fillAndSubmitForm(formData, res, submissionObj.indicatorID, val);
                },
                cache: false
            });
        });
    }

    function fillAndSubmitForm(formData, newRecordID, indicatorIDToChange, newData)
    {
        var ajaxData = new Object();
        ajaxData['CSRFToken'] = CSRFToken;
        ajaxData['series'] = 1;
        $.each( formData, function( i, val ) {
            $.each( val, function( i, thisRow ) {
                if('series' in thisRow)
                {
                    ajaxData['series'] = thisRow['series']; 
                }
                if(('indicatorID' in thisRow) && ('value' in thisRow))
                {
                    ajaxData[thisRow['indicatorID']] = thisRow['value']; 
                }
            });
        });

        ajaxData[indicatorIDToChange] = newData;

        $.ajax({
            type: 'POST',
            url: './api/form/'+newRecordID,
            data: ajaxData,
            success: function(res) {
                $.ajax({
                    type: 'POST',
                    url: './api/'+newRecordID+'/submit',
                    data: ajaxData,
                    success: function(res) {
                        updateLoadingBar();
                    },
                    cache: false
                });
            },
            cache: false
        });
    }

    function updateLoadingBar()
    {
        currentRequestsSubmitted++;
        if(currentRequestsSubmitted < loadingBarSize)
        {
            //update the bar
        }
        else
        {
            //redirect to chart
        }
    }

    //TODO_PP:
    //change all this
    $('.buttonNorm').on( "click", function() {
        buildParallelProcessingDataJSON()
    });
    selectForParallelProcessing.buildParallelProcessingDataJSON = buildParallelProcessingDataJSON;
    fillIndicatorDropdown();
}

