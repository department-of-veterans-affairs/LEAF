<script src="../libs/js/moment/moment.min.js"></script>
<script src="../libs/js/moment/moment-timezone-with-data.min.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/Chart.js/2.7.2/Chart.min.js"></script>

<script>
var CSRFToken = '<!--{$CSRFToken}-->';
  
// Calculates time difference during business hours
var startBusinessHours = 8; // 8am
var endBusinessHours = 17; // 5pm
var currentTzOffset = new Date().getTimezoneOffset() / 60;
var siteTzOffset = moment.tz.zone("<!--{$systemSettings['timeZone']}-->").offset(moment.utc()) / 60; // time zone offset, in hours
var tzOffset = siteTzOffset - currentTzOffset;

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

var timelines = {}; // cache for timeline data
function processData(queryResult, workflowData) {
    var workflow = {};
    for(var i in workflowData) {
        workflow[workflowData[i].stepID] = workflowData[i].stepTitle;
    }
    var res = queryResult;
    timelines = {};

    for(var i in res) {
        var request = res[i];

        for(var j in request.action_history) {
            var idx = Number(j);
            if(request.action_history[idx + 1] != undefined) {
                var stepID = request.action_history[idx + 1].stepID;
                var startTime = request.action_history[idx].time;
                var endTime = request.action_history[idx + 1].time;

                if(workflow[stepID] != undefined) {
                    timelines[stepID] = timelines[stepID] || {};
                    timelines[stepID].label = workflow[stepID];
                }
                else {
                    stepID = 'Other route';
                    timelines[stepID] = timelines[stepID] || {};
                    timelines[stepID].label = 'Other route';
                }

                // only count the slowest approver in a multi-requirement step   
                if(request.action_history[idx].stepID != request.action_history[idx + 1].stepID) {
                    timelines[stepID].count = timelines[stepID].count == undefined ? 1 : timelines[stepID].count + 1;
                }
                timelines[stepID].time = timelines[stepID].time == undefined ? diffBusinessTime(startTime, endTime) : timelines[stepID].time + diffBusinessTime(startTime, endTime);
            }
        }
    }
}

function randInt(min, max) {
    return Math.floor(Math.random() * (max - min + 1)) + min;
}

var labels = [];
var labelColors = [];
var niceColors = ['#00a6d2', '#f9c642', '#4aa564', '#4773aa', '#9bdaf1', '#cd2026', '#fad980', '#94bfa2', '#8ba6ca', '#4c2c92'];
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

function renderData(categoryID, label) {
    // build chart data
    chartConfig.data.labels.push(label);
    var numIndex = chartConfig.data.labels.length;
    for(var i in chartConfig.data.datasets) {
        chartConfig.data.datasets[i].data.push(null);
    }

    for(var i in timelines) {
        var dataSet = {
            label: timelines[i].label,
            data: [],
        };
        for(var j = 1; j < numIndex; j++) {
            dataSet.data.push(null);
        }
        var time = Math.round((timelines[i].time / timelines[i].count) /60 /60 /8 *10) / 10;
        dataSet.data.push(time);
        dataSet.backgroundColor = getLabelColor(i);
        dataSet.borderColor = 'black';
        dataSet.borderWidth = 1;
        chartConfig.data.datasets.push(dataSet);
    }
    myChart.update();
    
    $('#progressContainer').slideUp();
    $('#chartBody').fadeIn();
}

var numCategories = 0;
function renderCategory(categoryID) {
    var query = new LeafFormQuery();

    query.addTerm('dateSubmitted', '>=', '3 months ago');
    query.addTerm('deleted', '=', 0);
    query.addTerm('categoryID', '=', categoryID);
    query.addTerm('stepID', '=', 'resolved');
    query.join('action_history');

    var data = {};
    query.onSuccess(function(res) {
        if(res.length == 0) {
            return 0;
        }
        numCategories++;
        var categoryID = res[Object.keys(res)[0]].categoryID;

        $.ajax({
            type: 'GET',
            url: './api/form/_' + categoryID + '/workflow'
        })
        .then(function(workflow) {
            $.ajax({
                type: 'GET',
                url: './api/workflow/' + workflow[0].workflowID
            })
            .then(function(workflowData) {
                processData(res, workflowData);
                renderData(categoryID, workflow[0].categoryName);
            });
        });
    });
    
    query.execute();
}

function newChartConfig() {
    return {
        type: 'horizontalBar',
        data: {
            labels: [],
            datasets: []
        },
        options: {
            tooltips: {
                mode: 'label',
                position: 'nearest',
                callbacks: {
                    afterBody: function(tooltipItem, data) {
                        var total = 0;
                        for(var i in tooltipItem) {
                            if(!isNaN(tooltipItem[i].xLabel)) {
                                total += tooltipItem[i].xLabel;
                            }
                        }
                        return ['', Math.round(total * 10) / 10 + ' total business days'];
                        
                    },
                    label: function(tooltipItem, data) {
                        if(!isNaN(tooltipItem.xLabel)) {
                            return data.datasets[tooltipItem.datasetIndex].label + ': ' + tooltipItem.xLabel;
                        }
                    }
                }
            },
            scales: {
                xAxes: [{
                    stacked: true,
                    scaleLabel: {
                        display: true,
                        labelString: 'Business Days'
                    }
                }],
                yAxes: [{
                    stacked: true,
                    ticks: {
                        beginAtZero:true
                    },
                    scaleLabel: {
                        display: true,
                        labelString: 'Request Type'
                    }
                }]
            },
            legend: {
                display: false
            },
            layout: {
                padding: 16
            }
        }
    };
}

var myChart;
var chartConfig = newChartConfig();
function createChart() {
    var ctx = document.getElementById("chart");

    myChart = new Chart(ctx, chartConfig);
}

function applyFilters() {
    myChart.destroy();
    chartConfig = newChartConfig();
    createChart();
    $('#categories input:checked').each(function() {
        renderCategory($(this).attr('value'));
    });
}

$(function() {
    createChart();

    $.ajax({
        type: 'GET',
        url: './api/formStack/categoryList/all'
    })
    .then(function(categories) {
        for(var i in categories) {
            if(categories[i].workflowID > 0
                && categories[i].parentID == '') {
                renderCategory(categories[i].categoryID);
                
                $('#categories').append('<div style="float: left; padding: 8px; white-space: nowrap"><input type="checkbox" id="category_'+ categories[i].categoryID +'" name="categoryID" value="'+ categories[i].categoryID +'" checked="checked" /><label class="checkable" for="category_'+ categories[i].categoryID +'">' + categories[i].categoryName + '</label></div>');
            }
        }
        $('#categories input').icheck({checkboxClass: 'icheckbox_square-blue', radioClass: 'iradio_square-blue'});
    });
    $('#progressContainer').slideUp();
    $('#chartBody').fadeIn();
});

</script>
<div id="progressContainer" style="width: 50%; border: 1px solid black; background-color: white; margin: auto; padding: 16px">
    <h1 style="text-align: center">Loading... <img src="./images/largespinner.gif" alt="loading indicator" /></h1>
</div>

<div id="chartBody" style="display: none">

    <h2 style="text-align: center">Average Business days to resolve requests (past 3 months)</h2>
    
    <div id="chartContainer" style="background-color: white; width: 800px; height: 400px; margin: auto; border: 1px solid black">
        <canvas id="chart" width="800" height="400"></canvas>
    </div>
    <br />
    <div class="card" style="padding: 8px; text-align: center">
        <div id="categories"></div>
        <br style="clear: both" />
        <button class="buttonNorm" onclick="applyFilters();">Apply filters</button>
    </div>

    <br />
    <div>
    * Business day defined as Monday - Friday, 8am - 5pm
    </div>
</div>
