<div id="step_1" style="<!--{if $query != '' && $indicators != ''}-->display: none; <!--{/if}-->width: 70%; background-color: white; border: 1px solid black; margin: auto; padding: 0px">
    <div style="background-color: #003a6b; color: white; padding: 4px; font-size: 22px; font-weight: bold">
        Step 1: Develop search filter
    </div>
    <div style="padding: 8px">
        <div id="searchContainer"></div>
    </div>
</div>

<div id="step_2" style="display: none; width: 85%; background-color: white; border: 1px solid black; margin: auto; padding: 0px">
    <div style="background-color: #0059a4; color: white; padding: 4px; font-size: 22px; font-weight: bold">
        Step 2: Select Data Columns
    </div>
    <div style="padding: 8px">
        <div id="indicatorList" style="padding: 8px; height: 320px; overflow: scroll; overflow-x: hidden">Loading...</div>
        <br />
        <div id="generateReport" class="buttonNorm" style="font-size: 120%; width: 70%; margin: auto; text-align: center">Generate Report <img src="../libs/dynicons/?img=x-office-spreadsheet-template.svg&w=32" alt="generate report" /></div>
    </div>
</div>

<div id="saveLinkContainer" style="display: none">
    <div id="reportTitleDisplay" style="font-size: 200%"></div>
    <input id="reportTitle" type="text" style="font-size: 200%; width: 50%" value="Untitled Report"></input>
</div>
<div id="results" style="display: none">Loading...</div>

<!--{include file="site_elements/generic_xhrDialog.tpl"}-->
<script>
var CSRFToken = '<!--{$CSRFToken}-->';

function prepareEmail() {
	mailtoHref = 'mailto:?subject=' + $('#reportTitle').val() + '&body=Report%20Link:%20'+ encodeURIComponent(url +'&title='+ btoa($('#reportTitle').val())) +'%0A%0A';
    $('body').append($('<iframe id="ie9workaround" src="' + mailtoHref + '"/>'));
    $('#ie9workaround').remove();
}

var tDepHeader = [];
function addHeader(column) {
	switch(column) {
	    case 'title':
	    	headers.push({name: 'Title', indicatorID: 'title', callback: function(data, blob) {
                            $('#'+data.cellContainerID).html(blob[data.recordID].title);
                            $('#'+data.cellContainerID).on('click', function() {
                                window.open('index.php?a=printview&recordID='+data.recordID, 'LEAF', 'width=800,resizable=yes,scrollbars=yes,menubar=yes');
                            });
                         }});
		    break;
	    case 'service':
            headers.push({name: 'Service', indicatorID: 'service', editable: false, callback: function(data, blob) {
                             $('#'+data.cellContainerID).html(blob[data.recordID].service);
                         }});
            break;
	    case 'type':
	    	leafSearch.getLeafFormQuery().join('categoryName');
            headers.push({name: 'Type', indicatorID: 'type', editable: false, callback: function(data, blob) {
                             var types = '';
                             for(var i in blob[data.recordID].categoryNames) {
                                 types += blob[data.recordID].categoryNames[i] + ' | ';
                             }
                             types = types.substr(0, types.length - 3);
                             $('#'+data.cellContainerID).html(types);
                         }});
            break;
	    case 'status':
	    	leafSearch.getLeafFormQuery().join('status');
            headers.push({name: 'Current Status', indicatorID: 'status', editable: false, callback: function(data, blob) {
                             status = blob[data.recordID].stepTitle == null ? blob[data.recordID].lastStatus : 'Pending ' + blob[data.recordID].stepTitle;
                             status = status == 'null' ? 'Not Submitted' : status;
                             if(blob[data.recordID].deleted > 0) {
                            	 status += ', Cancelled';
                             }
                             $('#'+data.cellContainerID).html(status);
                         }});
            break;
        case 'initiator':
            headers.push({name: 'Initiator', indicatorID: 'initiator', editable: false, callback: function(data, blob) {
            	$('#'+data.cellContainerID).html('<span class="initiator_'+ blob[data.recordID].userID +'">' + blob[data.recordID].userID + '</span>');
            	$('.initiator_'+ blob[data.recordID].userID).off('mouseover.custom');
            	$('.initiator_'+ blob[data.recordID].userID).on('mouseover.custom', function() {
            		$('.initiator_'+ blob[data.recordID].userID).off('mouseover.custom');
                    $.ajax({
                        type: 'GET',
                        url: '<!--{$orgchartPath}-->/api/?a=employee/search&q=' + blob[data.recordID].userID,
                        success: function(res) {
                        	var buffer = '';
                        	for(var i in res) {
                        		buffer += res[i].lastName + ', ' + res[i].firstName;
                        	}
                            $('.initiator_'+ blob[data.recordID].userID).html(buffer);
                        }
                    });            		
            	});
            }});
            break;
        case 'action_history':
            leafSearch.getLeafFormQuery().join('action_history');
            var months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'June', 'July', 'Aug', 'Sept', 'Oct', 'Nov', 'Dec'];
            headers.push({name: 'Comment History', indicatorID: 'action_history', editable: false, callback: function(data, blob) {
                             var buffer = '<table style="min-width: 300px">';
                             var now = new Date();

                             for(var i in blob[data.recordID].action_history) {
                            	 var date = new Date(blob[data.recordID].action_history[i]['time'] * 1000);
                            	 var year = now.getFullYear() != date.getFullYear() ? ' ' + date.getFullYear() : '';
                                 var formattedDate = months[date.getMonth()] + ' ' + parseFloat(date.getDate()) + year;
                                 if(blob[data.recordID].action_history[i]['comment'] != '') {
                                     buffer += '<tr><td style="border-right: 1px solid black; padding-right: 4px">' + formattedDate + '</td><td>' + blob[data.recordID].action_history[i]['comment'] + '</td></tr>';
                                 }
                             }
                             buffer += '</table>';
                             $('#'+data.cellContainerID).html(buffer);
                         }});
            break;
        case 'approval_history':
            leafSearch.getLeafFormQuery().join('action_history');
            var months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'June', 'July', 'Aug', 'Sept', 'Oct', 'Nov', 'Dec'];
            headers.push({name: 'Approval History', indicatorID: 'approval_history', editable: false, callback: function(data, blob) {
                             var buffer = '<table style="min-width: 300px">';
                             var now = new Date();

                             for(var i in blob[data.recordID].action_history) {
                                 var date = new Date(blob[data.recordID].action_history[i]['time'] * 1000);
                                 var year = now.getFullYear() != date.getFullYear() ? ' ' + date.getFullYear() : '';
                                 var formattedDate = months[date.getMonth()] + ' ' + parseFloat(date.getDate()) + year;
                                 buffer += '<tr><td style="border-right: 1px solid black; padding-right: 4px">' + formattedDate + '</td><td>' + blob[data.recordID].action_history[i]['description'] + ': ' + blob[data.recordID].action_history[i]['actionTextPasttense'] + '</td></tr>';
                             }
                             buffer += '</table>';
                             $('#'+data.cellContainerID).html(buffer);
                         }});
            break;
	    default:
	    	if(column.substr(0, 6) == 'depID_') {
	    		depID = column.substr(6);
	    		tDepHeader[depID] = 0;
	    		leafSearch.getLeafFormQuery().join('recordsDependencies');

	            headers.push({name: 'Approval Date', indicatorID: column, editable: false, callback: function(depID) {
	            	return function(data, blob) {
	                    if(blob[data.recordID].recordsDependencies != undefined
	                    	&& blob[data.recordID].recordsDependencies[depID] != undefined) {
	                        var date = new Date(blob[data.recordID].recordsDependencies[depID].time * 1000);
	                        $('#'+data.cellContainerID).html(date.toLocaleDateString().replace(/[^ -~]/g,'')); // IE11 encoding workaround: need regex replacement
	                        
	                        if(tDepHeader[depID] == 0) {
	                        	headerID = data.cellContainerID.substr(0, data.cellContainerID.indexOf('_') + 1) + 'header_' + column;
	                            $('#' + headerID).html(blob[data.recordID].recordsDependencies[depID].description);
	                            $('#Vheader_' + column).html(blob[data.recordID].recordsDependencies[depID].description);
	                        	tDepHeader[depID] = 1;
	                        }
	                    }
	            	}
                }(depID)});
	    	}
	    	break;
	}
}

var resIndicatorList = {};
var searchPrereqsLoaded = false;
function loadSearchPrereqs() {
	if(searchPrereqsLoaded == true) {
		return;
	}
	searchPrereqsLoaded = true;
    $.ajax({
        type: 'GET',
        url: './api/?a=form/indicator/list',
        dataType: 'json',
        success: function(res) {
            var buffer = '';

            // special columns
            buffer += '<div>';
            buffer += '<div class="indicatorOption"><input type="checkbox" class="icheck" id="indicators_title" name="indicators[title]" value="title" />';
            buffer += '<label class="checkable" style="width: 100px" for="indicators_title"> Title of Request</label></div>';
            buffer += '<div class="indicatorOption"><input type="checkbox" class="icheck" id="indicators_service" name="indicators[service]" value="service" />';
            buffer += '<label class="checkable" style="width: 100px" for="indicators_service"> Service</label></div>';
            buffer += '<div class="indicatorOption"><input type="checkbox" class="icheck" id="indicators_type" name="indicators[type]" value="type" />';
            buffer += '<label class="checkable" style="width: 100px" for="indicators_type"> Type of Request</label></div>';
            buffer += '<div class="indicatorOption"><input type="checkbox" class="icheck" id="indicators_status" name="indicators[status]" value="status" />';
            buffer += '<label class="checkable" style="width: 100px" for="indicators_status"> Current Status</label></div>';
            buffer += '<div class="indicatorOption"><input type="checkbox" class="icheck" id="indicators_initiator" name="indicators[initiator]" value="initiator" />';
            buffer += '<label class="checkable" style="width: 100px" for="indicators_initiator"> Initiator</label></div>';
            buffer += '<div class="indicatorOption"><input type="checkbox" class="icheck" id="indicators_action_history" name="indicators[action_history]" value="action_history" />';
            buffer += '<label class="checkable" style="width: 100px" for="indicators_action_history"> Comment History</label></div>';
            buffer += '<div class="indicatorOption"><input type="checkbox" class="icheck" id="indicators_approval_history" name="indicators[approval_history]" value="approval_history" />';
            buffer += '<label class="checkable" style="width: 100px" for="indicators_approval_history"> Approval History</label></div>';
            buffer += '</div>';
            var groupList = {};
            var tmp = document.createElement('div');
            var temp;
            for(var i in res) {
                temp = res[i].description != '' && res[i].description != null ? res[i].description : res[i].name;
                tmp.innerHTML = temp;
                temp = tmp.textContent || tmp.innerText || '';
                temp = temp.replace(/[^\040-\176]/g, '');

                resIndicatorList[res[i].indicatorID] = temp;

                if(groupList[res[i].categoryName] == undefined) {
                    groupList[res[i].categoryName] = [];
                }
                groupList[res[i].categoryName].push(res[i].indicatorID);
            }

            for(var i in groupList) {

                buffer += '<div class="form buttonNorm" style="width: 200px; float: left; min-height: 30px; margin: 4px"><div class="formLabel">' + i + '</div>';
                for(var j in groupList[i]) {
                    buffer += '<div class="indicatorOption" style="display: none"><input type="checkbox" class="icheck" id="indicators_'+ groupList[i][j] +'" name="indicators['+ groupList[i][j] +']" value="'+ groupList[i][j] +'" />';
                    buffer += '<label class="checkable" style="width: 100px" for="indicators_'+ groupList[i][j] +'" title="indicatorID: '+ groupList[i][j] +'" alt="indicatorID: '+ groupList[i][j] +'"> ' + resIndicatorList[groupList[i][j]] +'</label></div>';
                }
                buffer += '</div>';
            }

            buffer += '<br />';
            
            $('#indicatorList').html(buffer);

            $('#indicatorList').css('height', $(window).height() - 240);
            $('.form').on('click', function() {
            	$(this).removeClass('buttonNorm');
            	$(this).css({width: '100%'});
            	$(this).children('div').css('display', 'block');
            	$(this).children('.formLabel').css({'border-bottom': '1px solid #e0e0e0',
            		'font-weight': 'bold'});
            });
            $.ajax({
                type: 'GET',
                url: './api/?a=workflow/dependencies',
                dataType: 'json',
                success: function(res) {
                    buffer = '';
                    buffer += '<div class="form" style="width: 100%; float: left; min-height: 30px; margin: 4px"><div class="formLabel" style="border-bottom: 1px solid #e0e0e0; font-weight: bold">Approval Dates</div>';
                    for(var i in res) {
                        buffer += '<div class="indicatorOption"><input type="checkbox" class="icheck" id="indicators_depID_'+ res[i].dependencyID +'" name="indicators[depID_'+ res[i].dependencyID +']" value="depID_'+ res[i].dependencyID +'" />';
                        buffer += '<label class="checkable" style="width: 100px" for="indicators_depID_'+ res[i].dependencyID +'"> ' + res[i].description +'</label></div>';
                    }
                    buffer += '</div>';

                    $('#indicatorList').append(buffer);

                    // set user selections
                    if(t_inIndicators != undefined) {
                        for(var i in t_inIndicators) {
                            $('#indicators_' + t_inIndicators[i].indicatorID).prop('checked', true);
                        }
                    }
                    else {
                        // pre-select defaults
                        $('#indicators_title').prop('checked', true);
                        $('#indicators_service').prop('checked', true);
                    }

                    $('.icheck').icheck({checkboxClass: 'icheckbox_square-blue', radioClass: 'iradio_square-blue'});
                }
            });
        },
        cache: false
    });
}

function editLabels_down(id) {
    var row = $('#sortID_' + id); 
    row.next().after(row);
}

function editLabels_up(id) {
    var row = $('#sortID_' + id); 
    row.prev().before(row);
}

function editLabels() {
	dialog.setTitle('Edit Labels');
	
	var buffer = '<table id="labelSorter">';

	if (Object.keys(indicatorSort).length !== 0) {
		resSelectList.sort(function(a, b) {
			var sortA = indicatorSort[a] == undefined ? 0 : indicatorSort[a];
			var sortB = indicatorSort[b] == undefined ? 0 : indicatorSort[b];

		    if(sortA < sortB) {
		        return -1
		    }
		    if(sortB < sortA) {
		        return 1;
		    }
		    return 0;
		});
	}

	for(var i in resSelectList) {
		if(resIndicatorList[resSelectList[i]] != undefined) {
			buffer += '<tr id="sortID_'+ resSelectList[i] +'"><td><input type="text" style="min-width: 400px" id="id_'+ resSelectList[i] +'" value="'+ resIndicatorList[resSelectList[i]] +'"></input></td>';
			buffer += '<td><button class="buttonNorm" onclick="editLabels_down('+ resSelectList[i] +');"><img src="../libs/dynicons/?img=go-down_red.svg&w=16" /></button> ';
			buffer += '<button class="buttonNorm" onclick="editLabels_up('+ resSelectList[i] +');"><img src="../libs/dynicons/?img=go-up.svg&w=16" /></button></td></tr>';
		}
	}
	buffer += '</table>';
    dialog.setContent(buffer);
    dialog.show();

    dialog.setSaveHandler(function() {
    	$('#labelSorter tr').each(function(i) {
    		var curID = this.id.substr(7);
    		indicatorSort[curID] = i + 1;
    	});
        var tmp = document.createElement('div');
        var temp;
        for(var i in resSelectList) {
            if(resIndicatorList[resSelectList[i]] != undefined) {
                temp = $('#id_' + resSelectList[i]).val();
                tmp.innerHTML = temp;
                temp = tmp.textContent || tmp.innerText || '';
                temp = temp.replace(/[^\040-\176]/g, '');
            	resIndicatorList[resSelectList[i]] = temp;
            }
        }
        $('#generateReport').click();
        dialog.hide();
    });
}

function isSearchingDeleted(searchObj) {
    // check if the user explicitly wants to find deleted requests
    var t = searchObj.getLeafFormQuery().getQuery();
    var searchDeleted = false;
    for(var i in t.terms) {
        if(t.terms[i].id == 'stepID'
            && t.terms[i].match == 'deleted'
            && t.terms[i].operator == '=') {

            return true;
        }
    }
    return false;
}

function sortHeaders(a, b) {
    a.sort = a.sort == undefined ? 0 : a.sort;
    b.sort = b.sort == undefined ? 0 : b.sort;
    if(a.sort < b.sort) {
        return -1
    }
    if(b.sort < a.sort) {
        return 1;
    }
    return 0;
}

var url, urlQuery, urlIndicators;
var leafSearch;
var headers = [];
var t_inIndicators;
var isNewQuery = false;
var dialog;
var indicatorSort = {}; // object = indicatorID : sortID
$(function() {
	dialog = new dialogController('xhrDialog', 'xhr', 'loadIndicator', 'button_save', 'button_cancelchange');
    leafSearch = new LeafFormSearch('searchContainer');
    leafSearch.setOrgchartPath('<!--{$orgchartPath}-->');
    leafSearch.renderUI();

    $('#' + leafSearch.getPrefixID() + 'advancedSearchButton').click();
    $('#' + leafSearch.getPrefixID() + 'advancedOptions').css('border', '0');
    $('#' + leafSearch.getPrefixID() + 'advancedOptionsClose').css('visibility', 'hidden');
    $('#' + leafSearch.getPrefixID() + 'advancedOptions>legend').css('display', 'none');
    $('#' + leafSearch.getPrefixID() + 'advancedSearchApply').html('Next Step <img src="../libs/dynicons/?img=go-next.svg&w=32" alt="next step" />');
    
    $('#' + leafSearch.getPrefixID() + 'advancedSearchApply').off();
    
    // Step 1
    $('#' + leafSearch.getPrefixID() + 'advancedSearchApply').on('click', function() {
    	$('#step_2').fadeIn(400);
    	$('#step_1').slideUp(400);
    });

    <!--{if $query == '' || $indicators == ''}-->
    loadSearchPrereqs();
    isNewQuery = true;
    <!--{/if}-->

    // Step 2
    var selectedIndicators = [];
    var grid = new LeafFormGrid('results');
    grid.enableToolbar();
    var extendedToolbar = false;
    $('#generateReport').off();
    $('#generateReport').on('click', function() {
        $('#results').fadeIn(700);
        $('#saveLinkContainer').fadeIn(700);
        $('#step_2').slideUp(700);

        if(isNewQuery) {
            leafSearch.generateQuery();
            
            if(!isSearchingDeleted(leafSearch)) {
            	leafSearch.getLeafFormQuery().addTerm('deleted', '=', 0);
            }
            leafSearch.getLeafFormQuery().join('service');
            headers = [];
        }
        else if(!isSearchingDeleted(leafSearch)) {
            leafSearch.getLeafFormQuery().addTerm('deleted', '=', 0);
        }

    	selectedIndicators = [];
    	resSelectList = [];
    	$('.icheck:checked').each(function() {
    		resSelectList.push(this.value);
    	});
    	resSelectList.sort(function(a, b) {
            var sortA = indicatorSort[a] == undefined ? 0 : indicatorSort[a];
            var sortB = indicatorSort[b] == undefined ? 0 : indicatorSort[b];

            if(sortA < sortB) {
                return -1
            }
            if(sortB < sortA) {
                return 1;
            }
            return 0;
        });
    	for(var i in resSelectList) {
            var temp = {};
            temp.indicatorID = resSelectList[i];
            temp.name = resIndicatorList[temp.indicatorID] != undefined ? resIndicatorList[temp.indicatorID] : '';
            temp.sort = indicatorSort[temp.indicatorID] == undefined ? 0 : indicatorSort[temp.indicatorID];
            var tmp = document.createElement('div');
            tmp.innerHTML = temp.name;
            temp.name = tmp.textContent || tmp.innerText || '';
            temp.name = temp.name.replace(/[^\040-\176]/g, '');
            if($.isNumeric(resSelectList[i])) {
                headers.push(temp);
                leafSearch.getLeafFormQuery().getData(temp.indicatorID);
            }
            else {
                addHeader(temp.indicatorID);
            }
            selectedIndicators.push(temp);
    	}

    	headers.sort(sortHeaders);
    	selectedIndicators.sort(sortHeaders);

    	
    	grid.setHeaders(headers);

    	leafSearch.getLeafFormQuery().onSuccess(function(res) {
            grid.setDataBlob(res);

            // this replaces grid.loadData()
            var tGridData = [];
            for(var i in res) {
                tGridData.push(res[i]);
            }
            
            if(<!--{$version}--> >= 3) {
                grid.setData(tGridData);
                grid.sort('recordID', 'desc');
                grid.renderBody();
            }
            else {
                var recordIDs = '';
                for (var i in res) {
                    recordIDs += res[i].recordID + ',';
                }
            	grid.loadData(recordIDs);
            }
    	});

    	// get data
    	leafSearch.getLeafFormQuery().execute();
    	
    	// create save link once
    	if(!extendedToolbar) {
            $('#' + grid.getPrefixID() + 'gridToolbar').prepend('<span class="buttonNorm" onclick="prepareEmail()"><img src="../libs/dynicons/?img=internet-mail.svg&w=32" alt="email report" /> Email Report</span> ');
            $('#' + grid.getPrefixID() + 'gridToolbar').prepend('<span id="editLabels" class="buttonNorm" onclick="editLabels()"><img src="../libs/dynicons/?img=accessories-text-editor.svg&w=32" alt="email report" /> Edit Labels</span> ');

            $('#' + grid.getPrefixID() + 'gridToolbar').css('width', '380px');
            $('#' + grid.getPrefixID() + 'gridToolbar').prepend('<span class="buttonNorm" id="editReport"><img src="../libs/dynicons/?img=gnome-applications-science.svg&w=32" alt="Modify report" /> Modify Report</span> ');
            extendedToolbar = true;
            
            $('#editReport').on('click', function() {
            	isNewQuery = true;
                $('#reportTitleDisplay').css('display', 'none');
                $('#reportTitle').css('display', 'block');
            	loadSearchPrereqs();
                $('#saveLinkContainer').slideUp(700);
                $('#results').fadeOut(700);
                $('#step_1').fadeIn(700);
            });
    	}

    	if($.isEmptyObject(resIndicatorList)) {
    		$('#editLabels').css('display', 'none');
    	}
    	else {
    		$('#editLabels').css('display', 'inline');
    	}

    	urlQuery = LZString.compressToBase64(JSON.stringify(leafSearch.getLeafFormQuery().getQuery()));
    	urlIndicators = LZString.compressToBase64(JSON.stringify(selectedIndicators));
    	var version = 3;
    	/* URL formats
    	 * v1 - base64
    	 * v2 - lz-string in base64
    	 * v3 - uses getData() from formQuery.js
    	*/
    	if(isNewQuery) {
    		baseURL = '';
    		if(window.location.href.indexOf('&') == -1) {
    			baseURL = window.location.href;
    		}
    		else {
    			baseURL = window.location.href.substr(0, window.location.href.indexOf('&'));
    		}
            url = baseURL + '&v='+ version + '&query=' + encodeURIComponent(urlQuery) + '&indicators=' + encodeURIComponent(urlIndicators);
            window.history.pushState('', '', url);
            $('#reportTitle').on('keyup', function() {
                url = baseURL + '&v='+ version + '&query=' + encodeURIComponent(urlQuery) + '&indicators=' + encodeURIComponent(urlIndicators) + '&title=' + encodeURIComponent(btoa($('#reportTitle').val()));
                window.history.pushState('', '', url);
            });
    	}
    	else {
    		url = window.location.href;
    	}
    });
    
    <!--{if $query != '' && $indicators != ''}-->
    function loadReport() {
        var inQuery;
        var inIndicators;
        var title = '';
        title = atob('<!--{$title|escape:"html"}-->');
        title = title.replace(/[^\040-\176]/g, '');
        title = title.replace(/</g, '&lt;');
        title = title.replace(/>/g, '&gt;');
        $('#reportTitleDisplay').html(title);
        $('#reportTitle').css('display', 'none');
        try {
        	if(<!--{$version}--> >= 2) {
                inQuery = JSON.parse(LZString.decompressFromBase64('<!--{$query|escape:"html"}-->'));
                t_inIndicators = JSON.parse(LZString.decompressFromBase64('<!--{$indicators|escape:"html"}-->'));
        	}
        	else {
                inQuery = JSON.parse(atob('<!--{$query|escape:"html"}-->'));
                t_inIndicators = JSON.parse(atob('<!--{$indicators|escape:"html"}-->'));
        	}
        	inIndicators = [];
        	for(var i in t_inIndicators) {
        		var temp = {};
                if($.isNumeric(t_inIndicators[i].indicatorID)) {
                    temp.indicatorID = parseInt(t_inIndicators[i].indicatorID);
                    temp.name = t_inIndicators[i].name.replace(/[^\040-\176]/g, '');
                    temp.name = temp.name.replace(/</g, '&lt;');
                    temp.name = temp.name.replace(/>/g, '&gt;');
                    inIndicators.push(temp);
                }
                else {
                    addHeader(t_inIndicators[i].indicatorID);
                }
        	}

        	leafSearch.getLeafFormQuery().setQuery(inQuery);
        	if(!isSearchingDeleted(leafSearch)) {
                inQuery.terms.pop();        		
        	}
        	leafSearch.renderPreviousAdvancedSearch(inQuery.terms);
        	headers = headers.concat(inIndicators);
        	$('#step_1').slideUp(700);
        	$('#generateReport').click();
        }
        catch(err) {
        	alert('Invalid report');
        	console.log(err);
        }
    }
    if(typeof atob == 'function') {
        loadReport();
    }
    <!--{/if}-->
    // ie9 workaround
    if(typeof atob != 'function') {
        $.ajax({
            type: 'GET',
            url: 'js/base64.js',
            dataType: 'script',
            success: function() {
                window.atob = base64.decode;
                window.btoa = base64.encode;
                <!--{if $query != '' && $indicators != ''}-->
                loadReport();
                <!--{/if}-->
            }
        });
    }
    if(typeof window.history.pushState != 'function') {
    	window.history.pushState = function(a, b, c) {
    		
    	}
    }
});
</script>
