function parallelProcessing(recordID, orgChartPath, CSRFToken)
{
    var indicatorObject = new Object();//indicators to select from
    var indicatorToSubmit = null;//the selected indicator
    var employeeObj = new Object();//selected employees
    var groupObj = new Object();//selected groups
    var loadingBarSize = 0;
    var currentRequestsSubmitted = 0;
    var newTitleRand = '';
    var empSel;
    var grpSel;

    //initialize progress bar, dropdown, and onClick
    function initializeParallelProcessing()
    {
        $('#pp_progressBar').progressbar();
        $('#pp_progressBar').progressbar('option', 'value', 0);
        $('#pp_progressLabel').text('0%');
        $('#submitControl .buttonNorm').on( "click", function() {
            if(hasSelections())
            {
                $('#pp_progressSidebar').show();
                $('#pp_banner').hide();
                $('#pp_selector').hide();
                $('#submitControl .buttonNorm').hide();
                beginProcessing();
            }
            else
            {
                alert('You must select at least one group or employee to begin Parallel Processing.');
            }
        });
        fillIndicatorDropdown();
        $('#selectDiv').on('click', '.employeeSelector > .employeeSelectorAddToList > button', function(){
            empSel.select(this.id.substring(3));
        });
        $('#selectDiv').on('click', '.groupSelector > .groupSelectorAddToList > button', function(){
            grpSel.select(this.id.substring(3));
        });
      
    }

    //fill the dropdown with all employee or group indicators in this form
    function fillIndicatorDropdown() 
    {
        $.ajax({
            type: 'GET',
            url: 'api/form/'+recordID+'/workflow/indicator/assigned',
            success: function(obj) {
                //indicatorObject is global, obj is an array or null
                indicatorObject = obj;
                if (indicatorObject !== null) {
                    for (let i = 0; i < indicatorObject.length; i++) {
                        $(document.createElement('option'))
                            .attr('value', indicatorObject[i].indicatorID)
                            .html(indicatorObject[i].name)
                            .appendTo($("select#indicator_selector"));
                    }
                }
                else {
                    let failResponse = 'Error: The form/workflow must contain a field of type "orgchart group" or "orgchart employee" to begin Parallel Processing.';
                    let responseHTML = '<span style="font-size: 120%">' + failResponse + '</span>';
                    $('#submitControl').css('display', 'none');
                    $('#selectDiv').html(responseHTML);
                }
            },
            cache: false
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
                            for(let i in this.selectionData) {
                                $('#'+this.prefixID+'grp'+i).off('click');
                                $('#'+this.prefixID+'grp'+i).append('<td class="groupSelectorAddToList"><button id="btn'+i+'" type="button">Select</button></td>');
                            }
                        }
                    });
                    grpSel.initialize();
                    $('#' + grpSel.prefixID + 'input').attr('placeholder', 'Search and select group...');
                    $('.emp_visibility').hide();
                    $('.grp_visibility').show();
                    break;
                case 'orgchart_employee':
                    empSel = new nationalEmployeeSelector('empSelector');
                    empSel.rootPath = orgChartPath+'/';
                    empSel.apiPath = orgChartPath+'/api/';
                    empSel.setSelectHandler(function(){
                        var selectedUserName = empSel.selectionData[empSel.selection].userName;
                        $.ajax({
                            type: 'POST',
                            url: orgChartPath + '/api/employee/import/_' + selectedUserName,
                            data: {CSRFToken: CSRFToken},
                            success: function(localEmpUID) {
                                if(!isNaN(localEmpUID)) {
                                    $('#'+this.prefixID+'emp'+empSel.selection).removeClass('employeeSelected');
                                    $('#'+this.prefixID+'emp'+empSel.selection).addClass('employeeSelector');
                                    var name = empSel.selectionData[empSel.selection].lastName + ', ' + empSel.selectionData[empSel.selection].firstName;
                                    addToList(localEmpUID, name);
                                }
                                else {
                                    alert(localEmpUID);
                                }
                            }
                        });
                    });
                    empSel.setResultHandler(function(){
                        if(this.numResults > 0) {
                            $('table.employeeSelectorTable tr:first').append('<th>&nbsp;</th>');
                            for(let i in this.selectionData) {
                                $('#'+this.prefixID+'emp'+i).off('click');
                                $('#'+this.prefixID+'emp'+i).append('<td class="employeeSelectorAddToList"><button id="btn'+i+'" type="button">Select</button></td>');
                            }
                        }
                    });
                    empSel.initialize();
                    $('#' + empSel.prefixID + 'input').attr('placeholder', 'Search and select employee...');
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
                    .attr('class','remove_id buttonNorm')
                    .on('click',function(){
                        removeFromList(id);
                    })
                    .html("Remove")
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

    //check if anything is currently selected
    function hasSelections()
    {
        var objToCheck = new Object();
        var format = '';
        if(indicatorToSubmit !== null)
        {
            format = indicatorToSubmit.format;
        }

        switch(format) {
            case 'orgchart_group':
                objToCheck = groupObj;
                break;
            case 'orgchart_employee':
                objToCheck = employeeObj;
                break;
        }

        return Object.keys(objToCheck).length > 0;
    }

    //build object to submit
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

    // Read api/form/[record ID]/data and api/form/[record ID]/recordinfo to local 
    // and move to next loopThroughSubmissions
    function beginProcessing()
    {
        var priority = 0;
        var serviceID = 0;
        var title = '';
        var categories = new Object();
    
        $.ajax({
            type: 'GET',
            url: 'api/form/'+recordID+'/recordinfo',
            success: function(res) {
                if ('priority' in res)
                {
                    priority = res['priority'];
                }
                if ('serviceID' in res)
                {
                    serviceID = res['serviceID'];
                }
                if ('title' in res)
                {
                    title = res['title'];
                }
                if ('categories' in res)
                {
                    categories = res['categories'];
                }
            },
            cache: false
        }).done(function() {
            $.ajax({
                type: 'GET',
                url: 'api/form/'+recordID+'/data',
                success: function(res) {
                   loopThroughSubmissions(res, priority, serviceID, title, categories);
                },
                cache: false
            });
        });
    }

    // Loop through list of users/groups to submit
    // Create new form for each entity. Append unique ID to the user supplied title
    // send each to fillAndSubmitForm
    function loopThroughSubmissions(formData, priority, serviceID, title, categories)
    {
        var submissionObj = buildParallelProcessingData();
        loadingBarSize = submissionObj.idsToProcess.length;
        rand = ((Date.now() + Math.floor(Math.random() * 12345))+"");
        rand = rand.substring(rand.length-6, rand.length);
        newTitleRand = 'PR:'+rand;

        var ajaxData = new Object();
        ajaxData['CSRFToken'] = CSRFToken;
        ajaxData['service'] = serviceID;
        ajaxData['title'] = title+' ('+newTitleRand+')';
        ajaxData['priority'] = priority;
        $.each( categories, function( i, val ) {
            if ('num'+val in ajaxData)
            {
                ajaxData['num'+val]++;
            }
            else
            {
                ajaxData['num'+val] = 1;
            }
        });

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

    /*
    * Function to copy file attachments from parallel processing record to new records
    * Alerts user if a file failed to be copy, otherwise, implicit success
    */
    function copyFileToNewRecord(indicatorID, fileName, newRecordID, series) {
        $.ajax({
            type: 'POST',
            url: './api/form/files/copy',
            data: {
                CSRFToken: CSRFToken, 
                indicatorID: indicatorID,
                fileName: fileName,
                recordID: recordID,
                newRecordID: newRecordID,
                series: series
            },
            success: function(res) {
                if (res !== 1) {
                    if (res.type === 2) {
                        alert('Error: ' + fileName + " failed to copy.\nReason: File does not exist or file name format incorrect");
                    } else {
                        alert('Error: Unknown error.\nReason: If you see this error, try again. If the error persists, please contact support.');
                    }
                } 
            },
            cache: false
        });
    }

    // Add data from form for recordID given
    // then submit, updating load bar
    function fillAndSubmitForm(formData, newRecordID, indicatorIDToChange, newData)
    {
        var ajaxData = new Object();
        ajaxData['CSRFToken'] = CSRFToken;
        ajaxData['series'] = 1;
        $.each( formData, function( i, val ) {
            $.each( val, function( j, thisRow ) {
                if('series' in thisRow)
                {
                    ajaxData['series'] = thisRow['series']; 
                }
                if(('indicatorID' in thisRow) && ('value' in thisRow))
                {
                    if(thisRow['format'] === 'fileupload' || thisRow['format'] === 'image') {
                        ajaxData[thisRow['indicatorID']] = '';
                        if(thisRow['value']){
                            $.each(thisRow['value'], function(k, file) {
                                ajaxData[thisRow['indicatorID']] = ajaxData[thisRow['indicatorID']] + file + '\n';
                                copyFileToNewRecord(thisRow['indicatorID'], file, newRecordID, ajaxData['series']);
                            });
                        }
                    }
                    else {
                        ajaxData[thisRow['indicatorID']] = thisRow['value']; 
                    }
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
                    url: './api/form/'+newRecordID+'/submit',
                    data: {CSRFToken: CSRFToken},
                    success: function(res) {
                        updateLoadingBar();
                    },
                    cache: false
                });
            },
            cache: false
        });
    }


    // update the load bar
    // if all done: Delete original form, Generate Report Builder link, and Redirect user to new report 
    function updateLoadingBar()
    {
        currentRequestsSubmitted++;
        var percentage = (currentRequestsSubmitted / loadingBarSize) * 100;
        $('#pp_progressBar').progressbar('option', 'value', percentage);
        $('#pp_progressLabel').text(percentage + '%');

        if(currentRequestsSubmitted == loadingBarSize)
        {
            //delete original one
            $.ajax({
                type: 'POST',
                url: './api/form/'+recordID+'/cancel',
                data: {CSRFToken: CSRFToken},
                success: function(res) {
                    //redirect to chart
                    urlTitle = "Requests have been assigned to these people";
                    urlIndicatorsJSON = '[{"indicatorID":"title","name":"","sort":0},{"indicatorID":"status","name":"","sort":0},{"indicatorID":"'+ indicatorToSubmit.indicatorID +'","name":"'+ indicatorToSubmit.name +'","sort":0}]';
                    urlQueryJSON = '{"terms":[{"id":"title","operator":"LIKE","match":"*'+newTitleRand+'*"},{"id":"deleted","operator":"=","match":0}],"joins":["service","status","initiatorName"],"sort":{},"getData":['+ indicatorToSubmit.indicatorID +']}';

                    urlTitle = encodeURIComponent(btoa(urlTitle));
                    urlQuery = encodeURIComponent(LZString.compressToBase64(urlQueryJSON));
                    urlIndicators = encodeURIComponent(LZString.compressToBase64(urlIndicatorsJSON));

                    window.location = './?a=reports&v=3&title='+urlTitle+'&query='+urlQuery+'&indicators='+urlIndicators;
                },
                cache: false
            });
            

            
        }
    }

    initializeParallelProcessing();
}

