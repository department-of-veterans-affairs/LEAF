<link rel="stylesheet" type="text/css" href="../libs/js/jquery/layout-grid/css/layout-grid.min.css" />
<script src="../libs/js/jquery/layout-grid/js/layout-grid.min.js"></script>

<link rel="stylesheet" type="text/css" href="https://cdnjs.cloudflare.com/ajax/libs/dc/3.0.9/dc.css" />
<script src="../libs/js/moment/moment.min.js"></script>
<script src="../libs/js/moment/moment-timezone-with-data.min.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/d3/5.7.0/d3.min.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/crossfilter2/1.4.6/crossfilter.min.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/dc/3.0.9/dc.min.js"></script>

<style>
.label {
    text-align: center;
    background-color: #5b616b;
    color: white;
    font-size: 120%;
    font-weight: bold;
    padding: 4px;
    cursor: grab;
}

.chart {
    height: 90%;
    width: 100%;
}
    
.dc-chart g.row text {
    fill: black;
}

.chartContainer {
    overflow-y: scroll;
}

#chart .axis.x text {
    text-anchor: end;
    transform: rotate(-45deg);
}
</style>

<script>
    
var CSRFToken = '<!--{$CSRFToken}-->';
var siteLinks = ['./'];

var excludedSteps = []; // array of stepIDs to be excluded
var getDataFields = {};

function getSiteURL(site) {
    return site;
}

function prepCrossfilter(site, service, label, recordID, categoryID, stepID, days, timestamp, data) {
    if(isExcludedStep(stepID)) {
        return;
    }

    var dataSet = {};
    dataSet.site = site;
    dataSet.service = service;
    dataSet.label = label;
    dataSet.recordID = recordID;
    dataSet.categoryID = dataCategories[categoryID];
    dataSet.stepID = stepID;
    dataSet.days = days;
    dataSet.timestamp = new Date(timestamp * 1000);
    for(var i in getDataFields) {
        if(getDataFields[i].transform != undefined) {
            dataSet[i] = getDataFields[i].transform(data[i]);
        }
        else {
            dataSet[i] = data[i];
        }
    }
    
    // process custom data fields
    
    parsedData.push(dataSet);
}

// Calculates time difference during business hours
var startBusinessHours = 8; // 8am
var endBusinessHours = 17; // 5pm
var currentTzOffset = new Date().getTimezoneOffset() / 60;
var siteTzOffset = moment.tz.zone("<!--{$systemSettings['timeZone']}-->").offset(moment.utc()) / 60; // time zone offset, in hours
var tzOffset = siteTzOffset - currentTzOffset;

// data variables
var dataTimelines = {}; // store for all sites
var dataServiceTimelines = {}; // store for all sites with services, if services exist
var dataSteps = {};
var parsedData = []; // for crossfilter

// Chart variables
var chart;
var facts;

function round(input) {
    return Math.round(input * 10) / 10;
}

function isExcludedStep(stepID) {
    if(excludedSteps.indexOf(Number(stepID)) != -1) {
        return true;
    }
    return false;
}

// Given 2 timestamps, return the number of seconds that count as "business hours"
function diffBusinessTime(startTime, endTime) {
    startTime = Number(startTime);
    endTime = Number(endTime);
    if((endTime - startTime) <= 28800) { // assume same day if the difference is <= 8 hours
        return (endTime - startTime);
    }

    var timer = 0;
    var timeResolution = 900;// in seconds
    while(startTime < endTime) {
        var startDate = new Date(startTime * 1000);
        if(startDate.getHours() - tzOffset >= startBusinessHours
            && startDate.getHours() - tzOffset <= endBusinessHours
            && startDate.getDay() >= 1
            && startDate.getDay() <= 5) {
            timer += timeResolution;
        }
        startTime += timeResolution;
    }
    return timer;
}

var hasServices = false;
var minTimestamp = Infinity;
function processData(queryResult, workflowData, site) {
    var workflow = {};
    for(var i in workflowData) {
        workflow[workflowData[i].stepID] = workflowData[i].stepTitle;
    }
    var res = queryResult;
    var timelines = {};
    var serviceTimelines = {};

    for(var i in res) {
        var request = res[i];
        var service = '';
        if(res[i].service != null) {
            serviceTimelines[res[i].service] = serviceTimelines[res[i].service] || {};
            service = res[i].service;
            hasServices = true;
        }

        var data = {};
        for(var k in getDataFields) {
            data[k] = res[i].s1['id' + k];
        }

        for(var j in request.action_history) {
            var isCounted = false;
            var idx = Number(j);
            var lastActionTimestamp = 0;
            if(request.action_history[idx + 1] != undefined) {
                var stepID = request.action_history[idx + 1].stepID;
                var startTime = request.action_history[idx].time;
                var endTime = request.action_history[idx + 1].time;
                lastActionTimestamp = lastActionTimestamp < endTime ? endTime : lastActionTimestamp;
                minTimestamp = minTimestamp > startTime ? startTime : minTimestamp;

                if(workflow[stepID] != undefined) {
                    timelines[stepID] = timelines[stepID] || {};
                    timelines[stepID].label = workflow[stepID];
                    
                    if(hasServices) {
                        serviceTimelines[res[i].service] = serviceTimelines[res[i].service] || {};
                        serviceTimelines[res[i].service][stepID] = serviceTimelines[res[i].service][stepID] || {};
                    }
                }
                else if (stepID == 0) {
                    // only track "Send Back" separately from "Other route" when checkbox is enabled
                    if ($('#showSendBackData').is(':checked')) {
                        timelines[stepID] = timelines[stepID] || {};
                        timelines[stepID].label = "Send Back";

                        if(hasServices) {
                            serviceTimelines[res[i].service][stepID] = serviceTimelines[res[i].service][stepID] || {};
                        }
                    }
                    else {
                        stepID = 'Other route';
                        timelines[stepID] = timelines[stepID] || {};
                        timelines[stepID].label = 'Other route';
                        if(hasServices) {
                            serviceTimelines[res[i].service][stepID] = serviceTimelines[res[i].service][stepID] || {};
                        }
                    }
                }
                else {
                    stepID = 'Other route';
                    timelines[stepID] = timelines[stepID] || {};
                    timelines[stepID].label = 'Other route';
                    if(hasServices) {
                        serviceTimelines[res[i].service][stepID] = serviceTimelines[res[i].service][stepID] || {};
                    }
                }

                // only count the slowest approver in a multi-requirement step   
                if(request.action_history[idx].stepID != request.action_history[idx + 1].stepID) {
                    timelines[stepID].count = timelines[stepID].count == undefined ? 1 : timelines[stepID].count + 1;
                    if(hasServices) {
                        serviceTimelines[res[i].service][stepID].count = serviceTimelines[res[i].service][stepID].count == undefined ? 1 : serviceTimelines[res[i].service][stepID].count + 1;
                    }
                    isCounted = true;
                }

                timelines[stepID].time = timelines[stepID].time == undefined ? diffBusinessTime(startTime, endTime) : timelines[stepID].time + diffBusinessTime(startTime, endTime);
                if(hasServices) {
                    serviceTimelines[res[i].service][stepID].time = serviceTimelines[res[i].service][stepID].time == undefined ? diffBusinessTime(startTime, endTime) : serviceTimelines[res[i].service][stepID].time + diffBusinessTime(startTime, endTime);
                }
                dataSteps[stepID] = timelines[stepID].label;

                var businessDaysSpent = Math.round(diffBusinessTime(startTime, endTime) /60 /60 / (endBusinessHours - startBusinessHours + 1) *100000) / 100000;
                prepCrossfilter(site, service, timelines[stepID].label, res[i].recordID, res[i].categoryID, stepID, businessDaysSpent, lastActionTimestamp, data)

                // don't count time taken during sendbacks or other route overrides
                if (!$('#showSendBackData').is(':checked')) {
                    if(request.action_history[idx + 1].stepID == 0) {
                        if(isCounted) {
                            timelines[stepID].count--;
                            if(hasServices) {
                                serviceTimelines[res[i].service][stepID].count--;
                            }
                        }
                        timelines[stepID].time -= diffBusinessTime(startTime, endTime);
                        if(hasServices) {
                            serviceTimelines[res[i].service][stepID].time -= diffBusinessTime(startTime, endTime);
                        }
                    }
                }
            }
        }
    }

    dataTimelines[site] = timelines;
    dataServiceTimelines[site] = serviceTimelines;
    sitesLoaded.push(site);
}

function randInt(min, max) {
    return Math.floor(Math.random() * (max - min + 1)) + min;
}

var labels = [];
var labelColors = [];
var niceColors = ['#0071bc', '#fad980', '#2e8540', '#e31c3d', '#00AEE8', '#92F098', '#FFF700', '#e59393', '#1EE7FD', '#B31EFD', '#b9ccb5', '#8ba6ca', '#6800E8', '#4DE800', '#FFDBDB', '#112e51', '#fdb81e', '#E800D9', '#FFFEDB', '#140DD6'];
function getLabelColor(label) { 
    var idx = labels.indexOf(label);
    if(idx >= 0) {
        return labelColors[idx];
    }

    var color = niceColors[labels.length % niceColors.length]; 
    labels.push(label);
    labelColors.push(color);
    return color;
    
}

function timeConvert(time, count) {
    var res = Math.round((time / count) /60 /60 /8 *10) / 10; // to days
    return isNaN(res) ? 0 : res;
}

var queryFirstDateSubmitted = '3 months ago';
var numCategories = 0;
function renderCategory(site, categoryID) {
    var siteURL = getSiteURL(site);
    var query = new LeafFormQuery();

    query.addTerm('dateSubmitted', '>=', queryFirstDateSubmitted);
    query.addTerm('deleted', '=', 0);
    query.addTerm('categoryID', '=', categoryID);
    query.addTerm('stepID', '=', 'resolved');
    query.setRootURL(siteURL);
    query.join('action_history');
    query.join('service');

    for(var i in getDataFields) {
        query.getData(i);
    }
    
    var data = {};
    query.onSuccess(function(res) {
        numCategories++;

        $.ajax({
            type: 'GET',
            url: siteURL + 'api/form/_' + categoryID + '/workflow'
        })
        .then(function(workflow) {
            $.ajax({
                type: 'GET',
                url: siteURL + 'api/workflow/' + workflow[0].workflowID
            })
            .then(function(workflowData) {
                processData(res, workflowData, site);
            });
        });
    });
    
    query.execute();
}

function changeDataset() {
    $('#chartBody').slideUp();
    $('#progressContainer').fadeIn();


    sitesLoaded = [];
    dataTimelines = {};
    dataServiceTimelines = {};
    dataSteps = {};
    var checkLoaded = setInterval(function() {
        if(sitesLoaded.length >= siteLinks.length) {
            clearInterval(checkLoaded);

            renderGrid()

            $('#progressContainer').slideUp();
            $('#chartBody').fadeIn();
        }
    }, 250);

    for(var i in siteLinks) {
        loadSite(siteLinks[i], $('#categories input:checked').val());
    }
}

var uniqueCategories = {};
var dataCategories = {};
function loadSite(site, limitCategoryID) {
    var siteURL = getSiteURL(site);
    $.ajax({
        type: 'GET',
        url: siteURL + 'api/formStack/categoryList/all'
    })
    .then(function(categories) {
        var tNumCategories = 0;
        for(var i in categories) {
            dataCategories[categories[i].categoryID] = categories[i].categoryName;
            if(categories[i].workflowID > 0
                && categories[i].parentID == '') {

                tNumCategories++;
                if(!document.getElementById('category_'+ categories[i].categoryID)) {
                    $('#categories').append('<div style="float: left; padding: 8px; white-space: nowrap"><input type="radio" id="category_'+ categories[i].categoryID +'" name="categoryID" value="'+ categories[i].categoryID +'" /><label class="checkable" for="category_'+ categories[i].categoryID +'">' + categories[i].categoryName + '</label></div>');
                }

                if(limitCategoryID == undefined) {
                    renderCategory(site, categories[i].categoryID);
                    $('#category_'+ categories[i].categoryID).attr('checked', 'checked');
                }
                else if(limitCategoryID == categories[i].categoryID){
                    renderCategory(site, categories[i].categoryID);
                    $('#category_'+ categories[i].categoryID).attr('checked', 'checked');
                }
            }
        }
        numTotalCategories = tNumCategories;
    });
}

function renderGrid() {
    return 0;
    var dataTimelineRes = [];
    if(hasServices) {
        var count = 1;
        for(var i in dataServiceTimelines) {
            for(var j in dataServiceTimelines[i]) {
                dataTimelineRes.push({
                    recordID: count,
                    site: i,
                    service: j,
                    data: dataServiceTimelines[i]
                });
                count++;
            }
        }
    }
    else {
        for(var i in dataTimelines) {
            dataTimelineRes.push({
                recordID: i.substr(4),
                site: i,
                data: dataTimelines[i]
            });
        }
    }

    var grid = new LeafFormGrid('gridData', {readOnly: true});
    grid.hideIndex();
    grid.enableToolbar();
    grid.setData(dataTimelineRes);
    grid.setDataBlob(dataTimelineRes);
    var headers = [
        {name: 'Site', indicatorID: 'site', callback: function(data, blob) {
            var recordData = grid.getDataByRecordID(data.recordID);
            $('#'+ data.cellContainerID).html(recordData.site);
        }}
    ];
    if(hasServices) {
        headers.push({name: 'Service', indicatorID: 'service', callback: function(data, blob) {
            var recordData = grid.getDataByRecordID(data.recordID);
            $('#'+ data.cellContainerID).html(recordData.service);
        }});
    }
    for(var i in dataSteps) {
        (function(i) {
            if(hasServices) {
                headers.push({
                    name: dataSteps[i],
                    indicatorID: i + 'step',
                    callback: function(data, blob) {
                        var recordData = grid.getDataByRecordID(data.recordID);
                        var service = recordData.service;
                        var time = recordData.data[service][i] == undefined ? 0 : timeConvert(recordData.data[service][i].time, recordData.data[service][i].count);
                        $('#'+ data.cellContainerID).html(time);
                        //                            $('#'+ data.cellContainerID).css('background-color', getLabelColor(i));
                    }
                });
            }
            else {
                headers.push({
                    name: dataSteps[i] + ' (Business Days)',
                    indicatorID: i + 'step',
                    callback: function(data, blob) {
                        var recordData = grid.getDataByRecordID(data.recordID);
                        var time = recordData.data[i] == undefined ? 0 : timeConvert(recordData.data[i].time, recordData.data[i].count);
                        $('#'+ data.cellContainerID).html(time);
                        //                            $('#'+ data.cellContainerID).css('background-color', getLabelColor(i));
                    }
                });
            }
        })(i);
    }
    headers.push({
        name: 'Total Business Days',
        indicatorID: 'totalDays',
        callback: function(data, blob) {
            var time = 0;
            var tTime = 0;
            var recordData = grid.getDataByRecordID(data.recordID);
            for(var i in dataSteps) {
                if(hasServices) {
                    var service = recordData.service;
                    tTime = recordData.data[service][i] == undefined? 0 : timeConvert(recordData.data[service][i].time, recordData.data[service][i].count);;
                }
                else {
                    tTime = recordData.data[i] == undefined? 0 : timeConvert(recordData.data[i].time, recordData.data[i].count);;
                }
                if(!isNaN(tTime)) {
                    time += tTime;
                }
            }
            $('#'+ data.cellContainerID).html(Math.round(time * 10) / 10);
        }
    });
    grid.setHeaders(headers);
    grid.renderBody();
}

var chart_workload_timescale;
function setupChart() {
    facts = crossfilter(parsedData);

    // setup chart
    chart_pie_category = dc.pieChart("#chart_pie_category");
    chart_workload_timescale = dc.barChart("#chart_workload_timescale");
    chart_pie_steps = dc.pieChart("#chart_pie_steps");
    chart_row_steps = dc.rowChart("#chart_row_steps");
    chart_pie_steps_total = dc.pieChart("#chart_pie_steps_total");
    chart_row_steps_total = dc.rowChart("#chart_row_steps_total");
    chart_form_type = dc.rowChart("#chart_form_type");
    chart_facilities = dc.rowChart("#chart_facilities");
    chart_workload_facilities = dc.rowChart("#chart_workload_facilities");
    chart_workload_facilities_numRequests = dc.rowChart("#chart_workload_facilities_numRequests");
    chart_table_requests = dc.dataTable("#chart_table_requests");
    chart_count_avgCompletionTime = dc.numberDisplay("#chart_count_avgCompletionTime");
    chart_countResolvedRequests = dc.numberDisplay("#chart_countResolvedRequests");
    

    var dimSite = facts.dimension(function(d) { return d.site; });
    var dimService = facts.dimension(function(d) { return d.service; });
    var dimService2 = facts.dimension(function(d) { return d.service; });
    var dimService3 = facts.dimension(function(d) { return d.service; });
    var dimActionsPerMonth = facts.dimension(function(d) { return d3.timeDay(d.timestamp); });
    var dimSteps = facts.dimension(function(d) { return d.label; });
    var dimRequests = facts.dimension(function(d) { return d.recordID; });
    var dimDataClassificationType = facts.dimension(function(d) { return d.categoryID; });

    var groupDataClassificationType = dimDataClassificationType.group().reduce(
        function(p, v) {
            var key = v.site + v.recordID;
            if(p.records[key] == undefined
              || p.records[key] == 0) {
                p.records[key] = 1;
                p.count++;
            }
            return p;
        },
        function(p, v) {
            var key = v.site + v.recordID;
            if(p.records[key] == 1) {
                p.records[key] = 0;
                p.count--;
            }
            return p;
        },
        function() {
            var p = {};
            p.records = {};
            p.count = 0;
            return p;
        }
    );

    var groupActionsPerMonth = dimActionsPerMonth.group().reduceCount();
    var totalRequestsPerService = dimService.group().reduce(
        function(p, v) {
            var key = v.site + v.recordID;
            if(p.records[key] == undefined) {
                p.records[key] = 1;
                p.count++;
            }
            else {
                p.records[key]++;
            }
            return p;
        },
        function(p, v) {
            var key = v.site + v.recordID;
            p.records[key]--;
            if(p.records[key] == 0) {
                delete p.records[key];
                p.count--;
            }
            return p;
        },
        function() {
            var p = {};
            p.records = {};
            p.count = 0;
            return p;
        }
    );
    var totalUniqueRequests = dimRequests.group().reduceCount();
    var avgTimeSpentByService = dimService2.group().reduce(
        function(p, v) {
            var key = v.site + v.recordID;
            p.records[key] = p.records[key] + v.days || v.days;
            return p;
        },
        function(p, v) {
            var key = v.site + v.recordID;
            p.records[key] -= v.days;
            if(round(p.records[key]) <= 0) {
                delete p.records[key];
            }
            return p;
        },
        function() {
            var p = {};
            p.records = {};
            return p;
        }
    );
    var totalWorkloadService = dimService3.group().reduceCount();

    var groupSteps = dimSteps.group().reduce(
        function(p, v) {
            p.days += v.days;
            p.count++;
            p.stepID = v.stepID;
            return p;
        },
        function(p, v) {
            p.days -= v.days;
            p.count--;
            p.stepID = v.stepID;
            return p;
        },
        function() {
            var p = {};
            p.days = 0;
            p.count = 0;
            p.stepID = '';
            return p;
        }
    );
    var avgTimeSpentBySite = dimSite.group().reduce(
        function(p, v) {
            var key = v.site + v.recordID;
            p.records[key] = p.records[key] + v.days || v.days;
            return p;
        },
        function(p, v) {
            var key = v.site + v.recordID;
            p.records[key] -= v.days;
            if(round(p.records[key]) <= 0) {
                delete p.records[key];
            }
            return p;
        },
        function() {
            var p = {};
            p.records = {};
            return p;
        }
    );
    
    chart_count_avgCompletionTime
        .valueAccessor(function(d) {
            var totalTime = 0;
            var count = 0;
            for(var i in d.value.records) {
                if(!isNaN(d.value.records[i])) {
                    totalTime += d.value.records[i];
                    count++;
                }
            }
            return count > 0 ? totalTime / count : 0;
        })
        .group(avgTimeSpentBySite)
        .formatNumber(d3.format(',.01f'));

    chart_countResolvedRequests
        .valueAccessor(function(d) {
            return totalUniqueRequests.all().filter(function(d) { return d.value > 0; }).length;
        })
        .group(totalUniqueRequests)
        .formatNumber(d3.format(',.0f'));

    chart_pie_category
        .useViewBoxResizing(true)
        .dimension(dimDataClassificationType)
        .group(groupDataClassificationType)
        .valueAccessor(function(d) { return d.value.count; })
        .title(function(d) { return d.key + ': ' + round(d.value.count) + ' requests'; })
//      .ordering(function(d) { return d.value.days; })
//      .legend(dc.legend().y(0).x(40))
        .ordinalColors(niceColors)
        .legend(dc.legend())
        .label(function(d) {
        })
        .on("pretransition", function(chart) {
            chart.selectAll('g path').style('stroke', function (d) {
                return '#000';
            });
            chart.selectAll('g text').style('fill', function (d) {
                return '#000';
            });
            chart.select('g :not(.dc-legend)').attr('transform', 'translate(0, 30)');
        });

    var today = new Date();
//  var minDate = new Date(today.getFullYear(), today.getMonth() - 4);
    var minDate = new Date(minTimestamp * 1000);
    minDate.setDate(minDate.getDate() - 1);
    var lastMonth = new Date(today).setMonth(today.getMonth() - 1);
    var maxDate = new Date(today.getFullYear(), today.getMonth(), today.getDate() + 1);
    chart_workload_timescale
        .useViewBoxResizing(true)
        .dimension(dimActionsPerMonth)
        .group(groupActionsPerMonth)
        .yAxisLabel('Handoffs')
        .x(d3.scaleTime().domain([minDate, maxDate]))
        .xUnits(d3.timeDays)
        .elasticY(true);

//  chart_workload_timescale.yAxis().ticks(4);
    chart_workload_timescale.xAxis().ticks(4);
//chart_workload_timescale.xAxis().tickFormat(d3.timeFormat("%b %Y"));

    chart_pie_steps
        .useViewBoxResizing(true)
        .dimension(dimSteps)
        .group(groupSteps)
        .valueAccessor(function(d) { return d.value.count > 0 ? d.value.days / d.value.count : 0; })
        .title(function(d) { return d.key + ': ' + round(d.value.days / d.value.count) + ' days'; })
        .ordering(function(d) { return d.value.count > 0 ? d.value.days / d.value.count : 0; })
//      .legend(dc.legend().y(0).x(40))
        .label(function() {}, false)
        .on("pretransition", function(chart) {
            chart.selectAll('g path').style('fill', function (d) {
                return getLabelColor(d.data.value.stepID);
            });
            chart.selectAll('g path').style('stroke', function (d) {
                return '#000';
            });
        });

    chart_row_steps
        .useViewBoxResizing(true)
        .dimension(dimSteps)
        .group(groupSteps)
        .valueAccessor(function(d) { return d.value.count > 0 ? d.value.days / d.value.count : 0; })
        .ordering(function(d) { return -(d.value.count > 0 ? d.value.days / d.value.count : 0); })
        .title(function(d) { return d.key + ': ' + round(d.value.days / d.value.count) + ' days'; })
        .gap(2)
        .rowsCap(14)
        .othersLabel('All others')
        .fixedBarHeight(14)
        .elasticX(true)
        .on("pretransition", function(chart) {
            chart.selectAll('g rect').style('fill', function (d) {
                return getLabelColor(d.value.stepID);
            });
            chart.selectAll('g rect.deselected').style('fill', function (d) {
                return '#ccc';
            });
        });

    chart_pie_steps_total
        .useViewBoxResizing(true)
        .dimension(dimSteps)
        .group(groupSteps)
        .valueAccessor(function(d) { return d.value.days; })
        .title(function(d) { return d.key + ': ' + round(d.value.days) + ' days'; })
        .ordering(function(d) { return d.value.days; })
//      .legend(dc.legend().y(0).x(40))
        .label(function() {}, false)
        .on("pretransition", function(chart) {
            chart.selectAll('g path').style('fill', function (d) {
                return getLabelColor(d.data.value.stepID);
            });
            chart.selectAll('g path').style('stroke', function (d) {
                return '#000';
            });
        });

    chart_row_steps_total
        .useViewBoxResizing(true)
        .dimension(dimSteps)
        .group(groupSteps)
        .valueAccessor(function(d) { return d.value.days; })
        .title(function(d) { return d.key + ': ' + round(d.value.days) + ' days'; })
        .ordering(function(d) { return -d.value.days; })
        .gap(2)
        .rowsCap(14)
        .othersLabel('All others')
        .fixedBarHeight(14)
        .elasticX(true)
        .on("pretransition", function(chart) {
            chart.selectAll('g rect').style('fill', function (d) {
                return getLabelColor(d.value.stepID);
            });
            chart.selectAll('g rect.deselected').style('fill', function (d) {
                return '#ccc';
            });
        });

    chart_facilities
        .height((avgTimeSpentByService.all().length * 18) + 60)
        .dimension(dimService2)
        .group(avgTimeSpentByService)
        .valueAccessor(function(d) {
            var totalTime = 0;
            var count = 0;
            for(var i in d.value.records) {
                if(!isNaN(d.value.records[i])) {
                    totalTime += d.value.records[i];
                    count++;
                }
            }
            return count > 0 ? totalTime / count : 0;
        })
        .title(function(d) {
            var totalTime = 0;
            var count = 0;
            for(var i in d.value.records) {
                if(!isNaN(d.value.records[i])) {
                    totalTime += d.value.records[i];
                    count++;
                }
            }
            var averageDays = count > 0 ? totalTime / count : 0;
            return d.key + ': ' + round(averageDays) + ' days'; })
        .ordering(function(d) {
            var totalTime = 0;
            var count = 0;
            for(var i in d.value.records) {
                if(!isNaN(d.value.records[i])) {
                    totalTime += d.value.records[i];
                    count++;
                }
            }
            var averageDays = count > 0 ? totalTime / count : 0;
            return -averageDays;
        })
        .gap(2)
//      .rowsCap(9)
        .othersLabel('All others')
        .fixedBarHeight(14)
        .elasticX(true);

    chart_facilities.xAxis().ticks(4);
    
    chart_workload_facilities
        .useViewBoxResizing(true)
        .height((totalWorkloadService.all().length * 18) + 60)
        .dimension(dimService3)
        .group(totalWorkloadService)
        .title(function(d) { return d.key + ': ' + round(d.value) + ' actions taken'; })
        .gap(2)
        .othersLabel('All others')
        .fixedBarHeight(14)
        .elasticX(true);

    chart_workload_facilities_numRequests
        .useViewBoxResizing(true)
        .height((totalRequestsPerService.all().length * 18) + 60)
        .dimension(dimService)
        .group(totalRequestsPerService)
        .valueAccessor(function(d) { return d.value.count; })
        .title(function(d) { return d.value.count + ' requests'; })
        .ordering(function(d) { return -d.value.count; })
        .gap(2)
        .othersLabel('All others')
        .fixedBarHeight(14)
        .elasticX(true);

    chart_form_type
        .useViewBoxResizing(true)
        .dimension(dimDataClassificationType)
        .group(groupDataClassificationType)
        .valueAccessor(function(d) { return d.value.count; })
        .title(function(d) { return d.value.count + ' requests'; })
        .ordering(function(d) { return -d.value.count; })
        .gap(2)
        .othersLabel('All others')
        .fixedBarHeight(14)
        .elasticX(true);

    chart_table_requests
        .dimension(dimService)
        .group(function(d) {
            return d.recordID;
        })
        .showGroups(false)
        .columns([
            function(d) { return d.service; },
            function(d) { return '<a href="index.php?a=printview&recordID='+ d.recordID +'" target="_blank">' + d.recordID + '</a>'; },
            function(d) { return dataSteps[d.stepID]; },
            function(d) { return round(d.days); }
        ])
        .sortBy(function(d) { return -d.days; })
        .size(Infinity)
        .beginSlice(0)
        .endSlice(10);
}

function resetFilters() {
    // pre-select last month
    var today = new Date();
    var lastMonth = new Date(today).setMonth(today.getMonth() - 1);
    var maxDate = new Date(today.getFullYear(), today.getMonth(), today.getDate() + 1);
    chart_workload_timescale.filter(dc.filters.RangedFilter(lastMonth, maxDate));
}

function start() {
    var progressbar = $('#progressbar').progressbar();

    var checkLoaded = setInterval(function() {
        $('#progressbar').progressbar('option', 'value', sitesLoaded.length);
        if(sitesLoaded.length == numTotalCategories) {
            clearInterval(checkLoaded);
            $('#progressContainer').slideUp();
            $('#chartBody').fadeIn();

            setupChart();
            dc.renderAll();

/*          resetFilters();
            dc.renderAll();*/

//          for (var chart of dc.chartRegistry.list()) { console.log(chart.anchor(), chart.filters())}
            renderGrid();

        }
    }, 250);

    $('#progressbar').progressbar('option', 'max', siteLinks.length);
    for(var i in siteLinks) {
        loadSite(siteLinks[i]);
    }
}

var sitesLoaded = [];
var numTotalCategories = Infinity;
$(function() {
    start();

    $('#showDateSubmitted').on('change', function() {
        queryFirstDateSubmitted = $('#showDateSubmitted').val();
        parsedData = [];
        sitesLoaded = [];
        $('#chartBody').slideUp();
        $('#progressContainer').fadeIn();
        start();
    });

    
    $('#btn_saveData').on('click', function() {
            var uploadPacket = JSON.stringify(facts.all());
            var uploadData = new FormData();
            uploadData.append('CSRFToken', CSRFToken);
            uploadData.append('file', new Blob([ uploadPacket ]), 'temp_leaf_timeline_data.json');
            $.ajax({
                type: 'POST',
                url: './admin/ajaxIndex.php?a=uploadFile',
                data: uploadData,
                processData: false,
                contentType: false,
                success: function() {
                    $('#linkToSavedData').html('<a href="./files/temp_leaf_timeline_data.json">Download JSON data</a>');
                }
            });
    });
});

</script>
<div id="progressContainer" style="width: 50%; border: 1px solid black; background-color: white; margin: auto; padding: 16px">
    <h1 style="text-align: center">Loading...</h1>
    <div id="progressbar"></div>
</div>

<div id="chartBody" style="display: none">
    <h1 style="text-align: center">Timeline Data Explorer <span style="background-color: white; color: red; border: 2px solid black; padding: 8px; font-style: italic">BETA</span></h1>
    <h2 style="text-align: center">Requests submitted since:
        <select id="showDateSubmitted">
            <option value="1 month ago">1 month ago</option>
            <option value="3 months ago" selected="selected">3 months ago</option>
            <option value="6 months ago">6 month ago</option>
            <option value="1 year ago">1 year ago</option>
        </select>
    </h2>
    
    <span class="buttonNorm" style="float: right" onclick="dc.filterAll(); dc.filterAll(); dc.renderAll(); resetFilters();">Reset Filters</span>
    <br style="clear: both" />

    <div>
        Stats for data in the selected set:
        <table id="container_count" class="table">
            <tr class="label">
                <td>Number of Requests</td>
            </tr>
            <tr>
                <td id="chart_countResolvedRequests" style="text-align: center"></td>
            </tr>
        </table>
    </div>

    <div id="lt-grid" class="lt-container lt-xs-h-10
                                          lt-md-h-6
                                          lt-lg-h-6" data-arrange="lt-grid">
        <!-- main overview chart -->
        <div class="lt lt-xs-x-0 lt-xs-y-0 lt-xs-w-1 lt-xs-h-1
                              lt-md-x-0 lt-md-y-0 lt-md-w-2 lt-md-h-2
                              lt-lg-x-0 lt-lg-y-0 lt-lg-w-2 lt-lg-h-2" draggable="true">
            <div class="lt-body card chartContainer">
                <div class="label">Average Completion Time (business days)</div>
                <div id="chart_count_avgCompletionTime" class="chart" style="height: 30%; text-align: center; font-size: 700%"></div>
                <div id="chart_workload_timescale" class="chart" style="height: 60%"></div>
            </div>
        </div>

        <!-- chart for complexity -->
        <div class="lt lt-xs-x-0 lt-xs-y-1 lt-xs-w-1 lt-xs-h-1
                              lt-md-x-2 lt-md-y-0 lt-md-w-1 lt-md-h-2
                              lt-lg-x-3 lt-lg-y-0 lt-lg-w-1 lt-lg-h-2" draggable="true">
            <div class="lt-body card">
                <div class="label">Type of Form</div>
                <div id="chart_pie_category" class="chart" style="padding: 8px; width: 95%"></div>
            </div>
        </div>


        <!-- chart for services/facilities -->
        <div class="lt lt-xs-x-0 lt-xs-y-2 lt-xs-w-1 lt-xs-h-1
                              lt-md-x-0 lt-md-y-2 lt-md-w-1 lt-md-h-1
                              lt-lg-x-2 lt-lg-y-0 lt-lg-w-1 lt-lg-h-2" draggable="true">
            <div class="lt-body card chartContainer">
                <div class="label">Average Completion Time per Service (business days)</div>
                <div id="chart_facilities" class="chart"></div>
            </div>
        </div>

        <!-- chart for service workload -->
        <div class="lt lt-xs-x-0 lt-xs-y-3 lt-xs-w-1 lt-xs-h-1
                              lt-md-x-2 lt-md-y-4 lt-md-w-1 lt-md-h-1
                              lt-lg-x-0 lt-lg-y-2 lt-lg-w-1 lt-lg-h-1" draggable="true">
            <div class="lt-body card chartContainer">
                <div class="label">Handoffs per Service</div>
                <div id="chart_workload_facilities" class="chart"></div>
            </div>
        </div>

        <!-- chart for service workload number of requests -->
        <div class="lt lt-xs-x-0 lt-xs-y-4 lt-xs-w-1 lt-xs-h-1
                              lt-md-x-2 lt-md-y-3 lt-md-w-1 lt-md-h-1
                              lt-lg-x-1 lt-lg-y-2 lt-lg-w-2 lt-lg-h-1" draggable="true">
            <div class="lt-body card chartContainer">
                <div class="label">Active Requests per Service</div>
                <div id="chart_workload_facilities_numRequests" class="chart"></div>
            </div>
        </div>

        <!-- chart for classification type -->
        <div class="lt lt-xs-x-0 lt-xs-y-6 lt-xs-w-1 lt-xs-h-1
                              lt-md-x-1 lt-md-y-2 lt-md-w-1 lt-md-h-1
                              lt-lg-x-3 lt-lg-y-2 lt-lg-w-1 lt-lg-h-1" draggable="true">
            <div class="lt-body card chartContainer">
                <div class="label">Type of Form</div>
                <div id="chart_form_type" class="chart"></div>
            </div>
        </div>

        <!-- chart for table: top slowest -->
        <div class="lt lt-xs-x-0 lt-xs-y-7 lt-xs-w-1 lt-xs-h-1
                              lt-md-x-0 lt-md-y-5 lt-md-w-3 lt-md-h-1
                              lt-lg-x-2 lt-lg-y-3 lt-lg-w-2 lt-lg-h-3" draggable="true">
            <div class="lt-body card chartContainer">
                <div class="label">Snapshot of slow actions</div>
                <table id="chart_table_requests" class="chart table" style="width: 99%; padding: 8px">
                    <thead>
                        <td>Service</td>
                        <td>recordID</td>
                        <td>Action</td>
                        <td>Business days for the action</td>
                    </thead>
                </table>
            </div>
        </div>

        <!-- chart for steps - cumulative -->
        <div class="lt lt-xs-x-0 lt-xs-y-8 lt-xs-w-1 lt-xs-h-1
                              lt-md-x-0 lt-md-y-3 lt-md-w-1 lt-md-h-2
                              lt-lg-x-0 lt-lg-y-3 lt-lg-w-1 lt-lg-h-3" draggable="true">
            <div class="lt-body card">
                <div class="label">Total time spent per step</div>
                <div id="chart_pie_steps_total" class="chart" style="height: 40%"></div>
                <div id="chart_row_steps_total" class="chart" style="height: 50%"></div>
                <div style="text-align: center">Business Days</div>
            </div>
        </div>

        <!-- chart for steps - average -->
        <div class="lt lt-xs-x-0 lt-xs-y-9 lt-xs-w-1 lt-xs-h-1
                              lt-md-x-1 lt-md-y-3 lt-md-w-1 lt-md-h-2
                              lt-lg-x-1 lt-lg-y-3 lt-lg-w-1 lt-lg-h-3" draggable="true">
            <div class="lt-body card">
                <div class="label">Avg. time spent per step</div>
                <div id="chart_pie_steps" class="chart" style="height: 40%"></div>
                <div id="chart_row_steps" class="chart" style="height: 50%"></div>
                <div style="text-align: center">Business Days</div>
            </div>
        </div>

    </div>

<!--
    <br />
    <div class="card" style="padding: 8px; text-align: center">
        <div id="sendBackOptions">
            <div style="float: left; padding: 8px; white-space: nowrap">
                <input type="checkbox" id="showSendBackData" name="showSendBack" />
                <label class="checkable" for="showSendBackData">Include Send Back times in averages</label>
            </div>
        </div>
        <br style="clear: both" />
        <div id="categories" style="display: none"></div>
        <br style="clear: both" />
        <button class="buttonNorm" onclick="changeDataset();">Select Dataset</button>
    </div>

    <br />
    <br style="clear: both" />
    <hr />
    <div class="card" style="padding: 8px">
        <div class="label">Dataset over the past year</div>
        <div id="gridData"></div>
    </div>
-->

    <br />
    <p>
    * Business day defined as Monday - Friday, 8am - 5pm  (Time zones may reflect minor differences)<br />
    * "Handoff" defined as an action taken that routes a request to another stakeholder
    </p>
    
    <hr />
    Advanced users:<br />
    <div>
        <button id="btn_saveData">Generate JSON data</button>
        <span id="linkToSavedData"></span>
    </div>
</div>
