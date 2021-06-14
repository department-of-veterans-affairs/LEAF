<link rel="stylesheet" type="text/css" href="../libs/js/jquery/layout-grid/css/layout-grid.min.css" />
<script src="../libs/js/jquery/layout-grid/js/layout-grid.min.js"></script>

<link rel="stylesheet" type="text/css" href="https://cdnjs.cloudflare.com/ajax/libs/dc/3.0.9/dc.css" />
<script src="../libs/js/moment/moment.min.js"></script>
<script src="../libs/js/moment/moment-timezone-with-data.min.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/d3/5.7.0/d3.min.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/crossfilter2/1.4.6/crossfilter.min.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/dc/3.0.9/dc.min.js"></script>

<!--Loading Modal-->
<!--{include file="../../../libs/smarty/loading_spinner.tpl" title='Timeline Explorer'}-->

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
/*
 * Timeline Explorer Javascript
 */

$('#body').addClass("loading");
let CSRFToken = '<!--{$CSRFToken}-->';
let siteLinks = ['./'];

let excludedSteps = []; // array of stepIDs to be excluded
let getDataFields = {};

/**
 * Purpose: Get Site URL
 * @param $site
 */
function getSiteURL(site) {
    return site;
}

/**
 * Purpose: Parse request data
 * @param site
 * @param service
 * @param label
 * @param recordID
 * @param categoryID
 * @param stepID
 * @param days
 * @param timestamp
 * @param data
 */
function prepCrossfilter(site, service, label, recordID, categoryID, stepID, days, timestamp, data) {
    if(isExcludedStep(stepID)) {
        return;
    }

    let dataSet = {};
    dataSet.site = site;
    dataSet.service = service;
    dataSet.label = label;
    dataSet.recordID = recordID;
    dataSet.categoryID = dataCategories[categoryID];
    dataSet.stepID = stepID;
    dataSet.days = days;
    dataSet.timestamp = new Date(timestamp * 1000);
    for(let i in getDataFields) {
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
let startBusinessHours = 8; // 8am
let endBusinessHours = 17; // 5pm
let currentTzOffset = new Date().getTimezoneOffset() / 60;
let siteTzOffset = moment.tz.zone("<!--{$systemSettings['timeZone']}-->").offset(moment.utc()) / 60; // time zone offset, in hours
let tzOffset = siteTzOffset - currentTzOffset;

// data letiables
let dataTimelines = {}; // store for all sites
let dataServiceTimelines = {}; // store for all sites with services, if services exist
let dataSteps = {};
let parsedData = []; // for crossfilter

// Chart letiables
let chart;
let facts;

/**
 * Purpose: Round inputted number
 * @param input
 * @returns {number}
 */
function round(input) {
    return Math.round(input * 10) / 10;
}

/**
 * Purpose: Check if stepID is excluded from parse
 * @param stepID
 * @returns {boolean}
 */
function isExcludedStep(stepID) {
    if(excludedSteps.indexOf(Number(stepID)) != -1) {
        return true;
    }
    return false;
}

/**
 * Purpose: Given 2 timestamps, return the number of seconds that count as "business hours"
 * @param startTime
 * @param endTime
 * @returns {number}
 */
function diffBusinessTime(startTime, endTime) {
    startTime = Number(startTime);
    endTime = Number(endTime);
    if((endTime - startTime) <= 28800) { // assume same day if the difference is <= 8 hours
        return (endTime - startTime);
    }

    let timer = 0;
    let timeResolution = 900;// in seconds
    while(startTime < endTime) {
        let startDate = new Date(startTime * 1000);
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

let minTimestamp = Infinity;

/**
 * Purpose: Processes workflow data from query on requests
 * @param queryResult
 * @param workflowData
 * @param site
 */
function processData(queryResult, workflowData, site) {
    let workflow = {};
    for(let i in workflowData) {
        workflow[workflowData[i].stepID] = workflowData[i].stepTitle;
    }
    let res = queryResult;
    let timelines = {};
    let serviceTimelines = {};

    for(let i in res) {
        let request = res[i];
        let service = '';
        let hasServices = false;
        if(res[i].service != null) {
            serviceTimelines[res[i].service] = serviceTimelines[res[i].service] || {};
            service = res[i].service.replace("&amp;", "&").replace("&apos;", "'"); // Clean up output
            hasServices = true;
        } else { // Label if No Service
            service = "No Service Selected";
        }

        let data = {};
        for(let k in getDataFields) {
            data[k] = res[i].s1['id' + k];
        }

        for(let j in request.action_history) {
            let isCounted = false;
            let idx = Number(j);
            let lastActionTimestamp = 0;
            if(request.action_history[idx + 1] != undefined) {
                let stepID = request.action_history[idx + 1].stepID;
                let startTime = request.action_history[idx].time;
                let endTime = request.action_history[idx + 1].time;
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

                let businessDaysSpent = Math.round(diffBusinessTime(startTime, endTime) /60 /60 / (endBusinessHours - startBusinessHours + 1) *100000) / 100000;
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

/**
 * Purpose: Random number generation
 * @param min
 * @param max
 * @returns {number}
 */
function randInt(min, max) {
    return Math.floor(Math.random() * (max - min + 1)) + min;
}

let labels = [];
let labelColors = [];
let niceColors = ['#0071bc', '#fad980', '#2e8540', '#e31c3d', '#00AEE8', '#92F098', '#FFF700', '#e59393', '#1EE7FD', '#B31EFD', '#b9ccb5', '#8ba6ca', '#6800E8', '#4DE800', '#FFDBDB', '#112e51', '#fdb81e', '#E800D9', '#FFFEDB', '#140DD6'];

/**
 * Purpose: Return label color for service/form
 * @param label
 * @returns {string|*}
 */
function getLabelColor(label) {
    let idx = labels.indexOf(label);
    if(idx >= 0) {
        return labelColors[idx];
    }

    let color = niceColors[labels.length % niceColors.length];
    labels.push(label);
    labelColors.push(color);
    return color;

}

/**
 * Purpose: Time Conversion
 * @param time
 * @param count
 * @returns {number}
 */
function timeConvert(time, count) {
    let res = Math.round((time / count) /60 /60 /8 *10) / 10; // to days
    return isNaN(res) ? 0 : res;
}

let queryFirstDateSubmitted = '3 months ago';
let numCategories = 0;

/**
 * Purpose: Query for workflow data
 * @param site
 * @param categoryID
 */
function renderCategory(site, categoryID) {
    let siteURL = getSiteURL(site);
    let query = new LeafFormQuery();

    query.addTerm('dateSubmitted', '>=', queryFirstDateSubmitted);
    query.addTerm('deleted', '=', 0);
    query.addTerm('categoryID', '=', categoryID);
    query.addTerm('stepID', '=', 'resolved');
    query.setRootURL(siteURL);
    query.join('action_history');
    query.join('service');

    for(let i in getDataFields) {
        query.getData(i);
    }

    let data = {};
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

/**
 * Purpose: Init containers
 */
function changeDataset() {
    $('#chartBody').slideUp();
    $('#progressContainer').fadeIn();


    sitesLoaded = [];
    dataTimelines = {};
    dataServiceTimelines = {};
    dataSteps = {};
    let checkLoaded = setInterval(function() {
        if(sitesLoaded.length >= siteLinks.length) {
            clearInterval(checkLoaded);

            renderGrid()

            $('#progressContainer').slideUp();
            $('#chartBody').fadeIn();
        }
    }, 250);

    for(let i in siteLinks) {
        loadSite(siteLinks[i], $('#categories input:checked').val());
    }
}

let uniqueCategories = {};
let dataCategories = {};

/**
 * Purpose: Init Data Containers for Forms
 * @param site
 * @param limitCategoryID
 */
function loadSite(site, limitCategoryID) {
    let siteURL = getSiteURL(site);
    $.ajax({
        type: 'GET',
        url: siteURL + 'api/formStack/categoryList/all'
    })
        .then(function(categories) {
            let tNumCategories = 0;
            for(let i in categories) {
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

/**
 * Purpose: Populate grid for services/forms
 * @returns {number}
 */
function renderGrid() {
    return 0;
    let dataTimelineRes = [];
    if (hasServices) {
        let count = 1;
        for (let i in dataServiceTimelines) {
            for (let j in dataServiceTimelines[i]) {
                dataTimelineRes.push({
                    recordID: count,
                    site: i,
                    service: j,
                    data: dataServiceTimelines[i]
                });
                count++;
            }
        }
    } else {
        for (let i in dataTimelines) {
            dataTimelineRes.push({
                recordID: i.substr(4),
                site: i,
                data: dataTimelines[i]
            });
        }
    }

    let grid = new LeafFormGrid('gridData', {readOnly: true});
    grid.hideIndex();
    grid.enableToolbar();
    grid.setData(dataTimelineRes);
    grid.setDataBlob(dataTimelineRes);
    let headers = [
    {name: 'Site', indicatorID: 'site', callback: function(data, blob) {
    let recordData = grid.getDataByRecordID(data.recordID);
    $('#'+ data.cellContainerID).html(recordData.site);
    }}

]
;
if (hasServices) {
    headers.push({name: 'Service', indicatorID: 'service', callback: function(data, blob) {
    let recordData = grid.getDataByRecordID(data.recordID);
    $('#'+ data.cellContainerID).html(recordData.service);
    }}
)
;
}
for (let i in dataSteps) {
    (function (i) {
        if (hasServices) {
            headers.push({
                name: dataSteps[i],
                indicatorID: i + 'step',
                callback: function (data, blob) {
                    let recordData = grid.getDataByRecordID(data.recordID);
                    let service = recordData.service;
                    let time = recordData.data[service][i] == undefined ? 0 : timeConvert(recordData.data[service][i].time, recordData.data[service][i].count);
                    $('#' + data.cellContainerID).html(time);
                    //                            $('#'+ data.cellContainerID).css('background-color', getLabelColor(i));
                }
            });
        } else {
            headers.push({
                name: dataSteps[i] + ' (Business Days)',
                indicatorID: i + 'step',
                callback: function (data, blob) {
                    let recordData = grid.getDataByRecordID(data.recordID);
                    let time = recordData.data[i] == undefined ? 0 : timeConvert(recordData.data[i].time, recordData.data[i].count);
                    $('#' + data.cellContainerID).html(time);
                    //                            $('#'+ data.cellContainerID).css('background-color', getLabelColor(i));
                }
            });
        }
    })(i);
}
headers.push({
    name: 'Total Business Days',
    indicatorID: 'totalDays',
    callback: function (data, blob) {
        let time = 0;
        let tTime = 0;
        let recordData = grid.getDataByRecordID(data.recordID);
        for (let i in dataSteps) {
            if (hasServices) {
                let service = recordData.service;
                tTime = recordData.data[service][i] == undefined ? 0 : timeConvert(recordData.data[service][i].time, recordData.data[service][i].count);
                ;
            } else {
                tTime = recordData.data[i] == undefined ? 0 : timeConvert(recordData.data[i].time, recordData.data[i].count);
                ;
            }
            if (!isNaN(tTime)) {
                time += tTime;
            }
        }
        $('#' + data.cellContainerID).html(Math.round(time * 10) / 10);
    }
});
grid.setHeaders(headers);
grid.renderBody();
}

let chart_workload_timescale;

/**
 * Purpose: Init Pie/Graph Charts
 */
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


    let dimSite = facts.dimension(function(d) { return d.site; });
    let dimService = facts.dimension(function(d) { return d.service; });
    let dimService2 = facts.dimension(function(d) { return d.service; });
    let dimService3 = facts.dimension(function(d) { return d.service; });
    let dimActionsPerMonth = facts.dimension(function(d) { return d3.timeDay(d.timestamp); });
    let dimSteps = facts.dimension(function(d) { return d.label.replace("&amp;", "&").replace("&apos;", "'"); }); // Clean up output
    let dimRequests = facts.dimension(function(d) { return d.recordID; });
    let dimDataClassificationType = facts.dimension(function(d) { return d.categoryID; });

    let groupDataClassificationType = dimDataClassificationType.group().reduce(
        function(p, v) {
            let key = v.site + v.recordID;
            if(p.records[key] == undefined
                || p.records[key] == 0) {
                p.records[key] = 1;
                p.count++;
            }
            return p;
        },
        function(p, v) {
            let key = v.site + v.recordID;
            if(p.records[key] == 1) {
                p.records[key] = 0;
                p.count--;
            }
            return p;
        },
        function() {
            let p = {};
            p.records = {};
            p.count = 0;
            return p;
        }
    );

    let groupActionsPerMonth = dimActionsPerMonth.group().reduceCount();
    let totalRequestsPerService = dimService.group().reduce(
        function(p, v) {
            let key = v.site + v.recordID;
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
            let key = v.site + v.recordID;
            p.records[key]--;
            if(p.records[key] == 0) {
                delete p.records[key];
                p.count--;
            }
            return p;
        },
        function() {
            let p = {};
            p.records = {};
            p.count = 0;
            return p;
        }
    );
    let totalUniqueRequests = dimRequests.group().reduceCount();
    let avgTimeSpentByService = dimService2.group().reduce(
        function(p, v) {
            let key = v.site + v.recordID;
            p.records[key] = p.records[key] + v.days || v.days;
            return p;
        },
        function(p, v) {
            let key = v.site + v.recordID;
            p.records[key] -= v.days;
            if(round(p.records[key]) <= 0) {
                delete p.records[key];
            }
            return p;
        },
        function() {
            let p = {};
            p.records = {};
            return p;
        }
    );
    let totalWorkloadService = dimService3.group().reduceCount();

    let groupSteps = dimSteps.group().reduce(
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
            let p = {};
            p.days = 0;
            p.count = 0;
            p.stepID = '';
            return p;
        }
    );
    let avgTimeSpentBySite = dimSite.group().reduce(
        function(p, v) {
            let key = v.site + v.recordID;
            p.records[key] = p.records[key] + v.days || v.days;
            return p;
        },
        function(p, v) {
            let key = v.site + v.recordID;
            p.records[key] -= v.days;
            if(round(p.records[key]) <= 0) {
                delete p.records[key];
            }
            return p;
        },
        function() {
            let p = {};
            p.records = {};
            return p;
        }
    );

    chart_count_avgCompletionTime
        .valueAccessor(function(d) {
            let totalTime = 0;
            let count = 0;
            for(let i in d.value.records) {
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

    let today = new Date();
//  let minDate = new Date(today.getFullYear(), today.getMonth() - 4);
    let minDate = new Date(minTimestamp * 1000);
    minDate.setDate(minDate.getDate() - 1);
    let lastMonth = new Date(today).setMonth(today.getMonth() - 1);
    let maxDate = new Date(today.getFullYear(), today.getMonth(), today.getDate() + 1);
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
            let totalTime = 0;
            let count = 0;
            for(let i in d.value.records) {
                if(!isNaN(d.value.records[i])) {
                    totalTime += d.value.records[i];
                    count++;
                }
            }
            return count > 0 ? totalTime / count : 0;
        })
        .title(function(d) {
            let totalTime = 0;
            let count = 0;
            for(let i in d.value.records) {
                if(!isNaN(d.value.records[i])) {
                    totalTime += d.value.records[i];
                    count++;
                }
            }
            let averageDays = count > 0 ? totalTime / count : 0;
            return d.key + ': ' + round(averageDays) + ' days'; })
        .ordering(function(d) {
            let totalTime = 0;
            let count = 0;
            for(let i in d.value.records) {
                if(!isNaN(d.value.records[i])) {
                    totalTime += d.value.records[i];
                    count++;
                }
            }
            let averageDays = count > 0 ? totalTime / count : 0;
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

/**
 * Purpose: Reinit for different filter (date)
 */
function resetFilters() {
    // pre-select last month
    let today = new Date();
    let lastMonth = new Date(today).setMonth(today.getMonth() - 1);
    let maxDate = new Date(today.getFullYear(), today.getMonth(), today.getDate() + 1);
    chart_workload_timescale.filter(dc.filters.RangedFilter(lastMonth, maxDate));
}

/**
 * Purpose: Loading visual for Init of chart and data
 */
function start() {
    let progressbar = $('#progressbar').progressbar();

    let checkLoaded = setInterval(function() {
        $('#progressbar').progressbar('option', 'value', sitesLoaded.length);
        if(sitesLoaded.length == numTotalCategories) {
            clearInterval(checkLoaded);
            $('#progressContainer').slideUp();
            $('#chartBody').fadeIn();

            setupChart();
            dc.renderAll();

            /*          resetFilters();
                        dc.renderAll();*/

//          for (let chart of dc.chartRegistry.list()) { console.log(chart.anchor(), chart.filters())}
            renderGrid();

        }
    }, 250);

    $('#progressbar').progressbar('option', 'max', siteLinks.length);
    for(let i in siteLinks) {
        loadSite(siteLinks[i]);
    }
}

let sitesLoaded = [];
let numTotalCategories = Infinity;
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
        let uploadPacket = JSON.stringify(facts.all());
        let uploadData = new FormData();
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