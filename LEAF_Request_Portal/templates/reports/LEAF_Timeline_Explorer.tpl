<script src="js/lz-string/lz-string.min.js"></script>
<script src="../libs/js/LEAF/intervalQueue.js"></script>
<link rel="stylesheet" type="text/css" href="../libs/js/jquery/layout-grid/css/layout-grid.min.css" />
<script src="../libs/js/jquery/layout-grid/js/layout-grid.min.js"></script>

<link rel="stylesheet" type="text/css" href="https://cdnjs.cloudflare.com/ajax/libs/dc/4.2.7/style/dc.css" />
<script src="https://cdnjs.cloudflare.com/ajax/libs/d3/7.2.0/d3.min.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/crossfilter2/1.5.4/crossfilter.min.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/dc/4.2.7/dc.min.js"></script>

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

    .unitTime {
        color: white;
    }

    #chart .axis.x text {
        text-anchor: end;
        transform: rotate(-45deg);
    }
</style>

<script>
/*
 * Timeline Explorer
 */

$('#body').addClass("loading");
let CSRFToken = '<!--{$CSRFToken}-->';

let tempFilename = 'temp_leaf_timeline_data.txt';
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
function prepCrossfilter(site, service, label, recordID, categoryID, stepID, days, timestamp, isFinal, data) {
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
    dataSet.isFinal = isFinal;
    
    // process custom data fields
    for(let i in getDataFields) {
        if(getDataFields[i].transform != undefined) {
            dataSet[i] = getDataFields[i].transform(data[i]);
        }
        else {
            dataSet[i] = data[i];
        }
    }

    parsedData.push(dataSet);
}

// Calculates time difference during business hours
let startBusinessHours = 8; // 8am
let endBusinessHours = 17; // 5pm
let currentTzOffset = new Date().getTimezoneOffset() / 60;
let siteTzOffset = new Date(new Date().toLocaleString('en', {timeZone: "<!--{$systemSettings['timeZone']}-->"})).getTimezoneOffset()/60; // time zone offset, in hours
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

function diffRealTime(startTime, endTime) {
    return (endTime - startTime);
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
                timelines[stepID].realTime = timelines[stepID].realTime == undefined ? diffRealTime(startTime, endTime) : timelines[stepID].realTime + diffRealTime(startTime, endTime);
                if(hasServices) {
                    serviceTimelines[res[i].service][stepID].time = serviceTimelines[res[i].service][stepID].time == undefined ? diffBusinessTime(startTime, endTime) : serviceTimelines[res[i].service][stepID].time + diffBusinessTime(startTime, endTime);
                    serviceTimelines[res[i].service][stepID].realTime = serviceTimelines[res[i].service][stepID].realTime == undefined ? diffRealTime(startTime, endTime) : serviceTimelines[res[i].service][stepID].realTime + diffRealTime(startTime, endTime);
                }
                dataSteps[stepID] = timelines[stepID].label;

                let businessDaysSpent = Math.round(diffBusinessTime(startTime, endTime) /60 /60 / (endBusinessHours - startBusinessHours + 1) *100000) / 100000;
                let realDaysSpent = Math.round(diffRealTime(startTime, endTime) /60 /60 /24 * 100000) / 100000;
                let daysSpent = realDaysSpent;
                prepCrossfilter(site, service, timelines[stepID].label, res[i].recordID, res[i].categoryID, stepID, daysSpent, lastActionTimestamp, res[i].isFinal, data)

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
                        timelines[stepID].realTime -= diffRealTime(startTime, endTime);
                        if(hasServices) {
                            serviceTimelines[res[i].service][stepID].time -= diffBusinessTime(startTime, endTime);
                            serviceTimelines[res[i].service][stepID].realTime -= diffRealTime(startTime, endTime);
                        }
                    }
                }
            }
        }
    }

    dataTimelines[site] = timelines;
    dataServiceTimelines[site] = serviceTimelines;
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

let queryFirstDateSubmitted = '';

/**
 * Purpose: Query for workflow data
 * @param site
 * @param categoryID
 */
function loadData(site, categoryID) {
    let siteURL = getSiteURL(site);
    let promise = new Promise((resolve, reject) => {
        let query = new LeafFormQuery();
        let index = 0;

        query.addTerm('dateSubmitted', '>=', queryFirstDateSubmitted);
        query.addTerm('deleted', '=', 0);
        query.addTerm('categoryID', '=', categoryID);
        query.addTerm('stepID', '=', 'resolved');
        query.setRootURL(siteURL);
        query.join('action_history');
        query.join('service');
        query.setExtraParams('&x-filterData=recordID,service,categoryID,action_history.stepID,action_history.time');
        query.onSuccess(function(res) {
            processData(res, categoryData[site][categoryID], site);
            resolve();
        });

        for(let i in getDataFields) {
            query.getData(i);
        }

        let data = {};
        query.execute();
    });
    
    return promise;
}

let categoryData = {};
/**
 * Purpose: Load workflow data for forms
 * @param site
 * @param categoryID
 */
function loadCategory(site, categoryID) {
    let siteURL = getSiteURL(site);

    return $.ajax({
        type: 'GET',
        url: siteURL + 'api/form/_' + categoryID + '/workflow'
    })
    .then(function(workflow) {
        return $.ajax({
            type: 'GET',
            url: siteURL + 'api/workflow/' + workflow[0].workflowID
        })
        .then(function(workflowData) {
            if(categoryData[site] == undefined) {
                categoryData[site] = {};
            }
            categoryData[site][categoryID] = workflowData;
        });
    });
}

let uniqueCategories = {};
let dataCategories = {};

/**
 * Purpose: Init Data Containers for Forms
 * @param site
 * @param limitCategoryID
 */
function getCategories(site) {
    let siteURL = getSiteURL(site);
    return $.ajax({
        type: 'GET',
        url: siteURL + 'api/formStack/categoryList/all'
    })
    .then(function(categories) {
        for(let i in categories) {
            if(categories[i].workflowID > 0
               && categories[i].parentID == '') {
                dataCategories[categories[i].categoryID] = categories[i].categoryName;
            }
        }
        return dataCategories;
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
        {
            name: 'Site',
            indicatorID: 'site',
            callback: function(data, blob) {
                let recordData = grid.getDataByRecordID(data.recordID);
                $('#'+ data.cellContainerID).html(recordData.site);
            }
        }
    ];

    if (hasServices) {
        headers.push({
            name: 'Service',
            indicatorID: 'service',
            callback: function(data, blob) {
                let recordData = grid.getDataByRecordID(data.recordID);
                $('#'+ data.cellContainerID).html(recordData.service);
            }
        });
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
                    name: dataSteps[i] + ' (Days)',
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
        name: 'Total Days',
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

function flagActionDeterminingResolution() {
    let tCache = {};
    for(let i in parsedData) {
        if(tCache[parsedData[i]['recordID']] == undefined) {
            tCache[parsedData[i]['recordID']] = {};
            tCache[parsedData[i]['recordID']].time = parsedData[i].timestamp.getTime();
            tCache[parsedData[i]['recordID']].index = i;
        }
        else if (tCache[parsedData[i]['recordID']].time < parsedData[i].timestamp.getTime()) {
            tCache[parsedData[i]['recordID']].time = parsedData[i].timestamp.getTime();
            tCache[parsedData[i]['recordID']].index = i;
        }
    }

    for(let i in tCache) {
        parsedData[tCache[i].index].isFinal = 1;
    }
}
    
let chart_workload_timescale_numRequests;
let chart_workload_timescale;

/**
 * Purpose: Init Pie/Graph Charts
 * return true on success, false on failure
 */
function setupChart() {
    if(parsedData.length == 0) {
        alert('No data matches the selected set. Please expand the time range.');
        return false;
    }
    
    flagActionDeterminingResolution();
    facts = crossfilter(parsedData);

    // setup dynamic units
    let dynUnit = {};
    let today = new Date();
    switch($('#reportTimeUnit').val()) {
        case 'day':
            dynUnit.convert = d3.timeDay;
            dynUnit.chart = d3.timeDays;
            dynUnit.maxDate = 1;
            break;
		case 'week':
            dynUnit.convert = d3.timeWeek;
            dynUnit.chart = d3.timeWeeks;
            dynUnit.maxDate = 7;
            break;
        case 'month':
            dynUnit.convert = d3.timeMonth;
            dynUnit.chart = d3.timeMonths;
            dynUnit.maxDate = 31 - today.getDate();
            break;
        default:
            dynUnit.convert = d3.timeYear;
            dynUnit.chart = d3.timeYears;
            dynUnit.maxDate = 365 - today.getMonth() * 30;
            break;
    }
    $('.unitTime').html($('#reportTimeUnit').val());
    
    // setup chart
    chart_workload_timescale_numRequests = dc.barChart("#chart_workload_timescale_numRequests");
    chart_workload_timescale = dc.barChart("#chart_workload_timescale");
    let chart_pie_steps = dc.pieChart("#chart_pie_steps");
    let chart_row_steps = dc.rowChart("#chart_row_steps");
    let chart_pie_steps_total = dc.pieChart("#chart_pie_steps_total");
    let chart_row_steps_total = dc.rowChart("#chart_row_steps_total");
    let chart_form_type = dc.rowChart("#chart_form_type");
    let chart_facilities = dc.rowChart("#chart_facilities");
    let chart_workload_type = dc.rowChart("#chart_workload_type");
    let chart_workload_facilities_numRequests = dc.rowChart("#chart_workload_facilities_numRequests");
    let chart_table_requests = dc.dataTable("#chart_table_requests");
    let chart_count_avgCompletionTime = dc.numberDisplay("#chart_count_avgCompletionTime");
    let chart_countResolvedRequests = dc.numberDisplay("#chart_countResolvedRequests");

    let dimSite = facts.dimension(function(d) { return d.site; });
    let dimService = facts.dimension(function(d) { return d.service; });
    let dimService2 = facts.dimension(function(d) { return d.service; });
    let dimSteps = facts.dimension(function(d) { return d.label.replace("&amp;", "&").replace("&apos;", "'"); }); // Clean up output
    let dimRequests = facts.dimension(function(d) { return d.recordID; });
    let dimRequestsTime = facts.dimension(function(d) { return dynUnit.convert(d.timestamp); });
    let dimDataClassificationType = facts.dimension(function(d) { return d.categoryID; });

    let groupDataClassificationType = dimDataClassificationType.group().reduce(
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

    let groupTimeToResolve = dimRequestsTime.group().reduce(
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
    let groupRequests = dimRequests.group().reduceCount();
    let groupUniqueRequestsByTime = dimRequestsTime.group().reduce(
        function(p, v) {
            let key = v.site + v.recordID;
            if(p.records[key] == undefined
              && v.isFinal == 1) {
                p.records[key] = 1;
                p.count++;
            }
            return p;
        },
        function(p, v) {
            let key = v.site + v.recordID;
            p.records[key]--;
            if(p.records[key] == 0
              && v.isFinal == 1) {
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
    let totalWorkloadType = dimDataClassificationType.group().reduce(
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
            for(let i in d?.value?.records) {
                if(!isNaN(d?.value?.records[i])) {
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
            return groupRequests.all().filter(function(d) { return d.value > 0; }).length;
        })
        .group(groupRequests)
        .formatNumber(d3.format(',.0f'));

//  let minDate = new Date(today.getFullYear(), today.getMonth() - 4);
    let minDate = new Date(dimRequestsTime.bottom(1)[0].timestamp);
    minDate.setDate(minDate.getDate() - 1);
    let lastMonth = new Date(today).setMonth(today.getMonth() - 1);
    let maxDate = new Date(dimRequestsTime.top(1)[0].timestamp);
    minDate.setDate(minDate.getDate() + 1);

    chart_workload_timescale
        .useViewBoxResizing(true)
        .dimension(dimRequestsTime)
        .group(groupTimeToResolve)
        .valueAccessor(function(d) {
            let totalTime = 0;
            let count = 0;
            for(let i in d?.value?.records) {
                if(!isNaN(d?.value?.records[i])) {
                    totalTime += d.value.records[i];
                    count++;
                }
            }
            return count > 0 ? totalTime / count : 0;
        })
        .yAxisLabel('Days to resolve')
    	.gap(4)
        .x(d3.scaleTime().domain([minDate, maxDate]))
        .xUnits(dynUnit.chart)
        .elasticY(true);

//  chart_workload_timescale.yAxis().ticks(4);
    chart_workload_timescale.xAxis().ticks(5);
//chart_workload_timescale.xAxis().tickFormat(d3.timeFormat("%b %Y"));
    
	chart_workload_timescale.filterHandler(function(dimension, filters) {
        if(filters[0]?.length == 2 && typeof filters[0][0].toISOString == 'function') {
            $('#filterStart').val(filters[0][0].toISOString().substring(0, 10));
            $('#filterEnd').val(filters[0][1].toISOString().substring(0, 10));
            dimension.filterFunction((d) => {
            	return d > filters[0][0] && d < filters[0][1];
            });
        }
	    else {
            dimension.filterAll();
        }

		return filters;
    });
    
    chart_workload_timescale_numRequests
        .useViewBoxResizing(true)
        .height(176)
        .dimension(dimRequestsTime)
        .group(groupUniqueRequestsByTime)
    	.valueAccessor(function(d) { return d.value.count; })
        .yAxisLabel('Resolved Requests')
    	.gap(4)
        .x(d3.scaleTime().domain([minDate, maxDate]))
        .xUnits(dynUnit.chart)
        .elasticY(true);

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

    chart_row_steps.xAxis().ticks(5);

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

    chart_row_steps_total.xAxis().ticks(4);

    chart_facilities
        .height((avgTimeSpentByService.all().length * 18) + 60)
        .dimension(dimService2)
        .group(avgTimeSpentByService)
        .valueAccessor(function(d) {
            let totalTime = 0;
            let count = 0;
            for(let i in d?.value?.records) {
                if(!isNaN(d?.value?.records[i])) {
                    totalTime += d.value.records[i];
                    count++;
                }
            }
            return count > 0 ? totalTime / count : 0;
        })
        .title(function(d) {
            let totalTime = 0;
            let count = 0;
            for(let i in d?.value?.records) {
                if(!isNaN(d?.value?.records[i])) {
                    totalTime += d.value.records[i];
                    count++;
                }
            }
            let averageDays = count > 0 ? totalTime / count : 0;
            return d.key + ': ' + round(averageDays) + ' days'; })
        .ordering(function(d) {
            let totalTime = 0;
            let count = 0;
            for(let i in d?.value?.records) {
                if(!isNaN(d?.value?.records[i])) {
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

    chart_workload_type
        .useViewBoxResizing(true)
        .height((totalWorkloadType.all().length * 18) + 60)
        .dimension(dimDataClassificationType)
        .group(totalWorkloadType)
        .valueAccessor(function(d) {
            let totalTime = 0;
            let count = 0;
            for(let i in d?.value?.records) {
                if(!isNaN(d?.value?.records[i])) {
                    totalTime += d.value.records[i];
                    count++;
                }
            }
            return count > 0 ? totalTime / count : 0;
        })
        .title(function(d) {
            let totalTime = 0;
            let count = 0;
            for(let i in d?.value?.records) {
                if(!isNaN(d?.value?.records[i])) {
                    totalTime += d.value.records[i];
                    count++;
                }
            }
            let averageDays = count > 0 ? totalTime / count : 0;
            return d.key + ': ' + round(averageDays) + ' days'; })
        .ordering(function(d) {
            let totalTime = 0;
            let count = 0;
            for(let i in d?.value?.records) {
                if(!isNaN(d?.value?.records[i])) {
                    totalTime += d.value.records[i];
                    count++;
                }
            }
            let averageDays = count > 0 ? totalTime / count : 0;
            return -averageDays;
        })
        .gap(2)
        .othersLabel('All others')
        .fixedBarHeight(14)
        .elasticX(true);
    
    chart_workload_type.xAxis().ticks(5);

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
    
    chart_workload_facilities_numRequests.xAxis().ticks(5);

    chart_form_type
        .useViewBoxResizing(true)
    	.height((groupDataClassificationType.all().length * 18) + 60)
        .dimension(dimDataClassificationType)
        .group(groupDataClassificationType)
        .valueAccessor(function(d) { return d.value.count; })
        .title(function(d) { return d.value.count + ' requests'; })
        .ordering(function(d) { return -d.value.count; })
        .gap(2)
        .othersLabel('All others')
        .fixedBarHeight(14)
        .elasticX(true);
    
    chart_form_type.xAxis().ticks(5);

    chart_table_requests
        .dimension(dimService)
        .section(function(d) {
            return d.recordID;
        })
        .showSections(false)
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
    
    return true;
}

/**
 * Purpose: Reinit for different filter (date)
 */
function resetFilters() {
    // pre-select last month
    let today = new Date();
    let lastMonth = new Date(today).setMonth(today.getMonth() - 1);
    let maxDate = new Date(today.getFullYear(), today.getMonth(), today.getDate() + 1);
    chart_workload_timescale_numRequests.filter(dc.filters.RangedFilter(lastMonth, maxDate));
}

function saveCache() {
	let uploadPacket = {};
    let today = new Date();
    uploadPacket.generateDate = today.toLocaleDateString();
    uploadPacket.config = {};
    uploadPacket.config.reportTimeUnit = $('#reportTimeUnit').val();
    uploadPacket.config.showDateSubmitted = $('#showDateSubmitted').val();
    uploadPacket.data = facts.all();
    uploadPacket.dataSteps = dataSteps;
    uploadPacket.version = 2;

    let uploadData = new FormData();
    uploadData.append('CSRFToken', CSRFToken);
    uploadData.append('file', new Blob([ LZString.compressToBase64(JSON.stringify(uploadPacket)) ]), tempFilename);
    $.ajax({
        type: 'POST',
        url: './admin/ajaxIndex.php?a=uploadFile',
        data: uploadData,
        processData: false,
        contentType: false
    });
}

/**
 * Purpose: Loading visual for Init of chart and data
 */
function start() {
    let progressbar = $('#progressbar').progressbar();
    
    let today = new Date();
    $('#generateDate').html(today.toLocaleDateString());

    let siteURL = './';
    getCategories(siteURL)
    .then(function(data) {
        $('#progressbar').progressbar('option', 'max', Object.keys(data).length);

    	let queue = new intervalQueue();
        queue.setConcurrency(3);
        queue.setWorker(function(item) {
            $('#progressbar').progressbar('option', 'value', queue.getLoaded());
        	return loadCategory(siteURL, item).then(function() {
                $('#progressDetail').html(`Loading data (${dataCategories[item]})...`);
            	return loadData(siteURL, item);
            });
        });
        queue.onComplete(function() {
            $('#progressContainer').slideUp();
            $('#chartBody').fadeIn();
            if(setupChart()) {
                dc.renderAll();
                renderGrid();

                saveCache();
            }
        });
        
        for(var i in data) {
            queue.push(i);
        }
        
        queue.start();
    });

}

let numTotalCategories = Infinity;
$(function() {
    queryFirstDateSubmitted = $('#showDateSubmitted').val();

    $.ajax({
        type: 'GET',
        url: `./files/${tempFilename}`,
        success: function(res) {
            res = JSON.parse(LZString.decompressFromBase64(res));
            if(res?.version != 2) {
                start();
                return;
            }
            $('#generateDate').html(res.generateDate);
    		$('#reportTimeUnit').val(res.config.reportTimeUnit);
    		$('#showDateSubmitted').val(res.config.showDateSubmitted);
            dataSteps = res.dataSteps;
            
            parsedData = res.data;
            for(let i in parsedData) {
                parsedData[i].timestamp = new Date(parsedData[i].timestamp);
            }

            $('#progressContainer').slideUp();
            $('#chartBody').fadeIn();

            setupChart();
            dc.renderAll();
            //renderGrid();
        },
        error: function() {
            $('#refreshData').css('display', 'none');
            start();
        },
        cache: false
    });

    $('#showDateSubmitted').on('change', function() {
        $('#refreshData').css('display', 'none');

        queryFirstDateSubmitted = $('#showDateSubmitted').val();
        parsedData = [];
        $('#chartBody').slideUp();
        $('#progressContainer').fadeIn();
        start();
    });

	$('#refreshData').on('click', function() {
        $('#refreshData').css('display', 'none');
        
        queryFirstDateSubmitted = $('#showDateSubmitted').val();
        parsedData = [];
        $('#chartBody').slideUp();
        $('#progressContainer').fadeIn();
        start();
    });

    $('#reportTimeUnit').on('change', function() {
        $('#chartBody').slideUp();
        $('#progressContainer').fadeIn(400, () => {
            $('#progressContainer').slideUp();
            $('#chartBody').fadeIn();

            setupChart();
            dc.renderAll();
            //renderGrid();
            
            saveCache();
        });
    });
    
    
    $('#btn_exportData').on('click', function() {
        let uploadPacket = JSON.stringify(facts.all());
        
        let filename = `leaf_timeline_data-${new Date().getTime()/1000}.json`;
        let file = new Blob([uploadPacket], {type: 'application/json'});
        let obj = URL.createObjectURL(file);
        let link = document.createElement('a');
        link.href = obj;
        link.download = filename;
        document.body.appendChild(link);
        link.click();
    });
    
    $('#filterStart, #filterEnd').on('change', function() {
        let startVal = $('#filterStart').val();
        let endVal = $('#filterEnd').val();
        let filterStart = new Date(startVal);
        let filterEnd = new Date(endVal);
        if(filterStart < filterEnd) {
            chart_workload_timescale.filterAll().filter(dc.filters.RangedFilter(filterStart, filterEnd));
            dc.renderAll();
        }
        $('#filterStart').val(startVal)
        $('#filterEnd').val(endVal)
    });
    
    
    let historicalDataOptions = '';
    for(let i = 2; i <= 15; i++) {
        historicalDataOptions += `<option value="${i} years ago">${i} years ago</option>`;
    }
    $('#showDateSubmitted').append(historicalDataOptions);
});

</script>

<div id="progressContainer" style="width: 50%; border: 1px solid black; background-color: white; margin: auto; padding: 16px">
    <h1 style="text-align: center">Loading...</h1>
    <div id="progressbar"></div>
    <h2 id="progressDetail" style="text-align: center"></h2>
</div>

<div id="chartBody" style="display: none">
    <h1 style="text-align: center">Timeline Data Explorer <span style="background-color: white; color: red; border: 2px solid black; padding: 8px; font-style: italic">BETA 2</span></h1>
    <h2 style="text-align: center">Requests submitted 
        <select id="reportTimeUnit">
            <option value="day">daily</option>
            <option value="week">weekly</option>
            <option value="month" selected="selected">monthly</option>
            <option value="year">yearly</option>
        </select> from 
        <select id="showDateSubmitted">
            <option value="1 month ago">1 month ago</option>
            <option value="3 months ago" selected="selected">3 months ago</option>
            <option value="6 months ago">6 months ago</option>
            <option value="9 months ago">9 months ago</option>
            <option value="1 year ago">1 year ago</option>
        </select>
    </h2>
    <h3 style="text-align: center">
        Last updated <span id="generateDate"></span> <button id="refreshData" class="buttonNorm">Refresh Data</button>
    </h3>

    <div style="float: right">
    	<button id="btn_exportData" class="buttonNorm">Export JSON data</button>
    	<button class="buttonNorm" onclick="dc.filterAll(); dc.renderAll(); resetFilters();">Reset Filters</button>
    </div>

    <div>
        Stats for data in the selected set:
        <table id="container_count" class="table">
            <tr class="label">
                <td>Number of Resolved Requests</td>
            </tr>
            <tr>
                <td id="chart_countResolvedRequests" style="text-align: center"></td>
            </tr>
        </table>
    </div>

    <div id="lt-grid" class="lt-container lt-xs-h-10
                                          lt-md-h-7
                                          lt-lg-h-6" data-arrange="lt-grid">
        <!-- main overview chart -->
        <div class="lt lt-xs-x-0 lt-xs-y-0 lt-xs-w-1 lt-xs-h-1
                    lt-sm-x-2 lt-sm-y-0 lt-sm-w-1 lt-sm-h-1
                    lt-md-x-2 lt-md-y-0 lt-md-w-1 lt-md-h-1
                    lt-lg-x-2 lt-lg-y-0 lt-lg-w-1 lt-lg-h-1" draggable="true">
            <div class="lt-body card chartContainer">
                <div class="label">Average resolution time</div>
                <div class="chart" style="height: 30%; text-align: center; font-size: 5rem"><span id="chart_count_avgCompletionTime"></span><span style="font-size: 2rem"> days</span></div>
            </div>
        </div>

        <!-- chart for resolution time -->
        <div class="lt lt-xs-x-0 lt-xs-y-1 lt-xs-w-1 lt-xs-h-1
                    lt-sm-x-0 lt-sm-y-0 lt-sm-w-2 lt-sm-h-1
                    lt-md-x-0 lt-md-y-0 lt-md-w-2 lt-md-h-1
                    lt-lg-x-0 lt-lg-y-0 lt-lg-w-2 lt-lg-h-2" draggable="true">
            <div class="lt-body card chartContainer">
                <div class="label">Resolution time per <span class="unitTime"></span></div>
                <div id="chart_workload_timescale" class="chart" style="height: 80%"></div>
                <div style="text-align: center">Filter Time: <input id="filterStart" type="date" /> to <input id="filterEnd" type="date" /></div>
            </div>
        </div>

        <!-- chart for services/facilities -->
        <div class="lt lt-xs-x-0 lt-xs-y-2 lt-xs-w-1 lt-xs-h-1
                    lt-sm-x-2 lt-sm-y-1 lt-sm-w-1 lt-sm-h-1
                    lt-md-x-2 lt-md-y-1 lt-md-w-1 lt-md-h-1
                    lt-lg-x-2 lt-lg-y-1 lt-lg-w-1 lt-lg-h-1" draggable="true">
            <div class="lt-body card chartContainer">
                <div class="label">Resolution time per Service</div>
                <div id="chart_facilities" class="chart"></div>
            </div>
        </div>

        <!-- chart for classification type -->
        <div class="lt lt-xs-x-0 lt-xs-y-3 lt-xs-w-1 lt-xs-h-1
					lt-sm-x-2 lt-sm-y-2 lt-sm-w-1 lt-sm-h-1
                    lt-md-x-2 lt-md-y-2 lt-md-w-1 lt-md-h-1
                    lt-lg-x-3 lt-lg-y-0 lt-lg-w-1 lt-lg-h-2" draggable="true">
            <div class="lt-body card chartContainer">
                <div class="label">Type of Form</div>
                <div id="chart_form_type" class="chart"></div>
            </div>
        </div>

		<!-- chart for quantity of resolved requests -->
        <div class="lt lt-xs-x-0 lt-xs-y-4 lt-xs-w-1 lt-xs-h-1
                    lt-sm-x-0 lt-sm-y-1 lt-sm-w-1 lt-sm-h-1
                    lt-md-x-0 lt-md-y-1 lt-md-w-1 lt-md-h-1
                    lt-lg-x-0 lt-lg-y-2 lt-lg-w-2 lt-lg-h-1" draggable="true">
            <div class="lt-body card chartContainer">
                <div class="label">Resolved Requests per <span class="unitTime"></span></div>
                <div id="chart_workload_timescale_numRequests" class="chart"></div>
            </div>
        </div>
        
        <!-- chart for service workload -->
        <div class="lt lt-xs-x-0 lt-xs-y-5 lt-xs-w-1 lt-xs-h-1
                    lt-sm-x-2 lt-sm-y-3 lt-sm-w-1 lt-sm-h-1
                    lt-md-x-2 lt-md-y-3 lt-md-w-1 lt-md-h-1
                    lt-lg-x-3 lt-lg-y-2 lt-lg-w-1 lt-lg-h-1" draggable="true">
            <div class="lt-body card chartContainer">
                <div class="label">Resolution time per type</div>
                <div id="chart_workload_type" class="chart"></div>
            </div>
        </div>

        <!-- chart for service workload number of requests -->
        <div class="lt lt-xs-x-0 lt-xs-y-6 lt-xs-w-1 lt-xs-h-1
                    lt-sm-x-1 lt-sm-y-1 lt-sm-w-1 lt-sm-h-1
                    lt-md-x-1 lt-md-y-1 lt-md-w-1 lt-md-h-1
                    lt-lg-x-2 lt-lg-y-2 lt-lg-w-1 lt-lg-h-1" draggable="true">
            <div class="lt-body card chartContainer">
                <div class="label">Service throughput</div>
                <div id="chart_workload_facilities_numRequests" class="chart"></div>
            </div>
        </div>

        <!-- chart for table: top slowest -->
        <div class="lt lt-xs-x-0 lt-xs-y-7 lt-xs-w-1 lt-xs-h-1
                    lt-sm-x-0 lt-sm-y-4 lt-sm-w-3 lt-sm-h-1
                    lt-md-x-0 lt-md-y-4 lt-md-w-3 lt-md-h-1
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
                    lt-sm-x-0 lt-sm-y-2 lt-sm-w-1 lt-sm-h-2
                    lt-md-x-0 lt-md-y-2 lt-md-w-1 lt-md-h-2
                    lt-lg-x-0 lt-lg-y-3 lt-lg-w-1 lt-lg-h-3" draggable="true">
            <div class="lt-body card">
                <div class="label">Cumulative time spent per step</div>
                <div id="chart_pie_steps_total" class="chart" style="height: 40%"></div>
                <div id="chart_row_steps_total" class="chart" style="height: 50%"></div>
                <div style="text-align: center">Business Days</div>
            </div>
        </div>

        <!-- chart for steps - average -->
        <div class="lt lt-xs-x-0 lt-xs-y-9 lt-xs-w-1 lt-xs-h-1
                    lt-sm-x-1 lt-sm-y-2 lt-sm-w-1 lt-sm-h-2
                    lt-md-x-1 lt-md-y-2 lt-md-w-1 lt-md-h-2
                    lt-lg-x-1 lt-lg-y-3 lt-lg-w-1 lt-lg-h-3" draggable="true">
            <div class="lt-body card">
                <div class="label">Average time spent per step</div>
                <div id="chart_pie_steps" class="chart" style="height: 40%"></div>
                <div id="chart_row_steps" class="chart" style="height: 50%"></div>
                <div style="text-align: center">Business Days</div>
            </div>
        </div>

    </div>

    <br />
    <!-- <p>
        * <span style="text-decoration: line-through">Business day defined as Monday - Friday, 8am - 5pm  (Time zones may reflect minor differences)</span><br />
        * "Handoff" or "Complexity" is defined as an action taken that routes a request to another stakeholder
    </p>-->

</div>
