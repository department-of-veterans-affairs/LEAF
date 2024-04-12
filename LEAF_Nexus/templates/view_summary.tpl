<script src="<!--{$app_js_path}-->/LEAF/formQuery.js"></script>
<script src="<!--{$app_js_path}-->/LEAF/formGrid.js"></script>

<script src="https://cdnjs.cloudflare.com/ajax/libs/bignumber.js/2.3.0/bignumber.min.js"></script>

<link rel="stylesheet" type="text/css" href="<!--{$app_js_path}-->/jquery/layout-grid/css/layout-grid.min.css" />
<script src="//cdnjs.cloudflare.com/ajax/libs/d3/3.5.16/d3.min.js"></script>
<script src="//cdnjs.cloudflare.com/ajax/libs/crossfilter/1.3.12/crossfilter.min.js"></script>
<script src="//cdnjs.cloudflare.com/ajax/libs/dc/2.0.0-beta.27/dc.min.js"></script>
<link rel="stylesheet" type="text/css" href="//cdnjs.cloudflare.com/ajax/libs/dc/2.0.0-beta.27/dc.min.css" />
<script>

function postRender() {
    // styles
    $('.dc-chart g.row text').css({'fill': 'black'});
}

$(function() {

var months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'June', 'July', 'Aug', 'Sept', 'Oct', 'Nov', 'Dec'];

var parsedData = Array();
var parsedDataByService = {};
$.ajax({
    type: 'GET',
    url: './utils/jsonExport_PDL.php',
    timeout: 240000,
    success: function(data) {
        for(var i in data) {
            parsedData.push({
                positionID: data[i].positionID,
                positionTitle: data[i].positionTitle,
                employee: data[i].employee,
                supervisor: data[i].supervisor,
                service: data[i].service,
                payPlan: data[i].payPlan,
                series: data[i].series,
                payGrade: data[i].payGrade,
                fteCeiling: data[i].fteCeiling,
                currentFte: data[i].currentFte,
                pdNumber: data[i].pdNumber
            });

            if(parsedDataByService[data[i].service] == undefined) {
                parsedDataByService[data[i].service] = {};
                parsedDataByService[data[i].service].service = data[i].service;
                parsedDataByService[data[i].service].authorized = 0;
                parsedDataByService[data[i].service].onBoard = 0;
                parsedDataByService[data[i].service].vacant = 0;
                parsedDataByService[data[i].service].recordID = i;
                parsedDataByService[data[i].service].indicatorID = i;
            }
            parsedDataByService[data[i].service].authorized = new BigNumber(parsedDataByService[data[i].service].authorized).plus(data[i].fteCeiling).round(3).toString();
            if(data[i].currentFte == 0) {
                parsedDataByService[data[i].service].vacant = new BigNumber(parsedDataByService[data[i].service].vacant).plus(data[i].fteCeiling).round(3).toString();
            }
            else {
                parsedDataByService[data[i].service].onBoard = new BigNumber(parsedDataByService[data[i].service].onBoard).plus(data[i].fteCeiling).round(3).toString();
            }
        }

        var chart_countFTEtotal = dc.numberDisplay('#chart_totalFTE');
        var chart_countFTEonBoard = dc.numberDisplay('#chart_FTEonBoard');
        var chart_countFTEvacant = dc.numberDisplay('#chart_FTEvacant');
        var chart_dataTable = dc.dataTable('#chart_dataTable');
        var chart_services_bar = dc.rowChart('#chart_services_bar');
        var chart_vacancy = dc.pieChart('#chart_vacancy');

        var cf = crossfilter(parsedData);
        var serviceDim = cf.dimension(function(d) { return d.service; });
        var vacancyDim = cf.dimension(function(d) {
            if(d.currentFte == 0) {
            	return 'Vacant';
            }
            return 'On Board';
        });
        var serviceGroup = serviceDim.group().reduceSum(function(d) { return d.fteCeiling; });
        var vacancyGroup = vacancyDim.group().reduceSum(function(d) { return d.fteCeiling; });
        var numFTEGroup = cf.groupAll().reduce(
            function(p, v) {
                p.total += Number(v.fteCeiling);
                if(v.currentFte == 0) {
                    p.vacant += Number(v.fteCeiling);
                }
                else {
                	p.onBoard += Number(v.fteCeiling);
                }
                return p;
            },
            function(p, v) {
                p.total -= Number(v.fteCeiling);
                if(v.currentFte == 0) {
                    p.vacant -= Number(v.fteCeiling);
                }
                else {
                    p.onBoard -= Number(v.fteCeiling);
                }
                return p;
            },
            function(p, v) {
                return {total: 0, vacant: 0, onBoard: 0};
            }
        );



        // counter
        chart_countFTEtotal
            .valueAccessor(function(d) { return d.total; })
            .group(numFTEGroup)
            .formatNumber(d3.format(',.3f'));

        chart_countFTEonBoard
            .valueAccessor(function(d) { return d.onBoard; })
            .group(numFTEGroup)
            .formatNumber(d3.format(',.3f'));

        chart_countFTEvacant
            .valueAccessor(function(d) { return d.vacant; })
            .group(numFTEGroup)
            .formatNumber(d3.format(',.3f'));

        // service vacancy breakdown
        var tGridData = [];
        for(var i in parsedDataByService) {
            tGridData.push(parsedDataByService[i]);
        }

        var grid = new LeafFormGrid('grid_service_vacancy', {readOnly: true});
        grid.disableVirtualHeader();
        grid.hideIndex();
        grid.enableToolbar();
        grid.setData(tGridData);
        grid.setHeaders([{name: 'Service', indicatorID: 'service', callback: function(data, blob) {
            $('#'+data.cellContainerID).html(grid.getDataByIndex(data.index).service);
        }},
        {name: 'Authorized FTE', indicatorID: 'authorizedFTE', callback: function(data, blob) {
            $('#'+data.cellContainerID).html(grid.getDataByIndex(data.index).authorized);
        }},
        {name: 'On Board FTE', indicatorID: 'onboardFTE', callback: function(data, blob) {
            $('#'+data.cellContainerID).html(grid.getDataByIndex(data.index).onBoard);
        }},
        {name: 'Vacant FTE', indicatorID: 'vacantFTE', callback: function(data, blob) {
            $('#'+data.cellContainerID).html(grid.getDataByIndex(data.index).vacant);
        }}]);
        grid.renderBody();

        // data table
        chart_dataTable
            .dimension(serviceDim)
            .group(function(d) {
                return '<b>' + d.service + '</b>';
            })
            .columns([
                function(d) { return '<a href="?a=view_position&positionID='+ d.positionID +'">' + d.positionTitle + '</a>'; },
                function(d) { return d.payPlan; },
                function(d) { return d.series; },
                function(d) { return d.payGrade; },
                function(d) { return d.employee; }
            ])
            .size(Infinity)
            .sortBy(function(d) { return d.service + d.positionID; }); // hacky way to give supervisors priority

        // service breakdown chart
        chart_services_bar
            .dimension(serviceDim)
            .group(serviceGroup)
            .fixedBarHeight(20)
            .height((serviceGroup.all().length * 28) + 30)
            .ordering(function(d) { return d.key; })
            .title(function(d) { return d.key + ': ' + Math.round(d.value * 100) / 100 + ' FTE'; })
            .elasticX(true);

        chart_vacancy
            .dimension(vacancyDim)
            .group(vacancyGroup)
            .title(function(d) { return d.key + ': ' + Math.round(d.value * 100) / 100 + ' FTE'; });

        $('#progressContainer').slideUp();
        $('#reportBody').fadeIn();

        // don't show full dataTable unless requested
        function showAll() {
            $('#btn_showAll').css('display', 'none');
            chart_dataTable.endSlice(Infinity);
            chart_dataTable.redraw();
        }
        $('#btn_showAll').on('click', function() {
            showAll();
        });
        chart_dataTable.endSlice(50);

        dc.renderAll();
        postRender();
    },
    error: function(jXHR, text, error) {
        alert(error);
    }
});


});

</script>

<div id="progressContainer" style="width: 50%; border: 1px solid black; background-color: white; margin: auto; padding: 16px">
    <h1 style="text-align: center">Loading... <img src="./images/largespinner.gif" alt="" /></h1>
</div>

<div id="reportBody" style="display: none">

<button class="buttonNorm" style="float: right" onclick="dc.filterAll(); dc.renderAll(); postRender();">Reset Filters</button>

<h2 style="">Vacancy Report</h2>

<br style="clear: both" />

<div id="lt-container" class="lt-container lt-lg-h-2 lt-md-h-2 lt-sm-h-3 lt-xs-h-4" data-arrange="lt-grid">
    <!-- Summary counts -->
    <div class="lt lt-lg-x-0 lt-lg-y-0 lt-lg-w-1 lt-lg-h-1
                   lt-md-x-0 lt-md-y-0 lt-md-w-1 lt-md-h-1
                   lt-sm-x-0 lt-sm-y-0 lt-sm-w-1 lt-sm-h-1
                   lt-xs-y-0 lt-xs-h-1">
        <div class="lt-body">
            <table id="container_count" class="table" style="width: 100%">
                <tr>
                    <td>Authorized FTE</td>
                    <td id="chart_totalFTE" style="text-align: center"></td>
                </tr>
                <tr>
                    <td>On Board:</td>
                    <td id="chart_FTEonBoard" style="text-align: center"></td>
                </tr>
                <tr>
                    <td>Vacant</td>
                    <td id="chart_FTEvacant" style="text-align: center"></td>
                </tr>
            </table>
        </div>
    </div>
    <!-- Vacancy Piechart -->
    <div class="lt lt-lg-x-0 lt-lg-y-1 lt-lg-w-1 lt-lg-h-1
                   lt-md-x-1 lt-md-y-0 lt-md-w-1 lt-md-h-1
                   lt-sm-x-0 lt-sm-y-1 lt-sm-w-1 lt-sm-h-1
                   lt-xs-y-1 lt-xs-h-1">
        <div class="lt-body">
            <div id="chart_vacancy"></div>
        </div>
    </div>
    <!-- Datatable -->
    <div class="lt lt-lg-x-1 lt-lg-y-0 lt-lg-w-2 lt-lg-h-2
                   lt-md-x-0 lt-md-y-1 lt-md-w-3 lt-md-h-1
                   lt-sm-x-0 lt-sm-y-2 lt-sm-w-2 lt-sm-h-1
                   lt-xs-y-3 lt-xs-h-1">
        <div class="lt-body">
            <div style="overflow: auto; height: 100%">
                <table id="chart_dataTable" class="table" style="width: 99%">
                    <thead class="header">
                        <td>Position Title</td>
                        <td>Pay Plan</td>
                        <td>Series</td>
                        <td>Pay Grade</td>
                        <td>Incumbent</td>
                    </thead>
                </table>
                <button id="btn_showAll">Show All</button>
            </div>
        </div>
    </div>
    <!-- Service list -->
    <div class="lt lt-lg-x-3 lt-lg-y-0 lt-lg-w-1 lt-lg-h-2
                   lt-md-x-2 lt-md-y-0 lt-md-w-1 lt-md-h-1
                   lt-sm-x-1 lt-sm-y-0 lt-sm-w-1 lt-sm-h-2
                   lt-xs-y-2 lt-xs-h-1">
        <div class="lt-body">
            <div style="overflow-y: auto; overflow-x: hidden; height: 100%; background-color: white; border: 1px solid black">
                <div id="chart_services_bar"></div>
            </div>
        </div>
    </div>
</div>

<hr /><br />
<div id="grid_service_vacancy">Service Breakdown</div>

</div> <!-- End reportBody-->
