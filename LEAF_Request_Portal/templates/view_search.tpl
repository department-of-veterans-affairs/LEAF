<div id="searchContainer"></div>
<button id="searchContainer_getMoreResults" class="buttonNorm" style="display: none; float: right">Show more records</button>
<script>
var CSRFToken = '<!--{$CSRFToken}-->';


$(function() {
    var query = new LeafFormQuery();
    var queryLimit = 50;
    var leafSearch = new LeafFormSearch('searchContainer');
    leafSearch.setOrgchartPath('<!--{$orgchartPath}-->');

    var extendedQueryState = 0; // 0 = not run, 1 = need to process, 2 = processed
    var foundOwnRequest = false;
    var firstResult = {};
    query.onSuccess(function(res) {
        // on the first run: if there are no results that are owned by the user,
        // append requests owned by the user
        if(extendedQueryState == 0) {
            firstResult = res;
            for(var i in res) {
                if(res[i].userID == '<!--{$userID}-->') {
                    foundOwnRequest = true;
                    break;
                }
            }
        }

        if(extendedQueryState == 0
            && foundOwnRequest == false
            && leafSearch.getSearchInput() == '') {
            extendedQueryState = 1;
            query.addTerm('userID', '=', '<!--{$userID}-->');
            query.execute();
            return false;
        }

        if(extendedQueryState == 1) {
            extendedQueryState = 2;
            for(var i in firstResult) {
                res[i] = firstResult[i];
            }
        }

        var months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'June', 'July', 'Aug', 'Sept', 'Oct', 'Nov', 'Dec'];
        var grid = new LeafFormGrid(leafSearch.getResultContainerID(), {readOnly: true});
        grid.hideIndex();
        grid.setDataBlob(res);
        grid.setHeaders([
         {name: 'Date', indicatorID: 'date', editable: false, callback: function(data, blob) {
             var date = new Date(blob[data.recordID].date * 1000);
             var now = new Date();
             var year = now.getFullYear() != date.getFullYear() ? ' ' + date.getFullYear() : '';
             var formattedDate = months[date.getMonth()] + ' ' + parseFloat(date.getDate()) + year;
             $('#'+data.cellContainerID).html(formattedDate);
             if(blob[data.recordID].userID == '<!--{$userID}-->') {
                 $('#'+data.cellContainerID).css('background-color', '#feffd1');
             }
         }},
         {name: 'Title', indicatorID: 'title', callback: function(data, blob) {
            var types = '';
            for(var i in blob[data.recordID].categoryNames) {
                if(blob[data.recordID].categoryNames[i] != '') {
                    types += blob[data.recordID].categoryNames[i] + ' | ';
                }
            }
            types = types.substr(0, types.length - 3);

            priority = '';
            priorityStyle = '';
            if(blob[data.recordID].priority == -10) {
                priority = '<span style="color: red"> ( Emergency ) </span>';
                priorityStyle = ' style="background-color: red; color: black"';
            }

            $('#'+data.cellContainerID).html('<span class="browsecounter"><a '+priorityStyle+' href="'
                    + 'index.php?a=printview&recordID='+data.recordID + '" tabindex="-1">' + data.recordID
                    + '</a></span><a href="' + 'index.php?a=printview&recordID='+data.recordID
                    + '">' + blob[data.recordID].title + '</a><br />'
                    + '<span class="browsetypes">' + types + '</span>' + priority);
            $('#'+data.cellContainerID).on('click', function() {
                window.location = 'index.php?a=printview&recordID='+data.recordID;
            });
         }},
         {name: 'Service', indicatorID: 'service', editable: false, callback: function(data, blob) {
             $('#'+data.cellContainerID).html(blob[data.recordID].service);
             if(blob[data.recordID].userID == '<!--{$userID}-->') {
                 $('#'+data.cellContainerID).css('background-color', '#feffd1');
             }
         }},
         {name: 'Status', indicatorID: 'currentStatus', editable: false, callback: function(data, blob) {
             var waitText = blob[data.recordID].blockingStepID == 0 ? 'Pending ' : 'Waiting for ';
             var status = '';
             if(blob[data.recordID].stepID == null && blob[data.recordID].submitted == '0') {
                 status = '<span style="color: #e00000">Not Submitted</span>';
             }
             else if(blob[data.recordID].stepID == null) {
                 var lastStatus = blob[data.recordID].lastStatus;
                 if(lastStatus == '') {
                     lastStatus = '<a href="index.php?a=printview&recordID='+ data.recordID +'">Check Status</a>';
                 }
                 status = '<span style="font-weight: bold">' + lastStatus + '</span>';
             }
             else {
                 status = waitText + blob[data.recordID].stepTitle;
             }

             if(blob[data.recordID].deleted > 0) {
                 status += ', Cancelled';
             }

             $('#'+data.cellContainerID).html(status);
             if(blob[data.recordID].userID == '<!--{$userID}-->') {
                 $('#'+data.cellContainerID).css('background-color', '#feffd1');
             }
         }}
         ]);
        grid.setPostProcessDataFunc(function(data) {
            var data2 = [];
            for(var i in data) {
                <!--{if !$is_admin}-->
                if(data[i].submitted == '0'
                    && data[i].userID == '<!--{$userID}-->') {
                    data2.push(data[i]);
                }
                else if(data[i].submitted != '0') {
                    data2.push(data[i]);
                }
                <!--{else}-->
                data2.push(data[i]);
                <!--{/if}-->
            }
            return data2;
        });

        var tGridData = [];
        for(var i in res) {
            tGridData.push(res[i]);
        }
        grid.setData(tGridData);
        grid.sort('recordID', 'desc');
        grid.renderBody();
        grid.announceResults();

        $('#header_date').css('width', '60px');
        $('#header_service').css('width', '150px');
        $('#header_currentStatus').css('width', '100px');

        // UI for "show more results". After 150 results, "show all results"
        if(queryLimit % 50 == 0) {
            $('#searchContainer_getMoreResults').css('display', 'inline');
        }
        else {
            $('#searchContainer_getMoreResults').css('display', 'none');
        }
        if(queryLimit > 100) {
            $('#searchContainer_getMoreResults').html('Show ALL records');
        }
    });
    leafSearch.setSearchFunc(function(txt) {
        query.clearTerms();

        var isJSON = true;
        var advSearch = {};
        try {
            advSearch = $.parseJSON(txt);
        }
        catch(err) {
            isJSON = false;
        }

        txt = txt.trim();
        if(txt == '' || txt == '*') {
            query.setLimit(queryLimit);
        }

        if(txt == '') {
            query.addTerm('title', 'LIKE', '*');
        }
        else if($.isNumeric(txt)) {
            query.addTerm('recordID', '=', txt);
        }
        else if(isJSON) {
            for(var i in advSearch) {
                if(advSearch[i].id != 'data'
                    && advSearch[i].id != 'dependencyID') {
                    query.addTerm(advSearch[i].id, advSearch[i].operator, advSearch[i].match, advSearch[i].op);
                }
                else {
                    query.addDataTerm(advSearch[i].id, advSearch[i].indicatorID, advSearch[i].operator, advSearch[i].match, advSearch[i].op);
                }

                if(advSearch[i].id == 'title'
                        && advSearch[i].match == '**') {
                    query.setLimit(queryLimit);
                }
            }
        }
        else {
            query.addTerm('title', 'LIKE', '*' + txt + '*');
        }

        // check if the user wants to search for deleted requests
        var hasDeleteQuery = false;
        for(var i in query.getQuery().terms) {
            if(query.getQuery().terms[i].id == 'stepID'
                && query.getQuery().terms[i].operator == '='
                && query.getQuery().terms[i].match == 'deleted') {
                hasDeleteQuery = true;
                break;
            }
        }
        if(!hasDeleteQuery) {
            query.addTerm('deleted', '=', 0);
        }

        query.join('service');
        query.join('status');
        query.join('categoryName');
        query.sort('date', 'DESC');
        return query.execute();
    });
    leafSearch.init();

    $('#searchContainer_getMoreResults').on('click', function() {
        if(leafSearch.getSearchInput() == '') {
            var tQuery = query.getQuery();
            for(var i in tQuery.terms) {
                if(tQuery.terms[i].id == 'userID') {
                    tQuery.terms.splice(i, 1);
                }
            }
            query.setQuery(tQuery);
        }
        if(queryLimit <= 100) {
            queryLimit += 50;
            query.setLimit(queryLimit);
        }
        else {
            query.setLimit();
        }
        query.execute()
    });
});
</script>
