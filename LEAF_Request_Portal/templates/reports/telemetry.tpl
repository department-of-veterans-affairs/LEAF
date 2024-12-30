<script src="//cdnjs.cloudflare.com/ajax/libs/d3/3.5.16/d3.min.js"></script>
<script src="//cdnjs.cloudflare.com/ajax/libs/crossfilter/1.3.12/crossfilter.min.js"></script>
<script src="//cdnjs.cloudflare.com/ajax/libs/dc/2.0.0-beta.27/dc.min.js"></script>
<link rel="stylesheet" type="text/css" href="//cdnjs.cloudflare.com/ajax/libs/dc/2.0.0-beta.27/dc.min.css" />
<script>
var CSRFToken = '<!--{$CSRFToken}-->';

$(function() {

var query = new LeafFormQuery();
var months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'June', 'July', 'Aug', 'Sept', 'Oct', 'Nov', 'Dec'];

$.ajax({
    type: 'GET',
    url: './api/telemetry/requests?startTime=0&endTime=9999999999',
    success: function(data) {
        var date = new Date();
        var parsedData = [];
        var month;
        for(var i in data) {
            parsedData.push({
                recordID: data[i].recordID,
                submitted: new Date(data[i].submitted * 1000),
                timeFillOut: data[i].submitted - data[i].initiated,
                timeSubmitted: data[i].submitted * 1000,
                timeResolved: data[i].resolved * 1000
            });
        }

        var chart = dc.lineChart('#chart');
        var chart_count = dc.numberDisplay('#chart_count');

        var facts = crossfilter(parsedData);
        var dimCategory = facts.dimension(function(d) { return d.categoryName; });
        var dimSubmittedByMonth = facts.dimension(function(d) { return d3.time.month(d.submitted); });
        
        var groupSubmittedByMonth = dimSubmittedByMonth.group().reduceCount(function(d) { d.submitted });

        var minDate = dimSubmittedByMonth.bottom(1)[0].submitted;
        var maxDate = dimSubmittedByMonth.top(1)[0].submitted;

        chart
            .width(480)
            .height(240)
            .margins({top: 10, right: 10, bottom: 20, left: 40})
            .dimension(dimSubmittedByMonth)
            .group(groupSubmittedByMonth)
            .yAxisLabel('Number of Requests')
            .x(d3.time.scale().domain([minDate, maxDate]))
            .xUnits(d3.time.months)
            .elasticY(true);
        
        // counter
        chart_count
            .valueAccessor(function(d) { return d; })
            .group(dimSubmittedByMonth.groupAll())
            .formatNumber(d3.format(',.0f'));
      
        dc.renderAll();
    }
});

});

</script>

<h2 style="">All requests made in the system</h2>

<span class="buttonNorm" style="float: right" onclick="dc.filterAll(); dc.renderAll();">Reset Filters</span>

<div id="grid"></div>

<table id="container_count" class="table">
  	<tr>
    	<td>Number of Requests</td>
      	<td id="chart_count" style="text-align: center"></td>
    </tr>

</table>
<div id="chart"></div>
